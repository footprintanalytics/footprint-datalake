{{config(
    materialized='incremental',
    unique_key=['on_date','chain','protocol_slug','wallet_address'],
    incremental_strategy='merge',
    properties={
        "partitioning": "ARRAY['month(on_date)']",
    }
)}}

{#
'【可选参数】'
'注意： 刷数据时间只能从前往后刷（从过去时间往现在时间刷），不能从后往前刷，不然数据会有问题'
'protocol_slug: ["aave",...]'
'chain_values: ["Hive"]'
'start_time: 开始时间'
'end_time: 结束时间'
#}

with protocol_info as
(
    select
        chain,
        protocol_slug,
        protocol_name,
		protocol_type
    from iceberg.prod_silver.protocol_info
    where protocol_type = 'GameFi'
),
protocol_transactions as
(
    select *
    from {{ref('protocol_transactions')}}
    where
    {% if is_incremental() %}
        {% if var('start_time', none) is not none and var('end_time',none) is not none %}
            block_timestamp >= timestamp '{{var("start_time")}}'  and block_timestamp < timestamp '{{var("end_time")}}'
        {% else %}
            block_timestamp >= date_add('day', -2, current_date) and block_timestamp < current_date
        {% endif %}
    {% else %}
        block_timestamp < current_date
    {% endif %}
    {% if var('protocol_slug', none) is not none %}
        and protocol_slug in ('{{var("protocol_slug")|join("','")}}')
    {% endif%}
    {% if var('chain_values', none) is not none %}
        and "chain" in ('{{var("chain_values")|join("','")}}')
    {% endif%}
),
-- 获取 transactions 的去重 wallet_address 交易地址
distinct_transactions_on_date as
(
    select
        cast(block_timestamp as date) as on_date,
        protocol_slug,
        protocol_name,
        chain,
        wallet_address
    from protocol_transactions
    group by cast(block_timestamp as date), chain, protocol_slug, wallet_address, protocol_name
),
transactions_mix_type as
(
    select
        t1.on_date,
        t1.protocol_slug,
        t1.protocol_name,
        t1.chain,
        t1.wallet_address,
        t2.protocol_type
    from distinct_transactions_on_date t1
    inner join protocol_info t2 on t1.protocol_slug = t2.protocol_slug and t1.chain = t2.chain
),
distinct_transactions as
(
    select
        min(on_date) as on_date,
        protocol_slug,
        chain,
        wallet_address
    from distinct_transactions_on_date
    group by chain, protocol_slug, wallet_address
),
history_protocol_new_address as
(
    select * from {{this}}
    where is_new_address = True
    {% if is_incremental() %}
        {% if var('start_time', none) is not none and var('end_time',none) is not none %}
            and on_date < timestamp '{{var("start_time")}}'
        {% else %}
            and on_date < date_add('day', -2, current_date)
        {% endif %}
    {% else %}
        and on_date < current_date
    {% endif %}
    {% if var('protocol_slug', none) is not none %}
        and protocol_slug in ('{{var("protocol_slug")|join("','")}}')
    {% endif%}
    {% if var('chain_values', none) is not none %}
        and "chain" in ('{{var("chain_values")|join("','")}}')
    {% endif%}
),
-- 判断 transactions wallet_address 是否是新的 wallet_address
protocol_new_address as
(
    select
        t1.on_date,
        t1.protocol_slug,
        t1.chain,
        t1.wallet_address,
        if(t2.is_new_address = True,False,True) as is_new_address
    from distinct_transactions t1
    left join history_protocol_new_address t2 on t1.protocol_slug = t2.protocol_slug
        and t1.chain = t2.chain
        and t1.wallet_address = t2.wallet_address
)
select
    t1.on_date,
    t1.chain,
    t1.protocol_slug,
    t1.wallet_address,
    t1.protocol_name,
    coalesce(t2.is_new_address, False) as is_new_address,
    t1.protocol_type
from transactions_mix_type t1
left join protocol_new_address t2 on t1.on_date = t2.on_date
    and t1.chain = t2.chain
    and t1.wallet_address = t2.wallet_address
    and t1.protocol_slug = t2.protocol_slug

{{config(
    materialized='incremental',
    unique_key=['on_date','chain','protocol_slug'],
    incremental_strategy='merge'
)}}
{#
'注意： 刷数据时间只能从前往后刷（从过去时间往现在时间刷），不能从后往前刷，不然数据会有问题'
'protocol_slug: ["aave",...]'
'chain_values: ["Hive"]'
'start_time: 开始时间'
'end_time: 结束时间'
#}
{% if var('start_time', none) is not none and var('end_time', none) is not none %}
    {% set time_filter = "block_timestamp >= timestamp '"+var('start_time')+"' and block_timestamp < timestamp '"+var('end_time')+"'" %}
{% else %}
    {% set time_filter = "block_timestamp >= date_add('day', -1, current_date)" %}
{% endif %}

with contract_info as
(
    select protocol_slug, chain
    from iceberg.prod_silver.contract_info
    group by protocol_slug, chain having count(1) > 0
),
protocol_info as
(
    select
        chain,
        protocol_slug,
        protocol_name
    from iceberg.prod_silver.protocol_info
    where protocol_type = 'GameFi'
),
need_flatten_protocol_info as
(
    select
        t1.protocol_slug as protocol_slug,
        t1.chain as chain,
        t1.protocol_name as protocol_name
    from protocol_info t1
    left join contract_info t2 on t1.chain = t2.chain
        and t1.protocol_slug = t2.protocol_slug
    where t2.protocol_slug is not null
    {% if var('protocol_slug', none) is not none %}
        and t1.protocol_slug in ('{{var("protocol_slug")|join("','")}}')
    {% endif%}
    {% if var('chain_values', none) is not none %}
        and t1."chain" in ('{{var("chain_values")|join("','")}}')
    {% endif%}

),
-- 生成日期序列：开始日期&结束日期
date_sequence as
(
    {% if is_incremental() %}
        {% if var('start_time', none) is not none and var('end_time',none) is not none %}
            select sequence(date '{{var("start_time")}}', date '{{var("end_time")}}') as date_arrs
        {% else %}
            select sequence(date_add('day', -2, current_date), current_date) as date_arrs
        {% endif %}
    {% else %}
        select sequence(date_add('month', -61, current_date), current_date) as date_arrs
    {% endif %}
),
epoch_date_list as
(
    select epoch_date
    from date_sequence
    cross join UNNEST(date_arrs) AS temTable (epoch_date)
    {% if var('start_time', none) is not none and var('end_time',none) is not none %}
        where epoch_date <  date '{{var("end_time")}}'
    {% else %}
        where epoch_date < current_date
    {% endif %}
),
-- 补齐数据
epoch_flatten_protocol_info as
(
    select t1.epoch_date, t2.protocol_slug, t2.chain, t2.protocol_name
    from epoch_date_list t1
    cross join need_flatten_protocol_info t2
),
protocol_active_address as
(
    select *
    from {{ref('protocol_active_address')}}
    where
    {% if is_incremental() %}
        {% if var('start_time', none) is not none and var('end_time',none) is not none %}
            on_date >= date '{{var("start_time")}}'  and on_date < date '{{var("end_time")}}'
        {% else %}
            on_date >= date_add('day', -2, current_date) and on_date < current_date
        {% endif %}
    {% else %}
        on_date < current_date
    {% endif %}
    {% if var('protocol_slug', none) is not none %}
        and protocol_slug in ('{{var("protocol_slug")|join("','")}}')
    {% endif%}
    {% if var('chain_values', none) is not none %}
        and chain in ('{{var("chain_values")|join("','")}}')
    {% endif%}
),
protocol_token_transfers as (
    select
    *
    from {{ref('protocol_token_transfers')}}
    where
    {{time_filter}}
    {% if var('protocol_slug', none) is not none %}
        and protocol_slug in ('{{var("protocol_slug")|join("','")}}')
    {% endif%}
    {% if var('chain_values', none) is not none %}
        and chain in ('{{var("chain_values")|join("','")}}')
    {% endif%}
)
, protocol_transactions as (
    select
    *
    from {{ref('protocol_transactions')}}
    where
    {{time_filter}}
    {% if var('protocol_slug', none) is not none %}
        and protocol_slug in ('{{var("protocol_slug")|join("','")}}')
    {% endif%}
    {% if var('chain_values', none) is not none %}
        and chain in ('{{var("chain_values")|join("','")}}')
    {% endif%}
)
-- protocol_slug 摊平实现每一天都需要有数据, 找到缺失数据的那一天
, protocol_users_info as
(
    select
        t1.epoch_date as on_date,
        t1.protocol_slug,
        t1.protocol_name,
        t1.chain,
        coalesce(t2.number_of_active_users, 0) as number_of_active_users,
        coalesce(t2.number_of_new_users, 0) as number_of_new_users,
        coalesce(t2.number_of_total_users, 0) as number_of_total_users
    from epoch_flatten_protocol_info t1
    left join
    (
        select
            on_date,
            protocol_slug,
            protocol_name,
            chain,
            count(distinct wallet_address) as number_of_active_users,
            coalesce(sum(if(is_new_address,1,0)),0) as number_of_new_users,
            0 as number_of_total_users
        from protocol_active_address
        group by on_date, protocol_slug, protocol_name, chain
    ) t2 on t1.protocol_slug = t2.protocol_slug
        and t1.chain = t2.chain
        and t1.epoch_date = t2.on_date
),
last_year_daily_stats as
(
    select * from {{this}}
        {% if var('start_time', none) is not none and var('end_time',none) is not none %}
            where on_date >= date_add('day', -360, date '{{var("start_time")}}') and on_date< date '{{var("start_time")}}'
        {% else %}
            where on_date >= date_add('day', -362, current_date)
        {% endif %}
        {% if var('protocol_slug', none) is not none %}
            and protocol_slug in ('{{var("protocol_slug")|join("','")}}')
        {% endif%}
        {% if var('chain_values', none) is not none %}
            and "chain" in ('{{var("chain_values")|join("','")}}')
        {% endif%}
),
-- 新的 active 数据先聚合成新的 protocol_daily_stats, 再拼接一年前的 protocol_daily_stats 数据
aggregate_daily_stats as
(
    select
        on_date,
        protocol_slug,
        protocol_name,
        chain,
        number_of_active_users,
        number_of_new_users,
        sum(coalesce(number_of_new_users,0)) over (partition by protocol_slug, chain order by on_date) as number_of_total_users
    from protocol_users_info
    union all
    select
        on_date,
        protocol_slug,
        protocol_name,
        chain,
        number_of_active_users,
        number_of_new_users,
        number_of_total_users
    from last_year_daily_stats
        {% if var('start_time', none) is not none and var('end_time',none) is not none %}
            where on_date <  date '{{var("start_time")}}'
        {% else %}
            where on_date < date_add('day', -2, current_date)
        {% endif %}
),
last_day_daily_stats as
(
    select *
    from last_year_daily_stats
        {% if var('start_time', none) is not none and var('end_time',none) is not none %}
            where on_date = date_add('day', -1, date '{{var("start_time")}}')
        {% else %}
            where on_date = date_add('day', -3, current_date)
        {% endif %}

),
base_daily_stats as
(
    select
        t1.on_date as on_date,
        t1.protocol_slug as protocol_slug,
        t1.protocol_name as protocol_name,
        t1.chain as chain,
        t1.number_of_active_users as number_of_active_users,
        t1.number_of_new_users as number_of_new_users,
        t1.number_of_total_users as number_of_total_users,
        coalesce(t2.number_of_total_users, 0) as last_number_of_total_users
    from aggregate_daily_stats t1
    left join last_day_daily_stats t2 on t2.protocol_slug = t1.protocol_slug
        and t2.chain = t1.chain
),
daily_stats as
(
    select
        on_date,
        chain,
        protocol_slug,
        protocol_name,
        number_of_active_users,
        number_of_new_users,
        last_number_of_total_users,
        number_of_total_users,
        lag(number_of_active_users,1,0) over (partition by protocol_slug,chain order by on_date) as number_of_d1_active_user,
        lag(number_of_active_users,7,0) over (partition by protocol_slug,chain order by on_date) as number_of_d7_active_user,
        lag(number_of_active_users,30,0) over (partition by protocol_slug,chain order by on_date) as number_of_d30_active_user,
        lag(number_of_active_users,180,0) over (partition by protocol_slug,chain order by on_date) as number_of_d180_active_user,
        lag(number_of_active_users,360,0) over (partition by protocol_slug,chain order by on_date) as number_of_d360_active_user,
        lag(number_of_new_users,1,0) over (partition by protocol_slug,chain order by on_date) as number_of_d1_new_user,
        lag(number_of_new_users,7,0) over (partition by protocol_slug,chain order by on_date) as number_of_d7_new_user,
        lag(number_of_new_users,30,0) over (partition by protocol_slug,chain order by on_date) as number_of_d30_new_user,
        lag(number_of_new_users,180,0) over (partition by protocol_slug,chain order by on_date) as number_of_d180_new_user,
        lag(number_of_new_users,360,0) over (partition by protocol_slug,chain order by on_date) as number_of_d360_new_user
    from base_daily_stats
)
, volume_daily_stats as (
    select
       date(block_timestamp) as on_date,
       chain,
       protocol_slug,
       sum(value) as volume
    from protocol_token_transfers
    where type = 'in'
    group by 1,2,3
)
, transactions_daily_stats as (
    select
        date(block_timestamp) as on_date,
        chain,
        protocol_slug,
        count(distinct transaction_hash) as number_of_transactions
    from protocol_transactions
    group by 1,2,3
)
select
    t1.on_date,
    t1.chain,
    t1.protocol_slug,
    t1.protocol_name,
    t1.number_of_active_users,
    t1.number_of_new_users,
    t1.number_of_total_users,
    case
        when number_of_d1_new_user =0 and number_of_new_users =0 then 0
        when number_of_d1_new_user =0 then 1
        else ((cast(number_of_new_users as double)/number_of_d1_new_user) - 1 )
    end as new_users_1d_pct_change,
    case
        when number_of_d7_new_user =0 and number_of_new_users=0 then 0
        when number_of_d7_new_user =0 then 1
        else ((cast(number_of_new_users as double)/number_of_d7_new_user) - 1 )
    end as new_users_7d_pct_change,
    case
        when number_of_d30_new_user =0 and number_of_new_users=0 then 0
        when number_of_d30_new_user =0 then 1
        else ((cast(number_of_new_users as double)/number_of_d30_new_user) - 1 )
    end as new_users_30d_pct_change,
    case
        when number_of_d180_new_user =0 and number_of_new_users=0 then 0
        when number_of_d180_new_user =0 then 1
        else ((cast(number_of_new_users as double)/number_of_d180_new_user) - 1 )
    end as new_users_180d_pct_change,
    case
        when number_of_d360_new_user =0 and number_of_new_users=0 then 0
        when number_of_d360_new_user =0 then 1
        else ((cast(number_of_new_users as double)/number_of_d360_new_user) - 1 )
    end as new_users_360d_pct_change,
    case
        when number_of_d1_active_user =0 and number_of_active_users=0 then 0
        when number_of_d1_active_user =0  then 1
        else ((cast(number_of_active_users as double)/number_of_d1_active_user) - 1)
    end as active_users_1d_pct_change,
    case
        when number_of_d7_active_user =0 and number_of_active_users=0 then 0
        when number_of_d7_active_user =0 then 1
        else ((cast(number_of_active_users as double)/number_of_d7_active_user) - 1)
    end as active_users_7d_pct_change,
    case
        when number_of_d30_active_user =0 and number_of_active_users=0 then 0
        when number_of_d30_active_user =0 then 1
        else ((cast(number_of_active_users as double)/number_of_d30_active_user) - 1)
    end as active_users_30d_pct_change,
    case
        when number_of_d180_active_user =0 and number_of_active_users=0 then 0
        when number_of_d180_active_user =0 then 1
        else ((cast(number_of_active_users as double)/number_of_d180_active_user) - 1)
    end as active_users_180d_pct_change,
    case
        when number_of_d360_active_user =0 and number_of_active_users=0 then 0
        when number_of_d360_active_user =0 then 1
        else ((cast(number_of_active_users as double)/number_of_d360_active_user) - 1 )
    end as active_users_360d_pct_change,
    volume.volume as volume,
    tx.number_of_transactions as number_of_transactions
from
(
    -- 当天 number_of_total_users 计算逻辑：拿近360天的 number_of_new_users 的总和，加上前第361天的 number_of_total_users
    select
        on_date,
        protocol_slug as protocol_slug,
        protocol_name as protocol_name,
        chain as chain,
        number_of_active_users,
        number_of_new_users,
        coalesce(last_number_of_total_users + number_of_total_users, 0) as number_of_total_users,
        number_of_d1_active_user,
        number_of_d7_active_user,
        number_of_d30_active_user,
        number_of_d180_active_user,
        number_of_d360_active_user,
        number_of_d1_new_user,
        number_of_d7_new_user,
        number_of_d30_new_user,
        number_of_d180_new_user,
        number_of_d360_new_user
    from daily_stats
) t1
left join volume_daily_stats volume
on
   t1.on_date = volume.on_date and t1.chain = volume.chain and t1.protocol_slug = volume.protocol_slug
left join transactions_daily_stats tx
on
   t1.on_date = tx.on_date and t1.chain = tx.chain and t1.protocol_slug = tx.protocol_slug
where number_of_total_users != 0
{% if var('start_time', none) is not none and var('end_time',none) is not none %}
    and t1.on_date >=  date '{{var("start_time")}}'
{% else %}
    and t1.on_date >= date_add('day', -2, current_date)
{% endif %}

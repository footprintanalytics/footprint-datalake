{%- macro basic_generate_protocol_transactions(chain_lower, chain_value) -%}

with distinct_protocol_info as
(
    select distinct
        chain,
        protocol_slug,
        protocol_name
    from iceberg.prod_silver.protocol_info
    where chain = '{{chain_value}}'
    and protocol_type = 'GameFi'
    {% if var('protocol_slug', none) is not none %}
        and protocol_slug in ('{{var("protocol_slug")| join("','")}}')
    {% endif%}
),
contract_info as
(
    select
        chain,
        protocol_slug,
        contract_address
    from iceberg.prod_silver.contract_info
    where chain = '{{chain_value}}'
    {% if var('protocol_slug', none) is not none %}
        and protocol_slug in ('{{var("protocol_slug")| join("','")}}')
    {% endif%}
),
protocol_contract_info as
(
    select
        t1.chain,
        t1.protocol_slug,
        lower(t1.contract_address) as contract_address,
        t2.protocol_name
    from contract_info t1
    inner join distinct_protocol_info t2 on t1.protocol_slug = t2.protocol_slug and t1.chain = t2.chain
    where t1.protocol_slug is not null
),
basic_crypto_transactions_temp as
(
select '{{chain_value}}' as chain, block_timestamp, from_address, to_address, receipt_contract_address, "input", "hash", "value", receipt_gas_used, gas_price, receipt_status
from "iceberg"."prod_bronze"."{{chain_lower}}_transactions"
where receipt_status = 1
{% if var('is_increment', True) %}
    {% if var('start_time', none) is not none and var('end_time',none) is not none %}
        and block_timestamp >= timestamp '{{var("start_time")}}'  and block_timestamp < timestamp '{{var("end_time")}}'
    {% else %}
        and block_timestamp >= date_add('day', -1, current_date) and block_timestamp < current_date
    {% endif %}
{% else %}
    and block_timestamp < current_date
{% endif %}
),
basic_protocol_chain_data as
(
    select
        chain,
        block_timestamp,
        from_address,
        coalesce(to_address, receipt_contract_address) as to_address,
        substr("input", 1, 10) as "data",
        "hash" as tx_hash,
        cast(cast("value" as varchar) as double) as "value",
        cast(receipt_gas_used as double) as gas,
        cast(gas_price as double) as gas_price
    from basic_crypto_transactions_temp
),
user_indicator_ignore_methods as
(
    select *
    from {{source('prod_origin_data','user_indicator_ignore_methods')}}
),
basic_protocol_transactions_temp as
(
    select
        t1.chain,
        t1.protocol_name,
        t1.protocol_slug,
        t1.contract_address as contract_address,
        t2.from_address as wallet_address,
        t2.block_timestamp as block_timestamp,
        t2."data" as contract_method_id,
        t2.tx_hash as transaction_hash,
        t2."value" as amount_raw
    from protocol_contract_info t1
    left join basic_protocol_chain_data t2 on t1.contract_address = t2.to_address
        and t1.chain = t2.chain
    where t2.block_timestamp is not null
        and t2."data" not in (select distinct method_id from user_indicator_ignore_methods)
    group by 1, 2, 3, 4, 5, 6, 7, 8, 9
)
select
    block_timestamp,
    transaction_hash,
    protocol_slug,
    chain,
    protocol_name,
    contract_address,
    wallet_address,
    contract_method_id,
    contract_method_id as contract_method_name,
    amount_raw,
    amount_raw / power(10,18) as amount
from basic_protocol_transactions_temp

{%- endmacro -%}
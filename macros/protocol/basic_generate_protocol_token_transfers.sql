{%- macro basic_generate_protocol_token_transfers(chain_lower, chain_value) -%}

with distinct_protocol_info as
(
    select
        chain,
        protocol_slug,
        protocol_name,
        protocol_type
    from iceberg.prod_silver.protocol_info
    where chain = '{{chain_value}}'
    and protocol_type = 'GameFi'
    {% if var('protocol_slug', none) is not none %}
        and protocol_slug in ('{{var("protocol_slug")| join("','")}}')
    {% endif%}
    group by 1,2,3,4
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
token_price as (
    select
        *
    from  {{source('prod_silver','token_price_5min')}}
    where chain = '{{chain_value}}'
    {% if var('start_time', none) is not none and var('end_time',none) is not none %}
        and timestamp >= timestamp '{{var("start_time")}}'  and timestamp < timestamp '{{var("end_time")}}'
    {% else %}
        and timestamp >= date_add('day', -1, current_date) and timestamp < current_date
    {% endif %}
),
protocol_contract_info as
(
    select
        t1.chain,
        t1.protocol_slug,
        lower(t1.contract_address) as contract_address,
        t2.protocol_name,
        t2.protocol_type
    from contract_info t1
    inner join distinct_protocol_info t2
    on t1.protocol_slug = t2.protocol_slug and t1.chain = t2.chain
    where t1.protocol_slug is not null
),
protocol_contract_token_info as (
    select
        protocol.chain as chain,
        protocol.protocol_slug as protocol_slug,
        protocol.contract_address as contract_address,
        protocol.protocol_name as protocol_name,
        token_info.token_symbol as token_symbol,
        token_info.decimals as decimals,
        token_info.token_address as token_address,
        protocol.protocol_type as protocol_type
    from
        protocol_contract_info protocol
    inner join
        iceberg.prod_silver.token_info token_info
    on
        protocol.protocol_slug = token_info.protocol_slug
    and
        protocol.chain = token_info.chain
),
basic_crypto_transactions_temp as
(
select
    '{{chain_value}}' as chain,
    block_timestamp,
    transaction_hash,
    from_address,
    to_address,
    token_address,
    amount_raw
from "iceberg"."prod_bronze"."{{chain_lower}}_token_transfers"
where
    (
        from_address != '0x0000000000000000000000000000000000000000'
        or
        to_address != '0x0000000000000000000000000000000000000000'
    )
{% if var('start_time', none) is not none and var('end_time',none) is not none %}
    and block_timestamp >= timestamp '{{var("start_time")}}'  and block_timestamp < timestamp '{{var("end_time")}}'
{% else %}
    and block_timestamp >= date_add('day', -1, current_date) and block_timestamp < current_date
{% endif %}
),
inflow_basic_protocol_chain_data as
(
    select
        temp.chain as chain,
        temp.block_timestamp as block_timestamp,
        temp.transaction_hash as transaction_hash,
        temp.from_address as wallet_address,
        temp.to_address as contract_address,
        temp.token_address as token_address,
        protocol_data.protocol_slug as protocol_slug,
        protocol_data.token_symbol as token_symbol,
        protocol_data.decimals as decimals,
        'in' as type,
        protocol_data.protocol_type as protocol_type,
        sum(temp.amount_raw/power(10, protocol_data.decimals)) as amount
    from basic_crypto_transactions_temp temp
    inner join protocol_contract_token_info protocol_data
    on temp.to_address = protocol_data.contract_address
    and temp.token_address = protocol_data.token_address
    group by 1,2,3,4,5,6,7,8,9,10,11
),
outflow_basic_protocol_chain_data as
(
    select
        temp.chain as chain,
        temp.block_timestamp as block_timestamp,
        temp.transaction_hash as transaction_hash,
        temp.from_address as contract_address,
        temp.to_address as wallet_address,
        temp.token_address as token_address,
        protocol_data.protocol_slug as protocol_slug,
        protocol_data.token_symbol as token_symbol,
        protocol_data.decimals as decimals,
        'out' as type,
        protocol_data.protocol_type as protocol_type,
        sum(temp.amount_raw/power(10, protocol_data.decimals)) as amount
    from basic_crypto_transactions_temp temp
    inner join protocol_contract_token_info protocol_data
    on temp.from_address = protocol_data.contract_address
    and temp.token_address = protocol_data.token_address
    group by 1,2,3,4,5,6,7,8,9,10,11
),
basic_protocol_transfers_temp as
(
    select
        protocol_transactions.chain,
        protocol_transactions.block_timestamp,
        protocol_transactions.transaction_hash,
        protocol_transactions.wallet_address,
        protocol_transactions.contract_address,
        protocol_transactions.token_address,
        protocol_transactions.protocol_slug,
        protocol_transactions.token_symbol,
        protocol_transactions.decimals,
        protocol_transactions.type,
        protocol_transactions.protocol_type,
        protocol_transactions.amount,
        protocol_transactions.amount * price.price as value
    from (
        select chain, block_timestamp, transaction_hash, wallet_address, contract_address, token_address, protocol_slug, token_symbol, decimals, type, protocol_type, amount from inflow_basic_protocol_chain_data
        union all
        select chain, block_timestamp, transaction_hash, wallet_address, contract_address, token_address, protocol_slug, token_symbol, decimals, type, protocol_type, amount from outflow_basic_protocol_chain_data
    ) protocol_transactions
    left join token_price price
    on protocol_transactions.token_address = price.token_address
    and price.timestamp = from_unixtime(floor(to_unixtime(protocol_transactions.block_timestamp)/300) * 300)
)
select
    chain,
    block_timestamp,
    transaction_hash,
    wallet_address,
    contract_address,
    token_address,
    protocol_slug,
    token_symbol,
    decimals,
    type,
    protocol_type,
    amount,
    value
from
    basic_protocol_transfers_temp
where wallet_address != '0x0000000000000000000000000000000000000000'
{%- endmacro -%}
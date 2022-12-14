with
transfers as (
    select
        eai.entity_slug
        ,eai.entity_name
        ,atb.block_timestamp
        ,atb.chain
        ,atb.wallet_address
        ,atb.token_address
        ,atb.value
    from {{source('footprint', 'address_token_balance')}} atb
    inner join
    {{source('footprint', 'entity_address_info')}} eai
    on atb.wallet_address = eai.wallet_address
    and atb.chain = eai.chain
    where atb.block_timestamp > date_add('day', -30, current_timestamp)
),
daily_wallet_balance as (
    select
        Date(block_timestamp) as on_date
        ,entity_slug
        ,entity_name
        ,chain
        ,wallet_address
        ,token_address
        ,first_value(value) over (order by block_timestamp desc) as balance
    from transfers
    group by Date(block_timestamp), entity_slug, entity_name, chain, wallet_address, token_address
),
daily_balance as (
    select
        on_date
        ,entity_slug
        ,entity_name
        ,sum(balance) as balance
    from daily_wallet_balance
    group by on_date, entity_slug, entity_name
    order by on_date
)
select * from daily_balance
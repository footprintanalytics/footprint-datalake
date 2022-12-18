{% macro in_out_flow(chain='ethereum', token_address='', block_timestamp=none) -%}
token_transfers as (
    select
        tt.from_address
        ,tt.to_address
        ,tt.amount_raw / power(10, coalesce(ti.decimals, 18)) as amount
        ,ti.token_slug
        ,tt.block_timestamp
    from footprint.{{chain}}_token_transfers tt
    left join
    footprint.token_info ti
    on tt.token_address = ti.token_address
    where 1=1
    and tt.token_address = lower('{{token_address}}')
    and ti.chain = '{{chain.capitalize()}}'
    {% if block_timestamp %}
    and block_timestamp <= timestamp '{{block_timestamp}}'
    {% endif %}
),
outflow as (
    select
        block_timestamp
        ,from_address as wallet_address
        ,token_slug
        ,-amount as amount
    from token_transfers
),
inflow as (
    select
        block_timestamp
        ,to_address as wallet_address
        ,token_slug
        ,amount as amount
    from token_transfers
),
union_flow as (
    select * from outflow
    union all
    select * from inflow
),
{%- endmacro %}

{% macro token_balance(chain='ethereum', token_address='', block_timestamp=none) -%}
{{in_out_flow(chain=chain, token_address=token_address,block_timestamp=block_timestamp)}}
token_balance as (
    select
        wallet_address
        ,sum(amount) as amount
    from union_flow
    group by wallet_address
    order by amount desc
)
{%- endmacro %}

{% macro daily_total_supply(chain='ethereum', token_address='', block_timestamp=none) -%}
mints as (
    select
        tt.amount_raw / power(10, coalesce(ti.decimals, 18)) as amount
        ,ti.token_slug
        ,tt.block_timestamp
    from footprint.{{chain}}_token_transfers tt
    left join
    footprint.token_info ti
    on tt.token_address = ti.token_address
    where 1=1
    and tt.from_address = '0x0000000000000000000000000000000000000000'
    and tt.token_address = lower('{{token_address}}')
    and ti.chain = '{{chain.capitalize()}}'
    {% if block_timestamp %}
    and block_timestamp <= timestamp '{{block_timestamp}}'
    {% endif %}
),
daily_total_supply as (
    select
        Date(block_timestamp) as on_date
        ,sum(amount) as daily_supply
        ,sum(sum(amount)) over (order by Date(block_timestamp)) as total_supply
    from mints
    group by 1
    order by 1
)
{%- endmacro %}

{% macro daily_address_balance(chain='ethereum', token_address='', wallet_address = '', block_timestamp=none) -%}
token_transfers as (
    select
        case when tt.from_address = lower('{{wallet_address}}') then -tt.amount_raw / power(10, coalesce(ti.decimals, 18))
            else tt.amount_raw / power(10, coalesce(ti.decimals, 18)) end as amount
        ,ti.token_slug
        ,tt.block_timestamp
    from footprint.{{chain}}_token_transfers tt
    left join
    footprint.token_info ti
    on tt.token_address = ti.token_address
    where 1=1
    and (tt.from_address = lower('{{wallet_address}}') or tt.to_address = lower('{{wallet_address}}')
    and tt.token_address = lower('{{token_address}}')
    and ti.chain = '{{chain.capitalize()}}'
    {% if block_timestamp %}
    and block_timestamp <= timestamp '{{block_timestamp}}'
    {% endif %}
),
daily_balance as (
    select
        Date(block_timestamp) as on_date
        ,sum(amount) as dail_net_flow
        ,sum(sum(amount)) over (order by Date(block_timestamp)) as daily_balance
    from token_transfers
    group by 1
    order by 1
)
{%- endmacro %}


{% macro daily_token_holders(chain='ethereum', token_address='', first_date='2015-07-30', block_timestamp=none) -%}
{{in_out_flow(chain=chain, token_address=token_address, block_timestamp=none)}}
double_entry_book_grouped_by_date as (
    select wallet_address, token_slug, sum(amount) as balance, Date(block_timestamp) as on_date
    from union_flow
    group by wallet_address, token_slug, Date(block_timestamp)
),
daily_balances_with_gaps as (
    select
        wallet_address,
        token_slug,
        on_date,
        sum(balance) over (partition by wallet_address, token_slug order by on_date)            as balance,
        lead(on_date, 1, current_date) over (partition by wallet_address, token_slug order by on_date) as next_date
    from double_entry_book_grouped_by_date
),
calendar AS (
    select on_date from unnest(sequence(FROM_ISO8601_DATE('{{first_date}}'), current_date, interval '1' day)) t(on_date)
),
daily_holder_balance as (
    select wallet_address, token_slug, calendar.on_date, balance
    from daily_balances_with_gaps dbwg
    right join calendar
    on dbwg.on_date <= calendar.on_date
    and calendar.on_date < dbwg.next_date
    and dbwg.balance > 0
    order by calendar.on_date asc, dbwg.balance desc
)
{%- endmacro %}
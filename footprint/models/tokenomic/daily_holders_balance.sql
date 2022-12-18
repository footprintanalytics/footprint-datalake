{% set first_date='2021-07-21' %}

with
{{daily_token_holders(chain='arbitrum', token_address='0xfc5a1a6eb076a2c7ad06ed22c90d7e710e35ad0a',first_date=first_date, block_timestamp=none)}}
,
today_top_ten as (
    select
        wallet_address
    from daily_holder_balance
    where on_date = (select max(on_date) - interval '1' day from daily_holder_balance)
    order by balance desc
    limit 10
),
top_ten_holder_balance as (
    select
        on_date
        ,wallet_address
        ,token_slug
        ,sum(balance) as balance
    from (
        select
            dhb.on_date
            ,dhb.token_slug
            ,dhb.balance
            ,coalesce(ttt.wallet_address, 'others') as wallet_address
        from daily_holder_balance dhb
        left join
        today_top_ten ttt
        on dhb.wallet_address = ttt.wallet_address
    )
    group by on_date, wallet_address, token_slug
    order by on_date asc, balance desc
),
date_list as (
    select on_date from unnest(sequence(FROM_ISO8601_DATE('2021-07-21'), current_date, interval '1' month)) t(on_date)
    union all
    select (max(on_date) - interval '1' day) as on_date from daily_holder_balance
)
select * from top_ten_holder_balance tthb
inner join
date_list dl
on tthb.on_date = dl.on_date
order by dl.on_date asc, tthb.balance desc
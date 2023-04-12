{% test test_solana_account_mapping(model, days=1) %}
with rank_time as (
  select
    token_account,
    hold_start_time,
    hold_end_time,
    row_number() over (partition by token_account order by hold_start_time) as rank_id
  from {{model}}
  where hold_start_time >= date_add('day', {{ days }}, current_date)
  or hold_end_time >= date_add('day', {{ days }}, current_date)
)

select
rt1.token_account,
rt1.hold_start_time as start_time_1,
rt1.hold_end_time as end_time_1,
rt2.hold_start_time as start_time_2
from rank_time rt1
left join rank_time rt2
on
rt1.token_account = rt2.token_account
and
rt2.rank_id = rt1.rank_id + 1
where
rt2.hold_start_time < rt1.hold_end_time
or
rt2.hold_start_time <= rt1.hold_start_time

{% endtest %}
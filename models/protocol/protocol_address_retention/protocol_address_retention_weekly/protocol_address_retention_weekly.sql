{{config(
    materialized='incremental',
    unique_key=['cohort','chain','protocol_slug'],
    incremental_strategy='merge'
)}}
{#'注意： 刷数据时间只能从前往后刷（从过去时间往现在时间刷），不能从后往前刷，不然数据会有问题'#}
with protocol_active_address as (
    select * from {{source('prod_gold', 'protocol_active_address')}}
    where
    {% if var('end_time', none) is not none %}
          on_date >= (date_add('day', -84, date_trunc('week', date '{{var("end_time")}}') )) AND on_date < date_trunc('week', date '{{var("end_time")}}')
    {% else %}
          on_date >= date_add('day', -84, date_trunc('week', current_date)) and on_date < date_trunc('week', current_date)
    {% endif %}
    {% if var('protocol_slug', none) is not none %}
        and protocol_slug in ('{{var("protocol_slug")|join("','")}}')
    {% endif%}
    {% if var('chain_values', none) is not none %}
        and "chain" in ('{{var("chain_values")|join("','")}}')
    {% endif%}
),
new_address_with_min_date as (
select ord.on_date,(case when new_add.chain = 'BSC' then 'BNB Chain' else new_add.chain end) as chain,
new_add.protocol_slug,new_add.wallet_address,new_add.min_day,
first_value(protocol_name) over (partition by new_add.protocol_slug order by new_add.min_day desc) as protocol_name,
date_trunc('week', (ord.on_date)) as order_cohort, date_trunc('week', (new_add.min_day)) as acquisition_cohort,
date_diff('day', (date_trunc('week', (new_add.min_day))), date_trunc('week', (ord.on_date)) ) / 7 as period_number
   from
   (select on_date as min_day,chain,protocol_slug,wallet_address,is_new_address, protocol_name from protocol_active_address where
    {% if var('end_time', none) is not none %}
          on_date >= (date_add('day', -84, date_trunc('week', date '{{var("end_time")}}') )) AND on_date <= date_trunc('week', date '{{var("end_time")}}')
    {% else %}
          on_date >= date_add('day', -84, date_trunc('week', current_date)) and on_date < date_trunc('week', current_date)
    {% endif %}
   and is_new_address = True) as new_add
   inner join
   (select on_date,wallet_address,protocol_slug,chain from protocol_active_address where
    {% if var('end_time', none) is not none %}
          on_date >= (date_add('day', -84, date_trunc('week', date '{{var("end_time")}}') )) AND on_date <= date_trunc('week', date '{{var("end_time")}}')
    {% else %}
          on_date >= date_add('day', -84, date_trunc('week', current_date)) and on_date < date_trunc('week', current_date)
    {% endif %}
   ) as ord
   on new_add.chain =ord.chain and new_add.protocol_slug = ord.protocol_slug and new_add.wallet_address = ord.wallet_address
),
retention_group as (select acquisition_cohort, order_cohort, protocol_slug, chain, protocol_name,period_number,
count(distinct wallet_address) as wallet_address, acquisition_cohort as start_date
from new_address_with_min_date
group by acquisition_cohort, order_cohort, protocol_slug, chain, protocol_name,period_number
),
add_weeks_columns as (select protocol_slug, chain, protocol_name,start_date,
date_add('day', 6, start_date) as end_date,
max(case when period_number=0 then wallet_address end) as week_1,
max(case when period_number=1 then wallet_address end) as week_2,
max(case when period_number=2 then wallet_address end) as week_3,
max(case when period_number=3 then wallet_address end) as week_4,
max(case when period_number=4 then wallet_address end) as week_5,
max(case when period_number=5 then wallet_address end) as week_6,
max(case when period_number=6 then wallet_address end) as week_7,
max(case when period_number=7 then wallet_address end) as week_8,
max(case when period_number=8 then wallet_address end) as week_9,
max(case when period_number=9 then wallet_address end) as week_10,
max(case when period_number=10 then wallet_address end) as week_11,
max(case when period_number=11 then wallet_address end) as week_12
from retention_group
group by protocol_slug, chain, protocol_name,start_date
)
select concat(date_format(start_date, '%Y-%m-%d'),' ~ ',date_format(end_date, '%Y-%m-%d')) as cohort, protocol_slug, chain, protocol_name, number_of_new_users,
coalesce(week_1/number_of_new_users,0) as week_1,
coalesce(week_2/number_of_new_users,if(date_add('day', 2*7, start_date)<current_date,0,null)) as week_2,
coalesce(week_3/number_of_new_users,if(date_add('day', 3*7, start_date)<current_date,0,null)) as week_3,
coalesce(week_4/number_of_new_users,if(date_add('day', 4*7, start_date)<current_date,0,null)) as week_4,
coalesce(week_5/number_of_new_users,if(date_add('day', 5*7, start_date)<current_date,0,null)) as week_5,
coalesce(week_6/number_of_new_users,if(date_add('day', 6*7, start_date)<current_date,0,null)) as week_6,
coalesce(week_7/number_of_new_users,if(date_add('day', 7*7, start_date)<current_date,0,null)) as week_7,
coalesce(week_8/number_of_new_users,if(date_add('day', 8*7, start_date)<current_date,0,null)) as week_8,
coalesce(week_9/number_of_new_users,if(date_add('day', 9*7, start_date)<current_date,0,null)) as week_9,
coalesce(week_10/number_of_new_users,if(date_add('day', 10*7, start_date)<current_date,0,null)) as week_10,
coalesce(week_11/number_of_new_users,if(date_add('day', 11*7, start_date)<current_date,0,null)) as week_11,
coalesce(week_12/number_of_new_users,if(date_add('day', 12*7, start_date)<current_date,0,null)) as week_12,
start_date,
end_date
from (select *, week_1*1.0000 as number_of_new_users from add_weeks_columns)t
order by cohort
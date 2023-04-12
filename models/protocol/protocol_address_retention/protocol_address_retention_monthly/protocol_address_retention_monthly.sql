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
          on_date >= (date_add('month', -12, date_trunc('month', date '{{var("end_time")}}') )) AND on_date < date_trunc('month', date '{{var("end_time")}}')
    {% else %}
          on_date >= date_add('month', -12, date_trunc('month', current_date)) and on_date < date_trunc('month', current_date)
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
date_trunc('month', (ord.on_date)) as order_cohort, date_trunc('month', (new_add.min_day)) as acquisition_cohort,
date_diff('month', (date_trunc('month', (new_add.min_day))), date_trunc('month', (ord.on_date)) )  as period_number
   from
   (select on_date as min_day,chain,protocol_slug,wallet_address,is_new_address, protocol_name from protocol_active_address where
    {% if var('end_time', none) is not none %}
          on_date >= (date_add('month', -12, date_trunc('month', date '{{var("end_time")}}') )) AND on_date <= date_trunc('month', date '{{var("end_time")}}')
    {% else %}
          on_date >= date_add('month', -12, date_trunc('month', current_date)) and on_date < date_trunc('month', current_date)
    {% endif %}
   and is_new_address = True) as new_add
   inner join
   (select on_date,wallet_address,protocol_slug,chain from protocol_active_address where
    {% if var('end_time', none) is not none %}
          on_date >= (date_add('month', -12, date_trunc('month', date '{{var("end_time")}}') )) AND on_date <= date_trunc('month', date '{{var("end_time")}}')
    {% else %}
          on_date >= date_add('month', -12, date_trunc('month', current_date)) and on_date < date_trunc('month', current_date)
    {% endif %}
   ) as ord
   on new_add.chain =ord.chain and new_add.protocol_slug = ord.protocol_slug and new_add.wallet_address = ord.wallet_address
),
retention_group as (select acquisition_cohort, order_cohort, protocol_slug, chain, protocol_name,period_number,
count(distinct wallet_address) as wallet_address, acquisition_cohort as start_date
from new_address_with_min_date
group by acquisition_cohort, order_cohort, protocol_slug, chain, protocol_name,period_number
),
add_months_columns as (select protocol_slug, chain, protocol_name,start_date,
date_add('day', -1, date_add('month', 1, start_date)) as end_date,
max(case when period_number=0 then wallet_address end) as month_1,
max(case when period_number=1 then wallet_address end) as month_2,
max(case when period_number=2 then wallet_address end) as month_3,
max(case when period_number=3 then wallet_address end) as month_4,
max(case when period_number=4 then wallet_address end) as month_5,
max(case when period_number=5 then wallet_address end) as month_6,
max(case when period_number=6 then wallet_address end) as month_7,
max(case when period_number=7 then wallet_address end) as month_8,
max(case when period_number=8 then wallet_address end) as month_9,
max(case when period_number=9 then wallet_address end) as month_10,
max(case when period_number=10 then wallet_address end) as month_11,
max(case when period_number=11 then wallet_address end) as month_12
from retention_group
group by protocol_slug, chain, protocol_name,start_date
)
select date_format(start_date, '%Y-%m-%d')as cohort, protocol_slug, chain, protocol_name, number_of_new_users,
coalesce(month_1/number_of_new_users,0) as month_1,
coalesce(month_2/number_of_new_users,if(date_add('month', 2, start_date)<current_date,0,null)) as month_2,
coalesce(month_3/number_of_new_users,if(date_add('month', 3, start_date)<current_date,0,null)) as month_3,
coalesce(month_4/number_of_new_users,if(date_add('month', 4, start_date)<current_date,0,null)) as month_4,
coalesce(month_5/number_of_new_users,if(date_add('month', 5, start_date)<current_date,0,null)) as month_5,
coalesce(month_6/number_of_new_users,if(date_add('month', 6, start_date)<current_date,0,null)) as month_6,
coalesce(month_7/number_of_new_users,if(date_add('month', 7, start_date)<current_date,0,null)) as month_7,
coalesce(month_8/number_of_new_users,if(date_add('month', 8, start_date)<current_date,0,null)) as month_8,
coalesce(month_9/number_of_new_users,if(date_add('month', 9, start_date)<current_date,0,null)) as month_9,
coalesce(month_10/number_of_new_users,if(date_add('month', 10, start_date)<current_date,0,null)) as month_10,
coalesce(month_11/number_of_new_users,if(date_add('month', 11, start_date)<current_date,0,null)) as month_11,
coalesce(month_12/number_of_new_users,if(date_add('month', 12, start_date)<current_date,0,null)) as month_12,
start_date,
end_date
from (select *, month_1*1.0000 as number_of_new_users from add_months_columns)t
order by cohort
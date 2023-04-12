{% test business_associated_where(model,column_name,right_table_name, check_fields, foreign_condition, left_table_condition="1=1", right_table_condition="1=1") %}

with left_table as (

  select
    *
  from {{model}}

  where {{left_table_condition}}

),

right_table as (

  select
    *
  from {{right_table_name}}

  where {{right_table_condition}}

),
exceptions as (

  select
    *
  from left_table

  left join right_table
         on {{foreign_condition}}

  where right_table.{{check_fields}} is null

)

select * from exceptions

{% endtest %}

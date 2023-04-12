{% test not_null_associated_with(model,column_name,right_table_name, foreign_condition, left_table_condition="1=1", right_table_condition="1=1") %}

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
    left_table.*
  from left_table

  inner join right_table
         on {{foreign_condition}}

  where left_table.{{column_name}} is null


)

select * from exceptions

{% endtest %}

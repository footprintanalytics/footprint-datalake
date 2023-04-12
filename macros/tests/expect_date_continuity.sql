{% test expect_date_continuity(model, column_name, continuity_of_columns, datepart= 'day') %}

with group_table as (
	select date({{column_name}}) as last_day, {{continuity_of_columns}}
	from {{model}}
	group by date({{column_name}}), {{continuity_of_columns}}
),
group_by_date as (
	select
		*,
		lead(last_day, 1, current_date) OVER(partition by {{continuity_of_columns}} ORDER BY last_day) as next_day
	from group_table
)
select *
from group_by_date
where date_diff('{{datepart}}', last_day, next_day) > 1

{% endtest %}

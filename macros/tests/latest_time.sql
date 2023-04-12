-- Example:
-- tests:
--   - latest_time:
--       date_col: block_timestamp
--       value: 3
--       unit: minute | hour | day
--       columns:
--         - chain

{% test latest_time(model, date_col, value, unit, columns) %}

{% set column_list = [] %}
{% for column in columns -%}
{% set column_list = column_list.append(adapter.quote(column)) %}
{% endfor %}
{% set columns_csv = column_list | join('`, `') %}

select * from (
  select *,
  case when latest >= datetime_sub(datetime_trunc(current_datetime, {{unit}}), interval {{value}} {{unit}})
  then 1 else 0 end as result
  from (
    select datetime(max({{date_col}})) as latest
    {% if column_list | length > 0 %}
    ,{{columns_csv}}
    {% endif %}
    from {{model}}
    {% if column_list | length > 0 %}
    group by {{columns_csv}}
    {% endif %}
  )
) where result = 0

{% endtest %}

{% test latest_time_after_yesterday_by_columns(model, date_col, columns) %}

{%- set column_list=[] %}
    {% for column in columns -%}
        {% set column_list = column_list.append( adapter.quote(column) ) %}
{%- endfor %}

{%- set columns_csv=column_list | join(', ') %}


select * from (
    select
    *,
    case when max_date >= current_date - interval '1' day then 1 else 0 end as result
    from (
        select Date(max({{ date_col }})) as max_date
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

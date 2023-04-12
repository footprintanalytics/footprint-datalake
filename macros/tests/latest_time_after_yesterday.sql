{% test latest_time_after_yesterday(model, column_name) %}

select * from (
    select
    case when max_date >= current_date - interval '1' day then 1 else 0 end as result
    from (
        select Date(max({{ column_name }})) as max_date from {{model}}
    )
) where result = 0

{% endtest %}

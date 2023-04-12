{% test expect_not_null_cloumn_in_value_range(model, column_name, _filter) %}

select * from {{model}} where {{ column_name }} is not null and not({{_filter}})

{% endtest %}
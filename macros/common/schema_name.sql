{% macro bronze_schema() -%}
    {% if target.name == 'prod' %}iceberg.prod_bronze
    {% else %}iceberg.beta_bronze
    {% endif %}
{%- endmacro %}

{% macro silver_schema() -%}
    {% if target.name == 'prod' %}iceberg.prod_silver
    {% else %}iceberg.beta_silver
    {% endif %}
{%- endmacro %}

{% macro gold_schema() -%}
    {% if target.name == 'prod' %}iceberg.prod_gold
    {% else %}iceberg.beta_gold
    {% endif %}
{%- endmacro %}
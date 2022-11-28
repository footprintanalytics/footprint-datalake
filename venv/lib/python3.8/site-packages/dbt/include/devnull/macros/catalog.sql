
{% macro devnull__get_catalog(information_schema, schemas) -%}

  {% set msg -%}
    get_catalog not implemented for devnull
  {%- endset %}

  {{ exceptions.raise_compiler_error(msg) }}
{% endmacro %}

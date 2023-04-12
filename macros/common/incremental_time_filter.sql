{% macro incremental_timestamp_filter(time_field_name='block_timestamp',need_full=none) -%}
    WHERE
    {{time_field_name}} < current_date
    {% if target.name == 'prod' %}
        {% if is_incremental()  %}
         AND {{time_field_name}} >= date_add('day', -1, current_date)
        {% else %}
            {% if need_full == none %}
             AND {{time_field_name}} >= date_add('day', -90, current_date)
            {% endif %}
        {% endif %}
    {% else %}
        {% if is_incremental()  %}
         AND {{time_field_name}} >= date_add('day', -1, current_date)
        {% else %}
            {% if need_full == none %}
             AND {{time_field_name}} >= date_add('day', -1, current_date)
            {% endif %}
        {% endif %}
    {% endif %}

{%- endmacro %}

{% macro incremental_timestamp_filter_realtime(time_field_name='block_timestamp',need_full=none) -%}
    WHERE
    TRUE
    {% if target.name == 'prod' %}
        {% if is_incremental()  %}
         AND {{time_field_name}} >= date_add('day', -1, current_date)
        {% else %}
            {% if need_full == none %}
              AND  {{time_field_name}} >= date_add('day', -90, current_date)
            {% endif %}
        {% endif %}
    {% else %}
        {% if is_incremental()  %}
         AND {{time_field_name}} >= date_add('day', -1, current_date)
        {% else %}
            {% if need_full == none %}
            AND {{time_field_name}} >= date_add('day', -1, current_date)
            {% endif %}
        {% endif %}
    {% endif %}

{%- endmacro %}

{%- macro call_statement_start_time(start_time) -%}

{%- call statement('get_start_time', fetch_result=True) -%}
    {% if start_time is none %}
        select cast(date_format(localtimestamp - interval '24' hour,'%Y-%m-%d') as timestamp)
    {% else %}
        select timestamp '{{start_time}}'
    {% endif %}
{%- endcall -%}

{%- endmacro -%}


{%- macro call_statement_end_time(end_time) -%}

{%- call statement('get_end_time', fetch_result=True) -%}
    {% if end_time is none %}
        select cast(date_format(localtimestamp,'%Y-%m-%d %H:%i:%s') as timestamp)
    {% else %}
        select timestamp '{{end_time}}'
    {% endif %}
{%- endcall -%}

{%- endmacro -%}
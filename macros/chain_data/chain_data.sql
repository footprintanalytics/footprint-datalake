{%- macro chain_data(source_project, source_dataset, source_table, target_table, start_time=none, end_time=none, time_field_name='block_timestamp') -%}

{% if target.name == 'prod' %}
    {% set data_async_situation_table = "mongodb.footprint_etl.data_async_situation" %}
    {% set target_schema = "prod_bronze" %}
{% else %}
    {% set data_async_situation_table = "mongodb.footprint_etl.data_async_situation_beta" %}
    {% set target_schema = "beta_bronze" %}
{% endif %}

{% set table_name = 'iceberg' + '.' + target_schema + '.' + target_table %}
{% set is_incremental_refresh = false %}

{% if is_incremental() %}
    {% if start_time is not none and end_time is not none %}
        {% set start_time = start_time %}
        {% set end_time = end_time %}
        {% set is_incremental_refresh = true %}
    {% else %}
        {% if target_table == 'ethereum_logs' or target_table == 'ethereum_token_transfers' or target_table == 'ethereum_transactions' %}
            {% set last_async_time = incremental_last_async_time(target_schema, target_table, data_async_situation_table) %}
            {% set start_time = last_async_time.strftime("%Y-%m-%d %H:%M:%S") %}
            {% set end_time = (modules.datetime.datetime.utcnow() - modules.datetime.timedelta(minutes=30)).strftime("%Y-%m-%d %H:%M:%S") %}
        {% elif target_table == 'oasys_logs' or target_table == 'oasys_token_transfers' or target_table == 'oasys_transactions' %}
            {% set last_update_time = incremental_last_update_time(target_schema, target_table, time_field_name, time_interval=-90) %}
            {% set start_time = last_update_time.strftime("%Y-%m-%d %H:%M:%S") %}
            {% set end_time = modules.datetime.datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S") %}
        {% elif target_table != 'solana_transactions' %}
            {% set last_update_time = incremental_last_update_time(target_schema, target_table, time_field_name) %}
            {% set start_time = last_update_time.strftime("%Y-%m-%d %H:%M:%S") %}
            {% set end_time = modules.datetime.datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S") %}
        {% else %}
            {% set last_update_time = incremental_last_update_time(target_schema, target_table, time_field_name) %}
            {% set start_time = last_update_time.strftime("%Y-%m-%d %H:%M:%S") %}
            {% set end_time = (last_update_time + modules.datetime.timedelta(hours=1)).strftime("%Y-%m-%d %H:%M:%S") %}
        {% endif %}
    {% endif %}
{% else %}
    {% set start_time = '2099-01-01 00:00:00' %}
    {% set end_time = modules.datetime.date.today().strftime("%Y-%m-%d %H:%M:%S") %}
{% endif %}

{%- call statement('delete', fetch_result=True) -%}
    delete from
       {{source(target_schema, target_table)}}
    where {{time_field_name}} >= timestamp '{{start_time}}' and {{time_field_name}} < timestamp '{{end_time}}'

{%- endcall -%}

{%- if execute -%}

    {%- call statement('insert', fetch_result=True) -%}

        insert into
            {{source(target_schema, target_table)}}
       select *
        {% if 'token_transfers' in target_table %}
        , try_cast (value as decimal(38,0) ) as amount_raw
        {% endif %}
        from "{{source_project}}".{{source_dataset}}.{{source_table}}
                where {{time_field_name}} >= timestamp '{{start_time}}'
                and {{time_field_name}} < timestamp '{{end_time}}'

    {%- endcall -%}

    {% if not is_incremental_refresh and (target_table == 'ethereum_logs' or target_table == 'ethereum_token_transfers' or target_table == 'ethereum_transactions') %}
        {{save_data_async_situation(target_table, start_time, end_time, time_field_name)}}
    {% endif %}


{% endif %}


{%- if execute -%}

select * from {{source(target_schema, target_table)}} where 1=0

{% endif %}

{%- endmacro -%}
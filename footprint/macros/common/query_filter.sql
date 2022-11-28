{% macro query_filter(time_filter_column='block_timestamp') -%}
    {% if var('protocol_slugs',none) is not none %}
        {% set protocol_slugs_sql = _field_filter('protocol_slug',var('protocol_slugs',none))%}
    {% endif %}

    {% if var('chains',none) is not none %}
        {% set chains_sql = _field_filter('chain',var('chains',none))%}
    {% endif %}

    {% if var('marketplace_slugs',none) is not none %}
        {% set marketplace_slugs_sql = _field_filter('marketplace_slug',var('marketplace_slugs',none))%}
    {% endif %}

    {% if var('collection_slugs',none) is not none %}
        {% set collection_slugs_sql = _field_filter('collection_slug',var('collection_slugs',none))%}
    {% endif %}

    {% if var('token_slugs',none) is not none %}
        {% set token_slugs_sql = _field_filter('token_slug',var('token_slugs',none))%}
    {% endif %}

    {% if var('token_addresses',none) is not none %}
        {% set token_addresses_sql = _field_filter('token_address',var('token_addresses',none))%}
    {% endif %}

    {% if var('contract_addresses',none) is not none %}
        {% set contract_addresses_sql = _field_filter('contract_address',var('contract_addresses',none))%}
    {% endif %}

    {% if var('collection_contract_addresses',none) is not none %}
        {% set collection_contract_addresses_sql = _field_filter('collection_contract_address',var('collection_contract_addresses',none))%}
    {% endif %}

    {% if var('transaction_hashes',none) is not none %}
        {% set transaction_hashes_sql = _field_filter('transaction_hash',var('transaction_hashes',none))%}
    {% endif %}

    {% if var('start_time',none) is not none %}
        {% set start_time_sql = time_filter_column + " >= timestamp '" + var('start_time',none)+ "'" %}
    {% endif %}

    {% if var('end_time',none) is not none %}
        {% set end_time_sql = time_filter_column + " < timestamp '" + var('end_time',none)+ "'" %}
    {% endif %}

    {% if var('start_time',none) is not none and var('end_time',none) is not none %}
        {% set start_end_time_sql = start_time_sql | default('true') + ' and ' +end_time_sql | default('true') %}
    {% else %}
        {% set start_end_time_sql = time_filter_column + ">= date_add('day', -1, current_date) and " + time_filter_column + "< current_date" %}
    {% endif %}


{% set yml_str %}

'protocol_slugs_sql': {{protocol_slugs_sql | default('true')}}
'chains_sql': {{chains_sql | default('true')}}
'marketplace_slugs_sql': {{marketplace_slugs_sql | default('true')}}
'token_slugs_sql': {{token_slugs_sql | default('true')}}
'token_addresses_sql': {{token_addresses_sql | default('true')}}
'contract_addresses_sql': {{contract_addresses_sql | default('true')}}
'collection_contract_addresses_sql': {{collection_contract_addresses_sql | default('true')}}
'transaction_hashes_sql': {{transaction_hashes_sql | default('true')}}
'start_time_sql': {{start_time_sql | default('true')}}
'end_time_sql': {{end_time_sql | default('true')}}
'start_end_time_sql': {{start_end_time_sql}}

{% endset %}
{{return(fromyaml(yml_str))}}
{%- endmacro %}

{% macro _field_filter(field_name, field_value) %}
    {% if  field_value is string  %}
        {{ return(field_name+" = '"+field_value+"' ") }}
    {% elif field_value is iterable and field_value is not mapping %}
        {{ return(field_name + " in ('"+field_value|join("','")+"') ") }}
    {% elif field_value is not mapping %}
        {{ return(field_name+" = "+field_value|string()) }}
    {% endif %}

{% endmacro%}

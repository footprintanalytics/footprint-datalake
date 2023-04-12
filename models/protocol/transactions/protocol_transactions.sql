{{config(
    materialized='incremental',
    unique_key=['chain','transaction_hash','protocol_slug','contract_address','wallet_address'],
    incremental_strategy='merge',
    properties={
        "partitioning": "ARRAY['day(block_timestamp)']",
        "sorted_by": "ARRAY['wallet_address']",
    }
)}}
{#
'【可选参数】'
'is_increment: 是否执行日增逻辑，默认True，如果需要刷全量，设置为False'
'protocol_slug: ["aave",...]'
'start_time: 开始时间'
'end_time: 结束时间'
#}

{% set defalut_chains = [
'ethereum'
]%}

{% for chain in var('chains', defalut_chains) %}
        {% if loop.index0 > 0 %}
        union all
        {% endif %}
        select * from {{ref(chain+'_protocol_transactions')}}

        {% if chain == 'solana' %}
            where 1=1
            {% if var('is_increment', True) %}
                {% if var('start_time', none) is not none and var('end_time',none) is not none %}
                    and block_timestamp >= timestamp '{{var("start_time")}}'  and block_timestamp < timestamp '{{var("end_time")}}'
                {% else %}
                    and block_timestamp >= date_add('day', -1, current_date) and block_timestamp < current_date
                {% endif %}
            {% else %}
                and block_timestamp < current_date
            {% endif %}
        {% endif %}
{% endfor %}

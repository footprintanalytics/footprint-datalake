{{config(
    materialized='incremental',
    unique_key=['chain','transaction_hash','protocol_slug','contract_address','wallet_address', 'token_address','type'],
    incremental_strategy='merge',
    properties={
        "partitioning": "ARRAY['day(block_timestamp)']",
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
        select * from {{ref(chain+'_protocol_token_transfers')}}
{% endfor %}

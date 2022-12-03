{% macro chain_daily_active_user(chain='ethereum', previous_days=30) -%}
    {{chain}}_active_user as (
        select
            Date(block_timestamp) as on_date
            ,'{{chain}}' as chain
            ,count(distinct from_address) as active_user
        from footprint.{{chain}}_transactions
        where 1=1
        and block_timestamp >= date_add('day', -1 * {{previous_days}}, current_date)
        and block_timestamp < current_date
        group by 1
    ),
{%- endmacro %}
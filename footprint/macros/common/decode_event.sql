{% macro
    decode_event(
          logs_table_name='ethereum_logs',
          address='0x146f2ac6ffc0c953073598fb5d6fbe0976421d8e',
          abi_string='',
          start_time='',
          end_time='',
          event_view_name=''
    )
-%}

parsed_logs AS
(SELECT
    logs.block_timestamp AS block_timestamp
    ,logs.block_number AS block_number
    ,logs.transaction_hash AS transaction_hash
    ,logs.log_index AS log_index
    ,logs.address AS contract_address
    ,udf_decode_event('{{abi_string}}', data, topics) AS parsed
FROM footprint.{{logs_table_name}} AS logs
WHERE
  address in ('{{address}}')
  AND topics[1] = udf_abi_to_selector('{{abi_string}}')
  AND block_timestamp >= timestamp '{{start_time}}'
  AND block_timestamp < timestamp '{{end_time}}'
  ),
{{event_view_name}} as
(SELECT
     block_timestamp
     ,block_number
     ,transaction_hash
     ,log_index
     ,contract_address
     ,parsed as inputs
FROM parsed_logs
WHERE parsed IS NOT NULL),

{%- endmacro %}
{{config(
        materialized='ephemeral'
)}}

{{basic_generate_protocol_transactions('ethereum', 'Ethereum')}}
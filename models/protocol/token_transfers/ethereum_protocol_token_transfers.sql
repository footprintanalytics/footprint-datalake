{{config(
        materialized='table'
)}}

{{basic_generate_protocol_token_transfers('ethereum', 'Ethereum')}}
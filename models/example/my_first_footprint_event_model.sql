
/*
    Welcome to your first dbt model!
    Did you know that you can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml

    Try changing "table" to "view" below
*/

{{ config(materialized='table') }}

with
{{
    decode_event(
        logs_table_name='ethereum_logs',
        address='0x7d2768de32b0b80b7a3454c06bdac94a69ddc7a9',
        abi_string='{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"reserve","type":"address"},{"indexed":false,"internalType":"address","name":"user","type":"address"},{"indexed":true,"internalType":"address","name":"onBehalfOf","type":"address"},{"indexed":false,"internalType":"uint256","name":"amount","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"borrowRateMode","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"borrowRate","type":"uint256"},{"indexed":true,"internalType":"uint16","name":"referral","type":"uint16"}],"name":"Borrow","type":"event"}',
        start_time='2022-11-20',
        end_time='2022-11-26',
        event_view_name='aave_borrow'
    )
}}
sources as (select * from aave_borrow)
select *
from sources

/*
    Uncomment the line below to remove records with null `id` values
*/

-- where id is not null

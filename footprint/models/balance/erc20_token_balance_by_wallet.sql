with
{{
erc20_token_balance_by_wallet(
chain='ethereum',
token_address=['0x4d224452801aced8b2f0aebe155379bb5d594381', '0x3845badade8e6dff049820680d1f14bd3903a5d0', '0x8642a849d0dcb7a15a974794668adcfbe4794b56'],
wallet_address=['0x91951fa186a77788197975ed58980221872a3352', '0x68c81a2bae78c8da02b7f2eca0d992da1d3a3011', '0x0404d96d2583799bc73edb8d230aa037fc22b379'],
block_timestamp='2023-01-12 13:00:00'
)
}}
select * from token_balance where balance > 0
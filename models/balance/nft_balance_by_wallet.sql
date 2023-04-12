with
{{
nft_balance_by_wallet(
chain='ethereum',
token_address=['0xbc4ca0eda7647a8ab7c2061c2e118a18a936f13d', '0x5cc5b05a8a13e3fbdb0bb9fccd98d38e50f90c38', '0x34d85c9cdeb23fa97cb08333b511ac86e1c4e258'],
wallet_address=['0x619866736a3a101f65cff3a8c3d2602fc54fd749', '0xe7079eec020ddfc3f1c0abe1d946c55e6ed30eb3', '0x18d82cc691754ea6db4018004de61fce8a63f392'],
block_timestamp='2023-01-12 13:00:00'
)
}}
select * from token_balance where balance > 0
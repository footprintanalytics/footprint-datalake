{% set day_range = 180 %}

with
{#chain_daily_active_user(chain='ethereum', previous_days=day_range)#}
{#chain_daily_active_user(chain='bsc', previous_days=day_range)#}
{#chain_daily_active_user(chain='polygon', previous_days=day_range)#}
{#chain_daily_active_user(chain='avalanche', previous_days=day_range)#}
{{chain_daily_active_user(chain='arbitrum', previous_days=day_range)}}
{{chain_daily_active_user(chain='optimism', previous_days=day_range)}}
{#chain_daily_active_user(chain='fantom', previous_days=day_range)#}
{#chain_daily_active_user(chain='celo', previous_days=day_range)#}
{#chain_daily_active_user(chain='moonriver', previous_days=day_range)#}
{#chain_daily_active_user(chain='moonbeam', previous_days=day_range)#}

join_all_chain as (
    select
        arb.on_date
        ,arb.active_user as "Arbitrum"
--        ,eth.active_user as "Ethereum"
--bsc too big        ,bsc.active_user as "BNB Chain"
--        ,matic.active_user as "Polygon"
--        ,avax.active_user as "Avalanche"
        ,op.active_user as "Optimism"
--        ,ftm.active_user as "Fantom"
--        ,celo.active_user as "Celo"
--        ,river.active_user as "MoonRiver"
--        ,beam.active_user as "MoonBeam"
    from arbitrum_active_user arb
--    left join
--    bsc_active_user bsc
--    on arb.on_date = bsc.on_date
--    left join
--    polygon_active_user matic
--    on arb.on_date = matic.on_date
--    left join
--    avalanche_active_user avax
--    on arb.on_date = avax.on_date
--    left join
--    ethereum_active_user eth
--    on arb.on_date = eth.on_date
    left join
    optimism_active_user op
    on arb.on_date = op.on_date
--    left join
--    fantom_active_user ftm
--    on arb.on_date = ftm.on_date
--    left join
--    celo_active_user celo
--    on arb.on_date = celo.on_date
--    left join
--    moonriver_active_user river
--    on arb.on_date = river.on_date
--    left join
--    moonbeam_active_user beam
--    on arb.on_date = beam.on_date
)

select * from join_all_chain

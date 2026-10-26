-- SQLite, one verified pool only. Monetary population = valid tx_from with positive
-- priced-leg estimate in the week. Every amount is the reviewed daily-price estimate.
-- Rank ties deterministically by lowercase tx_from ASC; exactly CEIL(.01*N) addresses.
WITH population AS (
 SELECT week_utc,tx_from,event_rows,transactions,usdc_abs_micro,usd_estimate
 FROM address_week WHERE usd_estimate>0
), ranked AS (
 SELECT *,ROW_NUMBER() OVER(PARTITION BY week_utc ORDER BY usd_estimate DESC,tx_from ASC) usd_rank,
 ROW_NUMBER() OVER(PARTITION BY week_utc ORDER BY transactions DESC,tx_from ASC) tx_rank,
 COUNT(*) OVER(PARTITION BY week_utc) population_n
 FROM population
)
SELECT *,CAST((population_n+99)/100 AS INTEGER) top1_count
FROM ranked ORDER BY week_utc,usd_rank;

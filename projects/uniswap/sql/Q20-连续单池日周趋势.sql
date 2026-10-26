-- SQLite. Population: BASE_UNIV3_WETH_USDC_FEE10000_84D only.
-- Every date is joined only AFTER complete RPC block-range coverage is certified.
-- Weekly distinct addresses/transactions are computed from events, NOT summed daily distincts.
DROP VIEW IF EXISTS daily_trend;
CREATE VIEW daily_trend AS
SELECT d.day_utc, COUNT(e.tx_hash) event_rows,
       COUNT(DISTINCT e.tx_hash) transactions, COUNT(DISTINCT e.tx_from) active_addresses,
       COALESCE(SUM(e.usdc_abs_micro),0) usdc_abs_micro,
       CASE WHEN COUNT(e.tx_hash)=0 THEN 0.0 ELSE SUM(e.usd_estimate) END usd_estimate,
       COUNT(e.usd_estimate) priced_events,
       SUM(CASE WHEN e.tx_hash IS NOT NULL AND e.tx_from IS NULL THEN 1 ELSE 0 END) unknown_origin_events
FROM days d LEFT JOIN events e ON e.day_utc=d.day_utc
GROUP BY d.day_utc;

DROP VIEW IF EXISTS weekly_trend;
CREATE VIEW weekly_trend AS
SELECT w.week_utc, COUNT(e.tx_hash) event_rows,
       COUNT(DISTINCT e.tx_hash) transactions, COUNT(DISTINCT e.tx_from) active_addresses,
       COALESCE(SUM(e.usdc_abs_micro),0) usdc_abs_micro,
       CASE WHEN COUNT(e.tx_hash)=0 THEN 0.0 ELSE SUM(e.usd_estimate) END usd_estimate,
       COUNT(e.usd_estimate) priced_events,
       SUM(CASE WHEN e.tx_hash IS NOT NULL AND e.tx_from IS NULL THEN 1 ELSE 0 END) unknown_origin_events,
       CASE WHEN SUM(CASE WHEN e.tx_hash IS NOT NULL AND e.tx_from IS NULL THEN 1 ELSE 0 END)=0
            THEN 0.0 ELSE SUM(CASE WHEN e.tx_from IS NULL THEN e.usd_estimate END) END unknown_origin_usd_estimate
FROM weeks w LEFT JOIN events e ON e.week_utc=w.week_utc
GROUP BY w.week_utc;

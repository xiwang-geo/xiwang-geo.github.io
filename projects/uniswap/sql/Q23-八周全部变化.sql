-- Main diagnostic selects the largest ABS change in weekly active addresses among all 7 transitions.
-- Ties: earliest week. The criterion is fixed before inspecting the outcomes.
WITH displayed AS (SELECT * FROM weekly_trend WHERE week_utc>='2026-08-24'),
lagged AS (
 SELECT *,LAG(active_addresses) OVER(ORDER BY week_utc) previous_addresses,
          LAG(transactions) OVER(ORDER BY week_utc) previous_transactions,
          LAG(usd_estimate) OVER(ORDER BY week_utc) previous_usd_estimate,
          LAG(usdc_abs_micro) OVER(ORDER BY week_utc) previous_usdc_abs_micro
 FROM displayed
)
SELECT *,active_addresses-previous_addresses delta_addresses,
       CASE WHEN previous_addresses>0 THEN 1.0*(active_addresses-previous_addresses)/previous_addresses END address_growth,
       transactions-previous_transactions delta_transactions,
       CASE WHEN previous_transactions>0 THEN 1.0*(transactions-previous_transactions)/previous_transactions END transaction_growth,
       usd_estimate-previous_usd_estimate delta_usd_estimate,
       CASE WHEN previous_usd_estimate>0 THEN usd_estimate/previous_usd_estimate-1 END usd_estimate_growth,
       CASE WHEN previous_usdc_abs_micro>0 THEN 1.0*usdc_abs_micro/previous_usdc_abs_micro-1 END usdc_units_growth
FROM lagged ORDER BY week_utc;

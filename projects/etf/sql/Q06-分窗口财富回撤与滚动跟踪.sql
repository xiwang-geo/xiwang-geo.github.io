-- Frozen windows. Seed date is the immediately preceding confirmed trading day.
WITH RECURSIVE windows(window_id,start_date,end_date) AS (
 VALUES ('W12','2025-10-24','2026-10-23'),('W06','2026-04-24','2026-10-23'),('W03','2026-07-24','2026-10-23')
), bounds AS (
 SELECT w.*, (SELECT MAX(trade_date) FROM dim_calendar WHERE is_trading_day=1 AND trade_date<w.start_date) AS seed_date
 FROM windows w
), ordered AS (
 SELECT b.window_id,b.start_date,b.end_date,b.seed_date,m.*,
 ROW_NUMBER() OVER(PARTITION BY b.window_id,m.product_id ORDER BY m.trade_date) AS rn
 FROM bounds b JOIN mart_product_day m ON m.trade_date BETWEEN b.seed_date AND b.end_date
), wealth(window_id,product_id,rn,fund_wealth,tr_wealth,price_index_wealth) AS (
 SELECT window_id,product_id,rn,1.0,1.0,1.0 FROM ordered WHERE rn=1
 UNION ALL
 SELECT o.window_id,o.product_id,o.rn,w.fund_wealth*(1+o.fund_total_return),
 w.tr_wealth*(1+o.reference_total_return),w.price_index_wealth*(1+o.reference_price_return)
 FROM wealth w JOIN ordered o ON o.window_id=w.window_id AND o.product_id=w.product_id AND o.rn=w.rn+1
), series AS (
 SELECT o.*,w.fund_wealth,w.tr_wealth,w.price_index_wealth,
 CASE WHEN o.rn=1 THEN NULL ELSE o.fund_total_return-o.reference_total_return END AS active_return,
 CASE WHEN o.rn=1 THEN NULL ELSE o.fund_total_return END AS analysis_return
 FROM ordered o JOIN wealth w USING(window_id,product_id,rn)
), rolling AS (
 SELECT *,MAX(fund_wealth) OVER base AS running_peak,
 COUNT(active_return) OVER r20 AS n20,SUM(active_return) OVER r20 AS s20,SUM(active_return*active_return) OVER r20 AS ss20,
 COUNT(active_return) OVER r60 AS n60,SUM(active_return) OVER r60 AS s60,SUM(active_return*active_return) OVER r60 AS ss60
 FROM series
 WINDOW base AS (PARTITION BY window_id,product_id ORDER BY trade_date ROWS UNBOUNDED PRECEDING),
 r20 AS (PARTITION BY window_id,product_id ORDER BY trade_date ROWS BETWEEN 19 PRECEDING AND CURRENT ROW),
 r60 AS (PARTITION BY window_id,product_id ORDER BY trade_date ROWS BETWEEN 59 PRECEDING AND CURRENT ROW)
)
SELECT window_id,product_id,start_date,end_date,seed_date,trade_date,rn,
 close_cny,unit_nav_cny,turnover_cny,volume_shares,analysis_return AS fund_total_return,
 CASE WHEN rn=1 THEN NULL ELSE reference_total_return END AS reference_total_return,
 CASE WHEN rn=1 THEN NULL ELSE reference_price_return END AS reference_price_return,
 active_return,closing_premium,fund_wealth,tr_wealth,price_index_wealth,
 fund_wealth/running_peak-1 AS drawdown,
 CASE WHEN n20=20 THEN SQRT(MAX(0,(ss20-s20*s20/20)/19)*252) END AS rolling_TE20,
 CASE WHEN n60=60 THEN SQRT(MAX(0,(ss60-s60*s60/60)/59)*252) END AS rolling_TE60
FROM rolling ORDER BY window_id,product_id,trade_date;

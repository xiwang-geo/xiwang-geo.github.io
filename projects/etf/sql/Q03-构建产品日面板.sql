WITH events AS (
 SELECT product_id,effective_date,SUM(CAST(cash_per_unit_decimal AS REAL)) AS cash
 FROM fact_corporate_action WHERE event_type='cash_distribution'
 AND verification_status='issuer_notice_verified'
 GROUP BY product_id,effective_date
), aligned AS (
 SELECT p.product_id,p.trade_date,CAST(p.close_decimal AS REAL) AS close_cny,
 CAST(n.unit_nav_decimal AS REAL) AS nav,
 CAST(p.turnover_cny_decimal AS REAL) AS turnover,p.volume_shares,
 COALESCE(e.cash,0.0) AS cash,
 CAST(btr.point_close_decimal AS REAL) AS tr_index,
 CAST(bp.point_close_decimal AS REAL) AS p_index,
 LAG(p.trade_date) OVER (PARTITION BY p.product_id ORDER BY p.trade_date) AS prev_date,
 LAG(CAST(n.unit_nav_decimal AS REAL)) OVER (PARTITION BY p.product_id ORDER BY p.trade_date) AS prev_nav,
 LAG(CAST(btr.point_close_decimal AS REAL)) OVER (PARTITION BY p.product_id ORDER BY p.trade_date) AS prev_tr,
 LAG(CAST(bp.point_close_decimal AS REAL)) OVER (PARTITION BY p.product_id ORDER BY p.trade_date) AS prev_p
 FROM fact_price_daily p JOIN fact_nav_daily n ON p.product_id=n.product_id AND p.trade_date=n.nav_date
 LEFT JOIN events e ON p.product_id=e.product_id AND p.trade_date=e.effective_date
 JOIN fact_benchmark_daily btr ON btr.series_id='H00300' AND p.trade_date=btr.trade_date
 JOIN fact_benchmark_daily bp ON bp.series_id='000300' AND p.trade_date=bp.trade_date
), expected AS (
 SELECT trade_date,LAG(trade_date) OVER(ORDER BY trade_date) AS expected_prev
 FROM dim_calendar WHERE exchange='SSE' AND is_trading_day=1
)
INSERT INTO mart_product_day
SELECT a.product_id,a.trade_date,x.expected_prev,a.close_cny,a.nav,a.turnover,a.volume_shares,
 CASE WHEN a.prev_date=x.expected_prev AND a.prev_nav>0 THEN (a.nav+a.cash)/a.prev_nav-1 END,
 CASE WHEN a.prev_date=x.expected_prev AND a.prev_tr>0 THEN a.tr_index/a.prev_tr-1 END,
 CASE WHEN a.prev_date=x.expected_prev AND a.prev_p>0 THEN a.p_index/a.prev_p-1 END,
 a.close_cny/a.nav-1,
 CASE WHEN x.expected_prev IS NULL THEN 'seed_no_return' WHEN a.prev_date=x.expected_prev THEN 'valid' ELSE 'gap' END,
 'valid','valid','1.0'
FROM aligned a JOIN expected x ON x.trade_date=a.trade_date;
-- Run only after full-window event inventory and independent calendar checks pass.

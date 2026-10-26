SELECT p.product_id, COUNT(*) AS price_rows, MIN(p.trade_date) AS first_date,
 MAX(p.trade_date) AS last_date,
 SUM(n.unit_nav_decimal IS NULL) AS missing_nav,
 SUM(CAST(p.close_decimal AS REAL)<=0) AS nonpositive_close,
 SUM(CAST(n.unit_nav_decimal AS REAL)<=0) AS nonpositive_nav,
 SUM(p.volume_shares<=0) AS nonpositive_volume,
 SUM(CAST(p.turnover_cny_decimal AS REAL)<=0) AS nonpositive_turnover
FROM fact_price_daily p LEFT JOIN fact_nav_daily n
 ON p.product_id=n.product_id AND p.trade_date=n.nav_date
GROUP BY p.product_id ORDER BY p.product_id;

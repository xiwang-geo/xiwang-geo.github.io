WITH RECURSIVE ordered AS (
 SELECT product_id,trade_date,fund_total_return,
 ROW_NUMBER() OVER(PARTITION BY product_id ORDER BY trade_date) AS rn
 FROM mart_product_day
), wealth(product_id,trade_date,rn,w) AS (
 SELECT product_id,trade_date,rn,1.0 FROM ordered WHERE rn=1
 UNION ALL
 SELECT o.product_id,o.trade_date,o.rn,w.w*(1+o.fund_total_return)
 FROM wealth w JOIN ordered o ON o.product_id=w.product_id AND o.rn=w.rn+1
)
SELECT product_id,trade_date,w,
 w/MAX(w) OVER(PARTITION BY product_id ORDER BY trade_date ROWS UNBOUNDED PRECEDING)-1 AS drawdown
FROM wealth ORDER BY product_id,trade_date;

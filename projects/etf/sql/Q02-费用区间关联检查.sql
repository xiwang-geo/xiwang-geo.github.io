SELECT p.product_id,p.trade_date,f.fee_type,COUNT(*) AS matched_intervals
FROM fact_price_daily p JOIN dim_fee_interval f
 ON p.product_id=f.product_id AND f.valid_from<=p.trade_date
 AND (f.valid_to IS NULL OR p.trade_date<f.valid_to)
GROUP BY p.product_id,p.trade_date,f.fee_type
HAVING COUNT(*)<>1;

WITH fee_types(fee_type) AS (SELECT 'management' UNION ALL SELECT 'custody')
    SELECT p.product_id,p.trade_date,t.fee_type,COUNT(f.valid_from) AS matched
    FROM fact_price_daily p CROSS JOIN fee_types t LEFT JOIN dim_fee_interval f
    ON f.product_id=p.product_id AND f.fee_type=t.fee_type
      AND f.valid_from<=p.trade_date AND (f.valid_to IS NULL OR p.trade_date<f.valid_to)
    GROUP BY p.product_id,p.trade_date,t.fee_type HAVING COUNT(f.valid_from)<>1;

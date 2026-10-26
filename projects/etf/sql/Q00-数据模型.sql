-- Schema contract only. No formal observations are inserted by this file.
PRAGMA foreign_keys = ON;
CREATE TABLE source_request (
 request_id TEXT PRIMARY KEY, url TEXT NOT NULL, requested_at_utc TEXT NOT NULL,
 http_status INTEGER, body_sha256 TEXT, body_path TEXT,
 semantic_status TEXT NOT NULL, source_notes TEXT
);
CREATE TABLE dim_product (
 product_id TEXT PRIMARY KEY CHECK(length(product_id)=6), full_name TEXT NOT NULL,
 manager_name TEXT NOT NULL, inception_date TEXT NOT NULL, listing_date TEXT NOT NULL,
 exchange TEXT NOT NULL CHECK(exchange='SSE'), currency TEXT NOT NULL CHECK(currency='CNY'),
 target_index TEXT NOT NULL CHECK(target_index='000300'), identity_source_notes TEXT NOT NULL
);
CREATE TABLE dim_calendar (
 exchange TEXT NOT NULL, trade_date TEXT NOT NULL,
 is_trading_day INTEGER NOT NULL CHECK(is_trading_day IN (0,1)),
 verification_status TEXT NOT NULL,
 source_request_id TEXT REFERENCES source_request(request_id), PRIMARY KEY(exchange,trade_date)
);
CREATE TABLE fact_price_daily (
 product_id TEXT NOT NULL REFERENCES dim_product(product_id), trade_date TEXT NOT NULL,
 open_decimal TEXT, high_decimal TEXT, low_decimal TEXT, close_decimal TEXT,
 volume_shares INTEGER, turnover_cny_decimal TEXT,
 price_adjustment TEXT NOT NULL CHECK(price_adjustment='unadjusted'),
 source_request_id TEXT NOT NULL REFERENCES source_request(request_id), quality_status TEXT NOT NULL,
 PRIMARY KEY(product_id,trade_date)
);
CREATE TABLE fact_nav_daily (
 product_id TEXT NOT NULL REFERENCES dim_product(product_id), nav_date TEXT NOT NULL,
 unit_nav_decimal TEXT, cumulative_nav_raw TEXT, source_growth_pct_raw TEXT,
 published_at TEXT, source_request_id TEXT NOT NULL REFERENCES source_request(request_id),
 source_page INTEGER, quality_status TEXT NOT NULL, PRIMARY KEY(product_id,nav_date)
);
CREATE TABLE fact_benchmark_daily (
 series_id TEXT NOT NULL CHECK(series_id IN ('000300','H00300')), trade_date TEXT NOT NULL,
 point_close_decimal TEXT, currency TEXT NOT NULL CHECK(currency='CNY'), return_type TEXT NOT NULL,
 source_request_id TEXT NOT NULL REFERENCES source_request(request_id), quality_status TEXT NOT NULL,
 PRIMARY KEY(series_id,trade_date)
);
CREATE TABLE fact_corporate_action (
 product_id TEXT NOT NULL REFERENCES dim_product(product_id), event_id TEXT NOT NULL,
 event_type TEXT NOT NULL, announcement_date TEXT, effective_date TEXT NOT NULL,
 original_amount_text TEXT, cash_per_unit_decimal TEXT, share_factor_decimal TEXT,
 unit_basis TEXT NOT NULL, record_date_on_exchange TEXT, record_date_off_exchange TEXT,
 pay_date_on_exchange TEXT, pay_date_off_exchange TEXT,
 source_request_id TEXT NOT NULL REFERENCES source_request(request_id), verification_status TEXT NOT NULL,
 PRIMARY KEY(product_id,event_id)
);
CREATE TABLE dim_fee_interval (
 product_id TEXT NOT NULL REFERENCES dim_product(product_id), fee_type TEXT NOT NULL,
 valid_from TEXT NOT NULL, valid_to TEXT, annual_rate_decimal TEXT NOT NULL,
 announcement_date TEXT, source_request_id TEXT NOT NULL REFERENCES source_request(request_id),
 verification_status TEXT NOT NULL,
 CHECK(valid_to IS NULL OR valid_to>valid_from), PRIMARY KEY(product_id,fee_type,valid_from)
);
CREATE TABLE fact_fee_snapshot (
 product_id TEXT NOT NULL REFERENCES dim_product(product_id), fee_type TEXT NOT NULL,
 as_of_date TEXT NOT NULL, source_request_id TEXT NOT NULL REFERENCES source_request(request_id),
 annual_rate_decimal TEXT, historical_valid_from TEXT, historical_status TEXT NOT NULL,
 PRIMARY KEY(product_id,fee_type,as_of_date,source_request_id)
);
CREATE TABLE fact_shares_snapshot (
 product_id TEXT NOT NULL REFERENCES dim_product(product_id), as_of_date TEXT NOT NULL,
 units_decimal TEXT NOT NULL, original_units_text TEXT NOT NULL,
 source_request_id TEXT NOT NULL REFERENCES source_request(request_id), quality_status TEXT NOT NULL,
 PRIMARY KEY(product_id,as_of_date)
);
CREATE TABLE mart_product_day (
 product_id TEXT NOT NULL REFERENCES dim_product(product_id), trade_date TEXT NOT NULL,
 previous_expected_trade_date TEXT, close_cny REAL, unit_nav_cny REAL,
 turnover_cny REAL, volume_shares INTEGER, fund_total_return REAL,
 reference_total_return REAL, reference_price_return REAL, closing_premium REAL,
 return_status TEXT NOT NULL, premium_status TEXT NOT NULL, trading_status TEXT NOT NULL,
 definition_version TEXT NOT NULL, PRIMARY KEY(product_id,trade_date)
);
CREATE TABLE mart_product_window (
 product_id TEXT NOT NULL REFERENCES dim_product(product_id), window_id TEXT NOT NULL,
 metric_id TEXT NOT NULL, metric_value REAL, valid_n INTEGER NOT NULL,
 expected_n INTEGER NOT NULL, reference_series TEXT, status TEXT NOT NULL,
 definition_version TEXT NOT NULL, computed_at_utc TEXT NOT NULL,
 CHECK(valid_n>=0 AND expected_n>=0 AND valid_n<=expected_n),
 PRIMARY KEY(product_id,window_id,metric_id)
);
-- Interval-overlap checks and post-join cardinality checks are mandatory before aggregation.

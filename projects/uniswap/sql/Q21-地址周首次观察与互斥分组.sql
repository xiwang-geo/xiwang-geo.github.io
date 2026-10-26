-- First observation uses ALL 84 days, including the 28-day pre-display buffer.
DROP VIEW IF EXISTS address_first;
CREATE VIEW address_first AS
SELECT tx_from, MIN(block_time) first_time, MIN(week_utc) first_week
FROM events WHERE tx_from IS NOT NULL GROUP BY tx_from;

DROP VIEW IF EXISTS address_week;
CREATE VIEW address_week AS
SELECT tx_from,week_utc,COUNT(*) event_rows,COUNT(DISTINCT tx_hash) transactions,
       SUM(usdc_abs_micro) usdc_abs_micro,SUM(usd_estimate) usd_estimate
FROM events WHERE tx_from IS NOT NULL GROUP BY tx_from,week_utc;

DROP VIEW IF EXISTS address_groups;
CREATE VIEW address_groups AS
SELECT a.*, f.first_week,
       CASE WHEN a.week_utc=f.first_week THEN 'first_observed'
            WHEN EXISTS(SELECT 1 FROM address_week p WHERE p.tx_from=a.tx_from
                        AND p.week_utc=date(a.week_utc,'-7 days')) THEN 'continuing'
            ELSE 'reappearing' END activity_group
FROM address_week a JOIN address_first f USING(tx_from);

DROP VIEW IF EXISTS weekly_groups;
CREATE VIEW weekly_groups AS
WITH labels(activity_group) AS (VALUES('first_observed'),('continuing'),('reappearing'))
SELECT w.week_utc,l.activity_group,COUNT(a.tx_from) addresses,
       COALESCE(SUM(a.event_rows),0) event_rows,COALESCE(SUM(a.transactions),0) transactions,
       COALESCE(SUM(a.usdc_abs_micro),0) usdc_abs_micro,
       CASE WHEN COUNT(a.tx_from)=0 THEN 0.0 ELSE SUM(a.usd_estimate) END usd_estimate
FROM weeks w CROSS JOIN labels l
LEFT JOIN address_groups a ON a.week_utc=w.week_utc AND a.activity_group=l.activity_group
GROUP BY w.week_utc,l.activity_group;

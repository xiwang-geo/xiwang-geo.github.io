-- W1 and W2 are exact relative weeks, NOT cumulative return and NOT necessarily consecutive.
-- W2 return does not require W1 return. Every address-week contributes at most 1 flag.
-- A cell is mature only when the ENTIRE target week is observed.
DROP VIEW IF EXISTS cohort_retention;
CREATE VIEW cohort_retention AS
WITH offsets(week_offset) AS (VALUES(0),(1),(2)),
sizes AS (SELECT first_week cohort_week,COUNT(*) cohort_size FROM address_first GROUP BY first_week)
SELECT w.week_utc cohort_week,o.week_offset,COALESCE(s.cohort_size,0) cohort_size,
       CASE WHEN date(w.week_utc,printf('+%d days',7*(o.week_offset+1)))<='2026-10-19'
            THEN 1 ELSE 0 END mature,
       CASE WHEN date(w.week_utc,printf('+%d days',7*(o.week_offset+1)))<='2026-10-19'
            THEN COUNT(a.tx_from) ELSE NULL END returning_addresses,
       CASE WHEN date(w.week_utc,printf('+%d days',7*(o.week_offset+1)))<='2026-10-19'
                      AND COALESCE(s.cohort_size,0)>0
            THEN 1.0*COUNT(a.tx_from)/s.cohort_size ELSE NULL END return_rate
FROM weeks w CROSS JOIN offsets o LEFT JOIN sizes s ON s.cohort_week=w.week_utc
LEFT JOIN address_first f ON f.first_week=w.week_utc
LEFT JOIN address_week a ON a.tx_from=f.tx_from
                         AND a.week_utc=date(w.week_utc,printf('+%d days',7*o.week_offset))
GROUP BY w.week_utc,o.week_offset,s.cohort_size;

-- ============================================================
-- TOURISM ANALYTICS PROJECT
-- FINAL SQL VALIDATION & QUALITY CHECK
-- ============================================================

USE tourism_analytics;


-- ============================================================
-- 1. FINAL TABLE CHECK
-- ============================================================

SELECT COUNT(*) AS `Total Rows`
FROM tourism_analysis_final;


-- ============================================================
-- 2. CHECK TABLE STRUCTURE
-- ============================================================

DESCRIBE tourism_analysis_final;


-- ============================================================
-- 3. CHECK DUPLICATE COUNTRIES
-- ============================================================

SELECT
    `Country Name`,
    COUNT(*) AS `Count`
FROM tourism_analysis_final
GROUP BY `Country Name`
HAVING COUNT(*) > 1;


-- ============================================================
-- 4. CHECK MISSING VALUES
-- ============================================================

SELECT
    SUM(`Country Name` IS NULL) AS `Missing Country Names`,
    SUM(`Country Code` IS NULL) AS `Missing Country Codes`,
    SUM(`2019` IS NULL) AS `Missing 2019`,
    SUM(`2020` IS NULL) AS `Missing 2020`,
    SUM(`Change (%)` IS NULL) AS `Missing Change`,
    SUM(`Recovery (%)` IS NULL) AS `Missing Recovery`,
    SUM(`Opportunity Score` IS NULL) AS `Missing Opportunity`,
    SUM(`Rank` IS NULL) AS `Missing Rank`
FROM tourism_analysis_final;


-- ============================================================
-- 5. CHECK NEGATIVE TOURISM VALUES
-- ============================================================

SELECT *
FROM tourism_analysis_final
WHERE `2019` < 0
   OR `2020` < 0;


-- ============================================================
-- 6. VALIDATE CHANGE (%) CALCULATION
-- ============================================================

SELECT
    `Country Name`,
    `2019`,
    `2020`,
    `Change (%)`,
    ROUND(
        ((`2020` - `2019`) / `2019`) * 100,
        2
    ) AS `Calculated Change`
FROM tourism_analysis_final
WHERE `2019` IS NOT NULL
  AND `2019` <> 0
  AND `2020` IS NOT NULL
ORDER BY `Country Name`;


-- ============================================================
-- 7. FIND INCORRECT CHANGE (%) VALUES
-- ============================================================

SELECT
    `Country Name`,
    `Change (%)`,
    ROUND(
        ((`2020` - `2019`) / `2019`) * 100,
        2
    ) AS `Expected Change`
FROM tourism_analysis_final
WHERE `2019` IS NOT NULL
  AND `2019` <> 0
  AND `2020` IS NOT NULL
  AND ABS(
        `Change (%)` -
        (((`2020` - `2019`) / `2019`) * 100)
      ) > 0.01;


-- ============================================================
-- 8. VALIDATE RECOVERY (%) CALCULATION
-- ============================================================

SELECT
    `Country Name`,
    `2019`,
    `2020`,
    `Recovery (%)`,
    ROUND(
        (`2020` / `2019`) * 100,
        2
    ) AS `Calculated Recovery`
FROM tourism_analysis_final
WHERE `2019` IS NOT NULL
  AND `2019` <> 0
  AND `2020` IS NOT NULL
ORDER BY `Country Name`;


-- ============================================================
-- 9. FIND INCORRECT RECOVERY (%) VALUES
-- ============================================================

SELECT
    `Country Name`,
    `Recovery (%)`,
    ROUND(
        (`2020` / `2019`) * 100,
        2
    ) AS `Expected Recovery`
FROM tourism_analysis_final
WHERE `2019` IS NOT NULL
  AND `2019` <> 0
  AND `2020` IS NOT NULL
  AND ABS(
        `Recovery (%)` -
        ((`2020` / `2019`) * 100)
      ) > 0.01;


-- ============================================================
-- 10. VALIDATE OPPORTUNITY SCORE
-- ============================================================

SELECT
    COUNT(*) AS `Opportunity Score Mismatches`
FROM tourism_analysis_final
WHERE `Opportunity Score` IS NOT NULL
  AND `Recovery (%)` IS NOT NULL
  AND ABS(`Opportunity Score` - `Recovery (%)`) > 0.01;


-- ============================================================
-- 11. CHECK RANKING
-- ============================================================

SELECT
    `Rank`,
    `Country Name`,
    `Opportunity Score`
FROM tourism_analysis_final
WHERE `Rank` IS NOT NULL
ORDER BY `Rank`
LIMIT 20;


-- ============================================================
-- 12. CHECK DUPLICATE RANKS
-- ============================================================

SELECT
    `Rank`,
    COUNT(*) AS `Count`
FROM tourism_analysis_final
WHERE `Rank` IS NOT NULL
GROUP BY `Rank`
HAVING COUNT(*) > 1;


-- ============================================================
-- 13. CHECK TOP 10 FINAL COUNTRIES
-- ============================================================

SELECT
    `Rank`,
    `Country Name`,
    `2019`,
    `2020`,
    `Change (%)`,
    `Recovery (%)`,
    `Opportunity Score`
FROM tourism_analysis_final
WHERE `Rank` IS NOT NULL
ORDER BY `Rank`
LIMIT 10;


-- ============================================================
-- 14. CHECK BOTTOM 10 FINAL COUNTRIES
-- ============================================================

SELECT
    `Rank`,
    `Country Name`,
    `2019`,
    `2020`,
    `Change (%)`,
    `Recovery (%)`,
    `Opportunity Score`
FROM tourism_analysis_final
WHERE `Rank` IS NOT NULL
ORDER BY `Rank` DESC
LIMIT 10;


-- ============================================================
-- 15. OVERALL PROJECT STATISTICS
-- ============================================================

SELECT
    COUNT(*) AS `Countries Analyzed`,
    ROUND(SUM(`2019`), 2) AS `Total Arrivals 2019`,
    ROUND(SUM(`2020`), 2) AS `Total Arrivals 2020`,
    ROUND(AVG(`2019`), 2) AS `Average Arrivals 2019`,
    ROUND(AVG(`2020`), 2) AS `Average Arrivals 2020`,
    ROUND(AVG(`Change (%)`), 2) AS `Average Change (%)`,
    ROUND(AVG(`Recovery (%)`), 2) AS `Average Recovery (%)`
FROM tourism_analysis_final;


-- ============================================================
-- 16. FINAL ANALYTICAL DATASET
-- ============================================================

SELECT
    `Country Name`,
    `Country Code`,
    `2019`,
    `2020`,
    `Change (%)`,
    `Recovery (%)`,
    `Opportunity Score`,
    `Rank`
FROM tourism_analysis_final
ORDER BY `Rank`;


-- ============================================================
-- 17. FINAL SQL PROJECT CHECK
-- ============================================================

SELECT
    CASE
        WHEN (SELECT COUNT(*) FROM tourism_analysis_final) = 223
        THEN 'PASS - 223 rows confirmed'
        ELSE 'CHECK - Row count is not 223'
    END AS `Row Count Status`,

    CASE
        WHEN (
            SELECT COUNT(*)
            FROM tourism_analysis_final
            WHERE `Opportunity Score` IS NOT NULL
              AND `Recovery (%)` IS NOT NULL
              AND ABS(`Opportunity Score` - `Recovery (%)`) > 0.01
        ) = 0
        THEN 'PASS - Opportunity Score validated'
        ELSE 'CHECK - Opportunity Score mismatch'
    END AS `Opportunity Status`,

    CASE
        WHEN (
            SELECT COUNT(*)
            FROM tourism_analysis_final
            WHERE `2019` IS NOT NULL
              AND `2019` <> 0
              AND `2020` IS NOT NULL
              AND ABS(
                    `Change (%)` -
                    (((`2020` - `2019`) / `2019`) * 100)
                  ) > 0.01
        ) = 0
        THEN 'PASS - Change calculation validated'
        ELSE 'CHECK - Change calculation'
    END AS `Change Status`,

    CASE
        WHEN (
            SELECT COUNT(*)
            FROM tourism_analysis_final
            WHERE `2019` IS NOT NULL
              AND `2019` <> 0
              AND `2020` IS NOT NULL
              AND ABS(
                    `Recovery (%)` -
                    ((`2020` / `2019`) * 100)
                  ) > 0.01
        ) = 0
        THEN 'PASS - Recovery calculation validated'
        ELSE 'CHECK - Recovery calculation'
    END AS `Recovery Status`;


-- ============================================================
-- END OF FINAL SQL VALIDATION
-- ============================================================
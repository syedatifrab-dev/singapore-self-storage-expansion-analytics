-- Check for duplicate stores

SELECT
    store_id,
    COUNT(*) AS record_count
FROM stores
GROUP BY store_id
HAVING COUNT(*) > 1;


-- Check invalid occupancy

SELECT *
FROM monthly_store_performance
WHERE occupancy_pct < 0
   OR occupancy_pct > 100;


-- Check missing planning areas

SELECT *
FROM stores
WHERE planning_area IS NULL;


-- Check negative revenue

SELECT *
FROM monthly_store_performance
WHERE revenue < 0;
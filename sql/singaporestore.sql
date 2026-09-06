 create database singapore_data;
 use singapore_data;
create schema raw;

select * from candidate_sites;

--Section A — Market Opportunity
--Q1. Which planning areas have the highest population density?


SELECT
    planning_area,
    population_2025,
    population_density_per_sq_km
FROM planning_area
ORDER BY population_density_per_sq_km DESC
LIMIT 10;

--Q2. Which areas have the highest business density?

SELECT
    planning_area,
    business_count,
    business_density_per_sq_km
FROM planning_area
ORDER BY business_density_per_sq_km DESC
LIMIT 10;

--Q3. Which areas have high population but relatively low competition?

SELECT
    p.planning_area,
    p.population_2025,
    COUNT(c.facility_id) AS competitor_count
FROM planning_area p
LEFT JOIN competitor_facilities c
    ON p.planning_area = c.planning_area
GROUP BY
    p.planning_area,
    p.population_2025
ORDER BY
    population_2025 DESC,
    competitor_count ASC;


--3. Customer analysis
--Q4. What is the enquiry conversion rate?

SELECT
    COUNT(*) AS total_enquiries,
    SUM(converted) AS conversions,
    ROUND(
        100.0 * SUM(converted) / COUNT(*),
        2
    ) AS conversion_rate_pct
FROM customer_enquiries;



--Q5. Which lead source converts best?

SELECT
    lead_source,
    COUNT(*) AS enquiries,
    SUM(converted) AS conversions,
    ROUND(
        100.0 * SUM(converted) / COUNT(*),
        2
    ) AS conversion_rate_pct
FROM customer_enquiries
GROUP BY lead_source
ORDER BY conversion_rate_pct DESC;


--Q6. Which customer segment generates the highest conversion?

SELECT
    customer_type,
    COUNT(*) AS enquiries,
    SUM(converted) AS conversions,
    ROUND(
        100.0 * SUM(converted) / COUNT(*),
        2
    ) AS conversion_rate_pct
FROM customer_enquiries
GROUP BY customer_type
ORDER BY conversion_rate_pct DESC;


--Q7. Which storage size has the strongest demand?

SELECT
    storage_size_band,
    COUNT(*) AS enquiries,
    SUM(converted) AS conversions,
    ROUND(
        100.0 * SUM(converted) / COUNT(*),
        2
    ) AS conversion_rate_pct
FROM customer_enquiries
GROUP BY storage_size_band
ORDER BY enquiries DESC;

--Q8. Which areas generate the most enquiries?

SELECT
    planning_area,
    COUNT(*) AS enquiries,
    SUM(converted) AS conversions,
    ROUND(
        100.0 * SUM(converted) / COUNT(*),
        2
    ) AS conversion_rate_pct
FROM customer_enquiries
GROUP BY planning_area
ORDER BY enquiries DESC
LIMIT 15;

--Q9. Which areas have high demand but low competition?
WITH demand AS (
    SELECT
        planning_area,
        COUNT(*) AS enquiries,
        SUM(converted) AS conversions
    FROM customer_enquiries
    GROUP BY planning_area
),

competition AS (
    SELECT
        planning_area,
        COUNT(*) AS competitor_count
    FROM competitor_facilities
    GROUP BY planning_area
)

SELECT
    d.planning_area,
    d.enquiries,
    d.conversions,
    COALESCE(c.competitor_count, 0) AS competitor_count,
    ROUND(
        d.enquiries * 1.0 /
        NULLIF(COALESCE(c.competitor_count, 0), 0),
        2
    ) AS demand_per_competitor
FROM demand d
LEFT JOIN competition c
    ON d.planning_area = c.planning_area
ORDER BY demand_per_competitor DESC;

--Q10. Which operators have the most facilities?

SELECT
    operator,
    COUNT(*) AS facility_count
FROM competitor_facilities
GROUP BY operator
ORDER BY facility_count DESC;


--Q11. What is the average competitor price by area?
SELECT
    planning_area,
    ROUND(AVG(avg_monthly_price_sgd), 2) AS avg_competitor_price
FROM competitor_facilities
GROUP BY planning_area
ORDER BY avg_competitor_price DESC;

--Q12. Where is competitor occupancy highest?

SELECT
    planning_area,
    ROUND(AVG(estimated_occupancy) * 100, 1) AS avg_occupancy_pct
FROM competitor_facilities
GROUP BY planning_area
ORDER BY avg_occupancy_pct DESC;

--30% Customer Demand
--20% Population Density
--15% Business Density
--15% Low Competition
--10% Traffic Accessibility
--10% HDB Household Potential

WITH metrics AS (
    SELECT
        p.planning_area,

        p.population_density_per_sq_km,
        p.business_density_per_sq_km,
        p.avg_daily_traffic_index,
        p.hdb_household_share,

        COUNT(DISTINCT c.facility_id) AS competitor_count,

        COUNT(DISTINCT e.enquiry_id) AS enquiries

    FROM planning_area p

    LEFT JOIN competitor_facilities c
        ON p.planning_area = c.planning_area

    LEFT JOIN customer_enquiries e
        ON p.planning_area = e.planning_area

    GROUP BY
        p.planning_area,
        p.population_density_per_sq_km,
        p.business_density_per_sq_km,
        p.avg_daily_traffic_index,
        p.hdb_household_share
)

SELECT *
FROM metrics;



--Q13. Which sites provide the fastest payback?

SELECT
    site_id,
    planning_area,
    initial_investment_sgd,
    projected_annual_ebitda_sgd,
    projected_payback_years
FROM candidate_sites
ORDER BY projected_payback_years ASC;

















    





 

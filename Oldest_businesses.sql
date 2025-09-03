/* ============================================================
   Project: Oldest Businesses Analysis
   Description: SQL queries exploring the history of businesses 
   across continents, categories, and datasets.
   ============================================================ */


/* ------------------------------------------------------------
   Q1. What is the oldest business on each continent?
   - Join businesses with countries to get continent info.
   - For each continent, find the business with the earliest 
     year_founded using MIN().
   - Return business name, founding year, country, and continent.
------------------------------------------------------------- */
SELECT A.business, A.year_founded, A.country, A.continent
FROM (
    SELECT business, year_founded, country, continent
    FROM businesses
    INNER JOIN countries USING(country_code)
) AS A
JOIN (
    SELECT continent, MIN(year_founded) AS year_founded
    FROM businesses
    INNER JOIN countries USING(country_code)
    GROUP BY continent
) AS B
ON A.continent = B.continent 
AND A.year_founded = B.year_founded
ORDER BY year_founded ASC;


/* ------------------------------------------------------------
   Q2. How many countries per continent lack data on the oldest 
       businesses? 
   - Check if any countries have no businesses recorded.
   - Extend analysis by including `new_businesses` data with UNION.
   - Count how many such countries exist per continent.
------------------------------------------------------------- */
SELECT continent, COUNT(countries.country) AS countries_without_businesses
FROM countries
LEFT JOIN (
    SELECT * FROM businesses
    UNION ALL
    SELECT * FROM new_businesses
) AS all_businesses
ON countries.country_code = all_businesses.country_code
WHERE all_businesses.business IS NULL
GROUP BY continent;


/* ------------------------------------------------------------
   Q3. Which business categories are best suited to last over 
       the course of centuries? 
   - Join businesses with categories and countries.
   - For each continent–category pair, find the earliest 
     year_founded.
   - Helps identify industries with the longest-lasting businesses.
------------------------------------------------------------- */
SELECT 
    countries.continent, 
    categories.category, 
    MIN(businesses.year_founded) AS year_founded
FROM businesses
INNER JOIN categories
    ON businesses.category_code = categories.category_code
INNER JOIN countries
    ON businesses.country_code = countries.country_code
GROUP BY countries.continent, categories.category
ORDER BY countries.continent, categories.category ASC;

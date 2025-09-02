
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
   - Extend analysis by includ

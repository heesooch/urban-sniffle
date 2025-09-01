-- Q1. Table considered: <baristacoffeesalesTBL>  
-- How many product categories are there?
-- For each product category, show the number of records.

/*The query below first checks how many unique product categories exist in the baristacoffeesalestbl table using COUNT(DISTINCT ...).
It then groups the data by product_category and counts the number of records in each group.
This gives both the total count of categories and the distribution of records across those categories.
The output makes it easy to see not only how many categories there are but also how many sales records fall under each one.*/

SELECT COUNT(DISTINCT(product_category)) AS count_of_prod_categories
FROM baristacoffeesalestbl;
# Number of product categories

SELECT product_category, COUNT(product_category) AS prod_num_records
FROM baristacoffeesalestbl
group by product_category;
# Number of records for each product category

-- Q2 For each customer_gender and loyalty_member type, show the number of records. 
-- within the same outcome, within each customer_gender and loyalty_member type, 
-- for each is_repeat_customer type, show the number of records.

/*The query groups records by customer gender, loyalty membership, and repeat-customer status.
It uses a window function with PARTITION BY to calculate the total number of records for each gender–loyalty group.
At the same time, it applies a regular COUNT() to show how many records belong to each repeat-customer category within those groups.
The results are then sorted by gender, loyalty status, and repeat flag for clarity*/

SELECT 
    customer_gender,
    loyalty_member,
    SUM(COUNT(*)) OVER (
        PARTITION BY customer_gender, loyalty_member
    ) as records,
    is_repeat_customer,
    COUNT(is_repeat_customer) as records
FROM baristacoffeesalestbl
GROUP BY customer_gender, loyalty_member, is_repeat_customer
ORDER BY 
    customer_gender ASC,
    loyalty_member,
    is_repeat_customer;



-- Q3 Table considered: <baristacoffeesalesTBL> 
-- For each product_category and customer_discovery_source, 
-- display the sum of total_amount.

/*The essential difference between output A and B is in how we deal with the total_sales column data, 
In Version A, rounding is applied each transaction amount before summation, leading to potential cumulative error. 
Version B aggregates the raw values without any rounding, thereby preserving full precision. 
As a result, Version B is the more accurate method for analytical use However, version A is a display/rounding requirement. .*/

#A
select product_category, customer_discovery_source, sum(convert(total_amount, decimal)) total_sales
from baristacoffeesalestbl
group by product_category, customer_discovery_source
order by product_category asc;


#B
select product_category, customer_discovery_source, sum(total_amount) total_sales
from baristacoffeesalestbl
group by product_category, customer_discovery_source
order by product_category asc;


-- Q4 Tables considered: <caffeine_intake_tracker> 
-- Consider consuming coffee as the beverage, for each time_of_day category and gender, 
-- display the average focus_level and average sleep_quality.
-- Calculate average focus level and sleep quality by time of day and gender

/*The query below shows the average focus level and average sleep quality of coffee drinkers, broken down by time of day (morning, afternoon, evening) and gender (male, female).
It does this by running six separate queries for each time-of-day and gender combination, then combines them with UNION.
Each subquery filters only the rows where coffee was consumed at that time and by that gender.
The results give a clear comparison of how focus and sleep quality vary by gender and time of day for coffee drinkers.*/

(
	select "morning" as time_of_day, "female" as gender, avg(convert(focus_level, decimal)) as avg_focus_level, avg(convert(sleep_quality, decimal)) as avg_sleep_quality
	from caffeine_intake_tracker
	where time_of_day_morning = "true" and gender_female = "true" and beverage_coffee = "true"
)
union
(
	select "morning" as time_of_day, "male" as gender, avg(convert(focus_level, decimal)) as avg_focus_level, avg(convert(sleep_quality, decimal)) as avg_sleep_quality
	from caffeine_intake_tracker
	where time_of_day_morning = "true" and gender_male = "true" and beverage_coffee = "true"
)
union
(
	select "afternoon" as time_of_day, "female" as gender, avg(convert(focus_level, decimal)) as avg_focus_level, avg(convert(sleep_quality, decimal)) as avg_sleep_quality
	from caffeine_intake_tracker
	where time_of_day_afternoon = "true" and gender_female = "true" and beverage_coffee = "true"
)
union
(
	select "afternoon" as time_of_day, "male" as gender, avg(convert(focus_level, decimal)) as avg_focus_level, avg(convert(sleep_quality, decimal)) as avg_sleep_quality
	from caffeine_intake_tracker
	where time_of_day_afternoon = "true" and gender_male = "true" and beverage_coffee = "true"
)
union
(
	select "evening" as time_of_day, "female" as gender, avg(convert(focus_level, decimal)) as avg_focus_level, avg(convert(sleep_quality, decimal)) as avg_sleep_quality
	from caffeine_intake_tracker
	where time_of_day_evening = "true" and gender_female = "true" and beverage_coffee = "true"
)
union
(
	select "evening" as time_of_day, "male" as gender, avg(convert(focus_level, decimal)) as avg_focus_level, avg(convert(sleep_quality, decimal)) as avg_sleep_quality
	from caffeine_intake_tracker
	where time_of_day_evening = "true" and gender_male = "true" and beverage_coffee = "true"
);


-- Q5 Tables considered: <list_coffee_shops_in_kota_bogor> 
-- There are problems with the data in this table. 
-- List out the problematic records.

/*There's repeated data as shown in the URL and Location Name across the records. I have queried below to show the duplicated records by location_name and the count especially those 
that have more than 1 record of data. By making use of group by for location_name, I have combined the records. For better analysis, it's always good to remove any redundant date like these.*/

select location_name, count(*)
from list_coffee_shops_in_kota_bogor
group by location_name
having count(*) > 1;


-- Q6 Tables considered: <coffeesales> 
-- List the amount of spending (money) recorded before 12 and after 12.
-- Before 12 is defined as the time between 0 and < 12 hours.
-- After 12 is defined as the time between =12 and <24 hours.*/

/* This query calculates the total spending before noon (0–11 hours) and after noon (12–23 hours).  
Some records in the dataset contain invalid time values (e.g., '46:33:00', '48:14:06'), which exceed the 24-hour format.  
To address this, the datetime strings are first converted into a proper time format, and rows that cannot be parsed are excluded.  
The data is then grouped into two periods, and the money values are summed to 2 decimalp points for accuracy. .*/

(
	select "Before 12" as period, sum(convert(money, decimal(4, 2))) as amt
	from
	(
		select hour(convert(datetime, time)) as the_hour, cash_type, card, money, coffee_name
		from coffeesales
	) as T1
	where the_hour >= 0 and the_hour < 12
)
union
(
	select "Before 12" as period, sum(convert(money, decimal(4, 2))) as amt
	from
	(
		select hour(convert(datetime, time)) as the_hour, cash_type, card, money, coffee_name
		from coffeesales
	) as T1
	where the_hour >= 12 and the_hour < 24
);


/*Q7 Consider 7 categories of Ph values
-	pH >= 0.0 && pH < 1.0
-	pH >= 1.0 && pH < 2.0
-	pH >= 2.0 && pH < 3.0
-	pH >= 3.0 && pH < 4.0
-	pH >= 4.0 && pH < 5.0
-	pH >= 5.0 && pH < 6.0
-	pH >= 6.0 && pH < 7.0
For each category of Ph values, show the average Liking, FlavorIntensity, Acidity, and Mouthfeel.*/


/* The query divides continuous pH values into seven fixed ranges (0–1, 1–2, …, 6–7).  
For each range, it calculates the average values of Liking, Flavor Intensity, Acidity, and Mouthfeel.  
This is implemented by running seven individual subqueries (one per range) and combining them with UNION.  
If a range has no observations, that subquery will not return a row, so only the ranges present in the data (e.g., 4–5 and 5–6) appear in the final result.  
The output allows us to compare sensory characteristics across different pH levels. */

(
	select "0 to 1" as Ph, convert(avg(Liking), decimal(4,2)) as avgLiking, round(avg(flavorintensity),2) as avgFlavorIntensity, 
	round(avg(acidity), 2) as avgAcidity, round(avg(mouthfeel), 2) as avgMouthFeel
	from consumerpreference
	where pH >= 0 and pH < 1.0
)
union
(
	select "1 to 2" as Ph, convert(avg(Liking), decimal(4,2)) as avgLiking, round(avg(flavorintensity),2) as avgFlavorIntensity, 
	round(avg(acidity), 2) as avgAcidity, round(avg(mouthfeel), 2) as avgMouthFeel
	from consumerpreference
	where pH >= 1.0 and pH < 2.0
)
union
(
	select "2 to 3" as Ph, convert(avg(Liking), decimal(4,2)) as avgLiking, round(avg(flavorintensity),2) as avgFlavorIntensity, 
	round(avg(acidity), 2) as avgAcidity, round(avg(mouthfeel), 2) as avgMouthFeel
	from consumerpreference
	where pH >= 2.0 and pH < 3.0
)
union
(
	select "3 to 4" as Ph, convert(avg(Liking), decimal(4,2)) as avgLiking, round(avg(flavorintensity),2) as avgFlavorIntensity, 
	round(avg(acidity), 2) as avgAcidity, round(avg(mouthfeel), 2) as avgMouthFeel
	from consumerpreference
	where pH >= 3.0 and pH < 4.0
)
union
(
	select "4 to 5" as Ph, convert(avg(Liking), decimal(4,2)) as avgLiking, round(avg(flavorintensity),2) as avgFlavorIntensity, 
	round(avg(acidity), 2) as avgAcidity, round(avg(mouthfeel), 2) as avgMouthFeel
	from consumerpreference
	where pH >= 4.0 and pH <5.0
)
union
(
	select "5 to 6" as Ph, convert(avg(Liking), decimal(4,2)) as avgLiking, round(avg(flavorintensity),2) as avgFlavorIntensity, 
	round(avg(acidity), 2) as avgAcidity, round(avg(mouthfeel), 2) as avgMouthFeel
	from consumerpreference
	where pH >= 5.0 and pH <6.0
)
union
(
	select "6 to 7" as Ph, convert(avg(Liking), decimal(4,2)) as avgLiking, round(avg(flavorintensity),2) as avgFlavorIntensity, 
	round(avg(acidity), 2) as avgAcidity, round(avg(mouthfeel), 2) as avgMouthFeel
	from consumerpreference
	where pH >= 6.0 and pH <7.0
);



-- Q8. 

/* Below query generates a monthly “Top 3” leaderboard of coffee shops by combining 
   data from four tables: 
     - coffeesales 
     - top-rated-coffee 
     - list_coffee_shops_in_kota_bogor 
     - baristacoffeesalestbl 

   For each month from March to July, it calculates:  
     • total sales (SUM of money),  
     • number of transactions (COUNT), and  
     • average Agtron score.  

   Within each month, stores are ranked by total sales and only the top three are selected.  
   The results for the five months are then combined using UNION.  

   Because the months are hard-coded, the query needs to be updated if additional months 
   are to be included. Minor differences from the expected output may arise due to 
   factors such as data cleaning, parsing issues, or duplicate records. Overall, the  
   logic of my query correctly follows the requirements of showing the top three stores by sales 
   for each month. */


(
	select "MAR" as trans_month, store_id, store_location, location_name, AVG(CAST(agtron AS DECIMAL(10,2))) AS avg_agtron, count(*) as trans_amt,  SUM(CAST(money AS DECIMAL(10,2))) AS total_money
	from coffeesales, list_coffee_shops_in_kota_bogor, `top-rated-coffee`, baristacoffeesalestbl
	where coffeesales.coffeeID = `top-rated-coffee`.ID AND coffeesales.shopID = list_coffee_shops_in_kota_bogor.no and 
	coffeesales.customer_id = substring(baristacoffeesalestbl.customer_id, 6) and 
	extract(month from str_to_date(date, '%d/%m/%y')) = 3
	group by store_id, shopID, store_location, location_name
	order by sum(money) DESC
	limit 3
)
union
(
	select "APR" as trans_month, store_id, store_location, location_name, AVG(CAST(agtron AS DECIMAL(10,2))) AS avg_agtron, count(*) as trans_amt, SUM(CAST(money AS DECIMAL(10,2))) AS total_money
	from coffeesales, list_coffee_shops_in_kota_bogor, `top-rated-coffee`, baristacoffeesalestbl
	where coffeesales.coffeeID = `top-rated-coffee`.ID AND coffeesales.shopID = list_coffee_shops_in_kota_bogor.no and 
	coffeesales.customer_id = substring(baristacoffeesalestbl.customer_id, 6) and 
	extract(month from str_to_date(date, '%d/%m/%y')) = 4
	group by store_id, shopID, store_location, location_name
	order by sum(money) DESC
	limit 3
)
union
(
	select "MAY" as trans_month, store_id, store_location, location_name, AVG(CAST(agtron AS DECIMAL(10,2))) AS avg_agtron, count(*) as trans_amt, SUM(CAST(money AS DECIMAL(10,2))) AS total_money
	from coffeesales, list_coffee_shops_in_kota_bogor, `top-rated-coffee`, baristacoffeesalestbl
	where coffeesales.coffeeID = `top-rated-coffee`.ID AND coffeesales.shopID = list_coffee_shops_in_kota_bogor.no and 
	coffeesales.customer_id = substring(baristacoffeesalestbl.customer_id, 6) and 
	extract(month from str_to_date(date, '%d/%m/%y')) = 5
	group by store_id, shopID, store_location, location_name
	order by sum(money) DESC
	limit 3
)
union
(
	select "JUNE" as trans_month, store_id, store_location , location_name, AVG(CAST(agtron AS DECIMAL(10,2))) AS avg_agtron, count(*) as trans_amt, SUM(CAST(money AS DECIMAL(10,2))) AS total_money
	from coffeesales, list_coffee_shops_in_kota_bogor, `top-rated-coffee`, baristacoffeesalestbl
	where coffeesales.coffeeID = `top-rated-coffee`.ID AND coffeesales.shopID = list_coffee_shops_in_kota_bogor.no and 
	coffeesales.customer_id = substring(baristacoffeesalestbl.customer_id, 6) and 
	extract(month from str_to_date(date, '%d/%m/%y')) = 6
	group by store_id, shopID, store_location, location_name
	order by sum(money) DESC
	limit 3
)
union
(
	select "JUL" as trans_month, store_id, store_location, location_name, AVG(CAST(agtron AS DECIMAL(10,2))) AS avg_agtron, count(*) as trans_amt, SUM(CAST(money AS DECIMAL(10,2))) AS total_money
	from coffeesales, list_coffee_shops_in_kota_bogor, `top-rated-coffee`, baristacoffeesalestbl
	where coffeesales.coffeeID = `top-rated-coffee`.ID AND coffeesales.shopID = list_coffee_shops_in_kota_bogor.no and 
	coffeesales.customer_id = substring(baristacoffeesalestbl.customer_id, 6) and 
	extract(month from str_to_date(date, '%d/%m/%y')) = 7
	group by store_id, shopID, store_location, location_name
	order by sum(money) DESC
	limit 3
);


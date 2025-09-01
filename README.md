A SQL project exploring coffee sales, customer behavior, and consumer preferences through data cleaning, aggregation, and multi-table analysis.

## Data & Schema
- Tables: `coffeesales`, `baristacoffeesalestbl`, `list_coffee_shops_in_kota_bogor`, `top-rated-coffee`, `consumerpreference`
- Joins: `coffeeID` ↔ `ID`, `shopID` ↔ `no`, `customer_id` ↔ `SUBSTRING(customer_id,6)`
- Known issues handled: invalid time strings (e.g., `46:33:00`), potential duplicates, nulls

## How to Run
Tested on MySQL 8.x.
```sql
-- from mysql client
SOURCE Coffee_SQL_Analysis.sql;


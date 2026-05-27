# Swiggy_Data_Analysis

## 1. Project Title / Headline
An end-to-end data analysis project exploring the Swiggy food delivery ecosystem. This project transforms transactional order data into actionable business intelligence, focusing on culinary performance, regional demand, and customer satisfaction metrics.

## 2. Short Description / Purpose
The Swiggy Data Analysis Project is an integrated solution designed to uncover patterns in food delivery data. By processing multiple dimension tables (Date, Location, Restaurant, Dish) and a central Fact table (Orders), this project enables deep-dive analytics into revenue trends, top-performing restaurants, and category-wise dish popularity.

## 3. Tech Stack
This project leverages the following technologies:
- **Power BI Desktop** - Core visualization engine for creating interactive dashboards and monitoring KPIs.
- **DAX (Data Analysis Expressions)** - Development of business logic for measures such as Total Revenue, Average Rating, and order-volume distributions.
- **Data Modeling** - Relational schema modeling connecting orders to geographic, temporal, and culinary dimensions.
- **Power Query** - Data transformation and ETL processes for raw transactional records.
- **PostgreSQL**  - Used to write queries, join tables, and calculate complex metric calculation
- **File Types** – `.pbix`, `.sql`,`.csv`

## 4. Data Source
**Source**: Swiggy Simulated Sales Dataset (2025)
**Location**: India
**Key Fields**: 
- fact_orders: Central transactional data
- dim_date: Temporal mapping for seasonality and trend analysis.
- dim_location: Geographic breakdown by State, City, and Local Area.
- dim_dish: Menu categorization (Category, Dish Name).
- dim_restaurant: Restaurant identification and entity mapping.

## 5. Features / Highlights
### • Business Problem
The project provides visibility into high-frequency food delivery operations, addressing the need for data-driven insights into regional performance variances, menu optimization, and overall customer satisfaction.

### • Goal of the Dashboard
To provide a structured analytical framework for:
- Monitoring revenue growth and order volume trends.
- Identifying "Hero Dishes" and top-performing restaurant chains.
- Analyzing geographic order density to understand regional market behavior.
- Evaluating customer satisfaction through rating count and score distribution.

### • Key Analytics and Metrics
**Business KPIs**
- Total Revenue: Measured in INR Millions.
- Order Throughput: Count of total orders processed.
- Satisfaction Indices: Average rating scores and rating-count frequency.
- Pricing Dynamics: Average price per dish and price-range order distributions.

**Performance Trends**
- Time-Series Analysis: Monthly and quarterly volume trends using dim_date.
- Day-of-Week Patterns: Identifying peak order velocity to optimize logistics.
- Regional Insights: State and City-level revenue contribution.

**Culinary & Restaurant Performance**
- Category Popularity: Ranking categories (e.g., North Indian, Snacks) by total orders.
- Dish Ranking: Identifying most popular menu items.
- Restaurant Leaders: Ranking top-order generating restaurants.

### Business Impact & Insights
- Optimized Inventory/Prep: By identifying top categories and peak days, restaurants can better manage demand.
- Strategic Expansion: Geographic insights help identify under-served cities versus high-density markets.
- Sentiment Analysis: Correlating ratings with specific dishes highlights quality control opportunities for restaurant partners.
- Pricing Strategy: Price-range segmentation assists in developing effective promotional bundles.

## 6. SQL Logic & Insights

Checking for Duplicate Values
```sql
select o.order_id,l.state,l.city,l.location,d.order_date,r.restaurant_name,di.category,di.dish_name,o.price,o.rating,o.rating_count,count(*) as occurance
from fact_orders o
join dim_location l on o.location_id = l.location_id
join dim_date d on o.date_id = d.date_id
join dim_dish di on o.food_id = di.dish_id
join dim_restaurant r on o.restaurant_id = r.restaurant_id
group by o.order_id,l.state,l.city,l.location,d.order_date,r.restaurant_name,di.category,di.dish_name,o.price,o.rating,o.rating_count
having count(*) > 1;
```
Overall Table
```sql
select o.order_id,l.state,l.city,l.location,d.order_date,r.restaurant_name,di.category,di.dish_name,o.price,o.rating,o.rating_count
from fact_orders o
join dim_location l on o.location_id = l.location_id
join dim_date d on o.date_id = d.date_id
join dim_dish di on o.food_id = di.dish_id
join dim_restaurant r on o.restaurant_id = r.restaurant_id
```
```sql
SELECT marital_status,count(*) as patients_as_marital_status
FROM [hospital_db].[dbo].[patients]
GROUP BY marital_status;
```
KPI
1. Total Orders
```sql
select count(order_id) as total_orders
from fact_orders;
```

2. Total Revenue (inr millon)
```sql
select concat(round(sum(price)/1000000,2),' INR Million') as total_revenue
from fact_orders;
```

3. Avg Dish Price
```sql
select concat(round(avg(price),2),' INR') as avg_dish_price
from fact_orders;
```

4. Avg Rating
```sql
select round(avg(rating),2) as avg_rating
from fact_orders;
```

Date Based Analysis
1. Monthly Order Trends
```sql
select 
	extract (year from order_date) as year,
	extract (month from order_date) as month,
	to_char(order_date::DATE, 'Month') as month_name,
	count(order_id) as total_orders
from fact_orders f 
join dim_date d on f.date_id = d.date_id
group by year,month,month_name
order by total_orders desc
```

2. Quarterly Order Trends
```sql
select 
	extract (year from order_date) as year,
	extract (quarter from order_date) as quarter,
	count(order_id) as total_orders
from fact_orders f 
join dim_date d on f.date_id = d.date_id
group by year,quarter
order by total_orders desc
```

3. Year Wise Growth
```sql
select 
	extract (year from order_date) as year,
	count(order_id) as total_orders
from fact_orders f 
join dim_date d on f.date_id = d.date_id
group by year
order by total_orders desc
```

4. Day of Week Patterns
```sql
select 
	to_char(order_date, 'FMDay') as days_of_week,
	count(order_id) as total_orders
from fact_orders f 
join dim_date d on f.date_id = d.date_id
group by days_of_week
order by total_orders desc
```

Location Based Analysis
1. Top 10 Cities by Order Volume
```sql
select 
	city,
	count(order_id) as total_volume
from fact_orders f
join dim_location l on f.location_id = l.location_id
group by city
order by total_volume desc
limit 10;
```

2. Revenue Contribution by States
```sql
select 
	state,
	sum(price) as revenue_by_state
from fact_orders f
join dim_location l on f.location_id = l.location_id
group by state
order by revenue_by_state desc;
```

Food Performance
1. Top 10 Resturants by Orders
```sql
select 
	restaurant_name,
	count(order_id) as total_orders
from fact_orders f
join dim_restaurant r on f.restaurant_id = r.restaurant_id
group by restaurant_name
order by total_orders desc
limit 10;
```

2. Top Categories
```sql
select 
	category,
	count(order_id) as total_orders
from fact_orders f
join dim_dish di on f.food_id = di.dish_id
group by category
order by total_orders desc
limit 10;
```

3. Most Ordered Dishes
```sql
select 
	dish_name,
	count(order_id) as total_orders
from fact_orders f
join dim_dish di on f.food_id = di.dish_id
group by dish_name
order by total_orders desc
limit 10;
```

4. Cuisine Performance
```sql
select 
	category,
	count(order_id) as total_orders,
	round(avg(rating),2) as avg_rating
from fact_orders f
join dim_dish di on f.food_id = di.dish_id
group by category
order by total_orders desc;
```

5. Total Orders by Price Range
```sql
select
	case
		when price < 100 then 'Under 100'
		when price between 100 and 199 then '100 - 199'
		when price between 200 and 299 then '200 - 299'
		when price between 300 and 399 then '300 - 399'
		when price between 400 and 499 then '400 - 499'
		else 'Over 500'
	end as price_range,
	count(order_id) as total_orders
from fact_orders
group by price_range
order by total_orders desc;
```

6. Rating Count Distribution
```sql
select
	case
		when price < 100 then 'Under 100'
		when price between 100 and 199 then '100 - 199'
		when price between 200 and 299 then '200 - 299'
		when price between 300 and 399 then '300 - 399'
		when price between 400 and 499 then '400 - 499'
		else 'Over 500'
	end as price_range,
	count(order_id) as total_orders
from fact_orders
group by price_range
order by total_orders desc;
```

## 7. Screenshots / Demos
![https://github.com/l2Aquel/Healthcare-Data-Analysis/blob/main/Dashboard_preview.png](Dashboard_preview.png)
![https://github.com/l2Aquel/Healthcare-Data-Analysis/blob/main/Data_Model.png](Data_Model.png)
![https://github.com/l2Aquel/Healthcare-Data-Analysis/blob/main/SqlServerManagementStudio.png](SqlServerManagementStudio.png)
    


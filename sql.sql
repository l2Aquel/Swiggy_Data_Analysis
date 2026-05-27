select o.order_id,l.state,l.city,l.location,d.order_date,r.restaurant_name,di.category,di.dish_name,o.price,o.rating,o.rating_count,count(*) as occurance
from fact_orders o
join dim_location l on o.location_id = l.location_id
join dim_date d on o.date_id = d.date_id
join dim_dish di on o.food_id = di.dish_id
join dim_restaurant r on o.restaurant_id = r.restaurant_id
group by o.order_id,l.state,l.city,l.location,d.order_date,r.restaurant_name,di.category,di.dish_name,o.price,o.rating,o.rating_count
having count(*) > 1;

--TABLE
select o.order_id,l.state,l.city,l.location,d.order_date,r.restaurant_name,di.category,di.dish_name,o.price,o.rating,o.rating_count
from fact_orders o
join dim_location l on o.location_id = l.location_id
join dim_date d on o.date_id = d.date_id
join dim_dish di on o.food_id = di.dish_id
join dim_restaurant r on o.restaurant_id = r.restaurant_id


--KPI
--total orders
select count(order_id) as total_orders from fact_orders;

--total revenue (inr millon)
select concat(round(sum(price)/1000000,2),' INR Million') as total_revenue from fact_orders;

--avg dish price
select concat(round(avg(price),2),' INR') as avg_dish_price from fact_orders;

--avg rating
select round(avg(rating),2) as avg_rating from fact_orders;


--Date Based Analysis
--monthly order trends
select 
	extract (year from order_date) as year,
	extract (month from order_date) as month,
	to_char(order_date::DATE, 'Month') as month_name,
	count(order_id) as total_orders
from fact_orders f 
join dim_date d on f.date_id = d.date_id
group by year,month,month_name
order by total_orders desc

--quarterly order trends
select 
	extract (year from order_date) as year,
	extract (quarter from order_date) as quarter,
	count(order_id) as total_orders
from fact_orders f 
join dim_date d on f.date_id = d.date_id
group by year,quarter
order by total_orders desc

--year wise growth
select 
	extract (year from order_date) as year,
	count(order_id) as total_orders
from fact_orders f 
join dim_date d on f.date_id = d.date_id
group by year
order by total_orders desc

--day of week patterns
select 
	to_char(order_date, 'FMDay') as days_of_week,
	count(order_id) as total_orders
from fact_orders f 
join dim_date d on f.date_id = d.date_id
group by days_of_week
order by total_orders desc

--Location Based Analysis
--top 10 cities by order volume
select 
	city,
	count(order_id) as total_volume
from fact_orders f
join dim_location l on f.location_id = l.location_id
group by city
order by total_volume desc
limit 10;

--revenue contribution by states
select 
	state,
	sum(price) as revenue_by_state
from fact_orders f
join dim_location l on f.location_id = l.location_id
group by state
order by revenue_by_state desc;

--Food Performance
--top 10 resturants by orders
select 
	restaurant_name,
	count(order_id) as total_orders
from fact_orders f
join dim_restaurant r on f.restaurant_id = r.restaurant_id
group by restaurant_name
order by total_orders desc
limit 10;

--top categories
select 
	category,
	count(order_id) as total_orders
from fact_orders f
join dim_dish di on f.food_id = di.dish_id
group by category
order by total_orders desc
limit 10;

--most ordered dishes
select 
	dish_name,
	count(order_id) as total_orders
from fact_orders f
join dim_dish di on f.food_id = di.dish_id
group by dish_name
order by total_orders desc
limit 10;

--cuisine performance
select 
	category,
	count(order_id) as total_orders,
	round(avg(rating),2) as avg_rating
from fact_orders f
join dim_dish di on f.food_id = di.dish_id
group by category
order by total_orders desc;

--total orders by price range
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

--rating count distribution
select
	rating,
	count(rating) as total_ratings
from fact_orders
group by rating
order by total_ratings desc;

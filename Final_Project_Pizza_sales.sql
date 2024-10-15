-- Now I have to import all the csv file to my Database SQL_Pizza_sales 


--create a pizzas table with same column value and name
create table pizzas (
pizza_id varchar(50) primary key,
pizza_type_id varchar(50) not null,
size char(8) not null,
price float(9) not null
);

--import pizzas csv file
copy pizzas(pizza_id, pizza_type_id, size, price)
from 'C:\pizzas.csv'
delimiter ','
csv header;


--create a pizza_types table with same column value and name
create table pizza_types(
       pizza_type_id varchar(50) primary key,
	   name varchar(50) not null,
	   category varchar(50) not null,
	   ingredients varchar(255) not null
 
);

--i have modified the igredients column
alter table pizza_types
alter column ingredients type text;

--import pizza_types csv file
copy pizza_types(pizza_type_id, name, category, ingredients)
from 'C:\SQL_Pizzasale\pizza_sales\pizza_types.csv'
delimiter ','
csv header;



--create a orders table with same column value and name
create table orders(
        order_id int8 primary key,
		date DATE NOT NULL,
		time TIME NOT NULL
);

--import orders csv file
COPY orders(order_id, date, time)
from 'C:\SQL_Pizzasale\pizza_sales\orders.csv'
delimiter ','
csv header;

--create a order_details table with same column value and name
create table order_details(
       order_details_id int8 primary key,
	   order_id int8 not null,
	   pizza_id varchar(250) not null,
	   quantity int8 not null
);

--import orders csv file
COPY order_details(order_details_id, order_id, pizza_id, quantity)
from 'C:\SQL_Pizzasale\pizza_sales\order_details.csv'
delimiter ','
csv header;


--Retrieve the total number of orders placed.
select count(order_id) as total_order_placed
from orders


--Calculate the total revenue generated from pizza sales.

select *from order_details
select *from pizzas

select sum(pizzas.price*order_details.quantity) as total_revenue
from pizzas
join order_details on pizzas.pizza_id = order_details.pizza_id;

--Identify the highest-priced pizza.

select *from pizzas

select pizzas.price as highest_price_pizza, pizza_types.name, pizza_types.category
from pizzas
join pizza_types on pizzas.pizza_type_id = pizza_types.pizza_type_id
group by pizza_types.name, pizza_types.category, highest_price_pizza
Order by highest_price_pizza desc
limit 1

--Identify the most common pizza size ordered.

select *from order_details

select pizzas.size, count(order_details.quantity) as total_count_pizza
from order_details
join pizzas on order_details.pizza_id = pizzas.pizza_id
group by pizzas.size
order by total_count_pizza desc
LIMIT 1


--List the top 5 most ordered pizza types along with their quantities.

select pizza_types.name, sum(order_details.quantity) as total_count_pizzas
from pizzas
join pizza_types on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.name
order by total_count_pizzas desc
limit 5


--Join the necessary tables to find the total quantity of each pizza category ordered.

select pizza_types.category, sum(order_details.quantity) as total_count_pizzas
from pizzas
join pizza_types on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details on pizzas.pizza_id = order_details.pizza_id
group by  pizza_types.category
order by total_count_pizzas

 
--Determine the distribution of orders by hour of the day.
select *from orders

alter table orders
rename COLUMN date to orders_date;

alter table orders
rename column time to orders_time;

select extract (HOUR from orders_time) as hour, count(order_id) as order_count
from orders
group by extract(HOUR from orders_time)
order by order_count desc;




--Group the orders by date and calculate the average number of pizzas ordered per day.

select round(avg(pizzas_per_day),0) from(
select orders.orders_date, sum(order_details.quantity) as pizzas_per_day
from orders
join order_details on orders.order_id = order_details.order_id
group by orders_date
order by orders_date
);




--Determine the top 3 most ordered pizza types based on revenue.

select * from pizza_types

select pizza_types.name, sum(pizzas.price*order_details.quantity) as total_revenue
from pizzas
join order_details on pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizzas.pizza_type_id = pizza_types.pizza_type_id
group by pizza_types.name
order by total_revenue desc
limit 3;






--Determine the percentage revenue category wise 
--Calculate the percentage contribution of each pizza type to total revenue.

WITH total_revenues as (
            select sum(pizzas.price*order_details.quantity) as total_revenue
            from pizzas
           join order_details on pizzas.pizza_id = order_details.pizza_id
)

select pizza_types.category, (sum(pizzas.price*order_details.quantity)
    /(select total_revenue from total_revenues) *100) as category_wise_revenue
from pizzas
join pizza_types on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.category
order by category_wise_revenue desc




--Analyze the cumulative revenue generated over time.

With total_revenue as(
    select orders.orders_date as Sales_date, sum(order_details.quantity*pizzas.price) as revenue
	from pizzas
	join order_details on pizzas.pizza_id = order_details.pizza_id
	join orders on order_details.order_id = orders.order_id
	group by Sales_date
	order by Sales_date
)

select sales_date, sum(revenue) over(order by sales_date)
from total_revenue




--Analyze the cumulative revenue generated over time.(2nd Menthod)

select orders_date,
sum(revenue) over(order by orders_date) as cum_revenue
from
(select orders.orders_date,
sum (order_details.quantity*pizzas.price)as revenue
from order_details join pizzas
on order_details.pizza_id= pizzas.pizza_id
join orders 
on orders.order_id = order_details.order_id
group by orders.orders_date) as sales;

--Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select pizza_types.category, sum(pizzas.price*order_details.quantity) as revenue
from pizza_types
join pizzas on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.category
order by pizza_types.category
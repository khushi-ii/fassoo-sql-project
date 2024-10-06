create database fasso;
use fasso;
drop table if exists driver;
CREATE TABLE driver(driver_id integer,reg_date date); 

INSERT INTO driver(driver_id, reg_date) 
VALUES (1, '2021-01-01'),
       (2, '2021-01-03'),
       (3, '2021-01-08'),
       (4, '2021-01-15');



drop table if exists ingredients;
CREATE TABLE ingredients(ingredients_id integer,ingredients_name varchar(60)); 

INSERT INTO ingredients(ingredients_id ,ingredients_name) 
 VALUES (1,'BBQ Chicken'),
(2,'Chilli Sauce'),
(3,'Chicken'),
(4,'Cheese'),
(5,'Kebab'),
(6,'Mushrooms'),
(7,'Onions'),
(8,'Egg'),
(9,'Peppers'),
(10,'schezwan sauce'),
(11,'Tomatoes'),
(12,'Tomato Sauce');

drop table if exists rolls;
CREATE TABLE rolls(roll_id integer,roll_name varchar(30)); 

INSERT INTO rolls(roll_id ,roll_name) 
 VALUES (1	,'Non Veg Roll'),
(2	,'Veg Roll');

drop table if exists rolls_recipes;
CREATE TABLE rolls_recipes(roll_id integer,ingredients varchar(24)); 

INSERT INTO rolls_recipes(roll_id ,ingredients) 
 VALUES (1,'1,2,3,4,5,6,8,10'),
(2,'4,6,7,9,11,12');

drop table if exists driver_order;
CREATE TABLE driver_order(order_id integer,driver_id integer,pickup_time datetime,distance VARCHAR(7),duration VARCHAR(10),cancellation VARCHAR(23));
INSERT INTO driver_order(order_id, driver_id, pickup_time, distance, duration, cancellation) 
VALUES
(1, 1, '2021-01-01 18:15:34', 20, '32 minutes', null),
(2, 1, '2021-01-01 19:10:54', 20, '27 minutes', null),
(3, 1, '2021-01-03 00:12:37', 13.4, '20 minutes', null),
(4, 2, '2021-01-04 13:53:03', 23.4, '40 minutes', null),
(5, 3, '2021-01-08 21:10:57', 10, '15 minutes', null),
(6, 3, null, null, null, 'Cancellation'),
(7, 2, '2020-01-08 21:30:45', 25, '25 minutes', null),
(8, 2, '2020-01-10 00:15:02', 23.4, '15 minutes', null),
(9, 2, null, null, null, 'Customer Cancellation'),
(10, 1, '2020-01-11 18:50:20', 10, '10 minutes', null);


drop table if exists customer_orders;
CREATE TABLE customer_orders(order_id integer,customer_id integer,roll_id integer,not_include_items VARCHAR(4),extra_items_included VARCHAR(4),order_date datetime);
INSERT INTO customer_orders(order_id, customer_id, roll_id, not_include_items, extra_items_included, order_date)
VALUES 
(1, 101, 1, null, null, '2021-01-01 18:05:02'),
(2, 101, 1, null, null, '2021-01-01 19:00:52'),
(3, 102, 1, null, null, '2021-01-02 23:51:23'),
(4, 102, 2, null, null, '2021-01-02 23:51:23'),
(5, 103, 1, '4', null, '2021-01-04 13:23:46'),
(6, 103, 2, '4', null, '2021-01-04 13:23:46'),
(7, 104, 1, null, '1', '2021-01-08 21:00:29'),
(8, 101, 2, null, null, '2021-01-08 21:03:13'),
(9, 105, 2, null, '1', '2021-01-08 21:20:29'),
(10, 102, 1, null, null, '2021-01-09 23:54:33'),
(11, 103, 1, '4', '1,5', '2021-01-10 11:22:59'),
(12, 104, 1, null, null, '2021-01-11 18:34:49'),
(13, 104, 1, '2,6', '1,4', '2021-01-11 18:34:49');


select * from customer_orders;
select * from driver_order;
select * from ingredients;
select * from driver;
select * from rolls;
select * from rolls_recipes;
-- 1.how many rolls were orders?
select count(roll_id) as total_rolls from customer_orders;

-- 2. how many unique order customers were made?
select count(distinct(customer_id)) as cust from customer_orders;

-- 3. how many successful orders were deivered by each deriver
SELECT driver_id, COUNT(DISTINCT(order_id)) AS total_orders
FROM driver_order
WHERE (cancellation IS NULL OR LOWER(cancellation) NOT IN ('cancellation', 'customer cancellation'))
GROUP BY driver_id;

-- or

SELECT driver_id, COUNT(DISTINCT(order_id)) AS total_orders
FROM driver_order
WHERE (cancellation IS NULL OR 
       LOWER(cancellation) NOT LIKE '%cancellation%' 
       AND LOWER(cancellation) NOT LIKE '%customer cancellation%')
GROUP BY driver_id;



-- 4 how many each type of roll delivered

WITH cte AS (
  SELECT * 
  FROM driver_order 
  WHERE cancellation IS NULL 
    OR LOWER(cancellation) NOT IN ('cancellation', 'customer cancellation')
)
SELECT co.roll_id, COUNT(co.roll_id) AS total_orders
FROM customer_orders co
JOIN cte ON co.order_id = cte.order_id
GROUP BY co.roll_id;

-- 5 how many veg non veg orders ordered
select a.*,rolls.roll_name from rolls join
(select roll_id,count(roll_id) from customer_orders group by roll_id ) a
on a.roll_id=rolls.roll_id;


-- 6 max nos of rolle delivered in a single order
SELECT co.order_id, COUNT(co.roll_id) 
FROM customer_orders co
WHERE co.order_id IN (
  SELECT do.order_id 
  FROM driver_order do
  WHERE do.cancellation IS NULL 
    OR LOWER(do.cancellation) NOT IN ('cancellation', 'customer cancellation')
)
GROUP BY co.order_id;
 
 
 --  how many customers had atleast 1 change or no change
 
 CREATE TEMPORARY TABLE temp_table_name3 (
order_id integer,customer_id integer,roll_id integer,not_include_items VARCHAR(4),extra_items_included VARCHAR(4),order_date datetime
);
INSERT INTO temp_table_name3 (order_id, customer_id, roll_id, not_include_items, extra_items_included, order_date)
SELECT order_id,customer_id,roll_id,
       CASE WHEN not_include_items IS NULL OR TRIM(not_include_items) = '' THEN 0 ELSE not_include_items END AS new_not_included_items,
       CASE WHEN extra_items_included IS NULL OR TRIM(extra_items_included) = '' OR extra_items_included = 'NAN' THEN 0 ELSE extra_items_included END AS new_extra_items_included,
       order_date
FROM customer_orders;

select customer_id from temp_table_name3;


 CREATE TEMPORARY TABLE temp_table_name4 (
order_id integer,driver_id integer,pickup_time datetime,distance VARCHAR(7),duration VARCHAR(10),cancellation VARCHAR(23)
);
INSERT INTO temp_table_name4 (order_id, driver_id,pickup_time,distance,duration,cancellation)
SELECT order_id, driver_id, pickup_time, distance, duration,
       CASE WHEN cancellation IN ('cancellation', 'customer cancellation') THEN 0 ELSE 1 END AS new_cancellation
FROM driver_order;

select customer_id,chg_no_chg from(
select *,case when not_include_items=0 and extra_items_included=0 then 'no change'else 'change' end as chg_no_chg  from temp_table_name3 where order_id in(
select order_id from temp_table_name4 where cancellation!=0))a
group by 1,2;

-- how many rolls were ordered each hour of the day
select hr_bw,count(hr_bw) from (
select concat(hour(order_date),'-',hour(order_date)+1)as hr_bw from customer_orders)a
group by 1;

-- how many rolls were ordered each day of the week
SELECT dow, COUNT(DISTINCT order_id) AS order_count
FROM (
    SELECT 
        DAYNAME(date(order_date)) AS dow,
        order_id
    FROM 
        customer_orders
) AS a
GROUP BY dow;


-- avg time took by each driver to arrive at fassoo to pickup
select
(select c.*,d.*,TIMESTAMPDIFF(MINUTE,order_date, pickup_time) AS difference_in_mins from customer_orders c join driver_order d on c.order_id=d.order_id
where d.pickup_time !=0);



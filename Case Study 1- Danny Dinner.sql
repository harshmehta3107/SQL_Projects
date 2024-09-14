CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  --What is the total amount each customer spent at the restaurant?
  
  select a.customer_id,
  sum(b.price) "Amount_Spent"
  from sales a 
  join menu b
  on a.product_id = b.product_id
  group by customer_id;
  
  --How many days has each customer visited the restaurant?
  
  select customer_id,
 count( distinct order_date ) "No_of_days_customer_visited"
 from sales 
 group by customer_id;
 
 --What was the first item from the menu purchased by each customer?
 
  with t1 as(
  select a.customer_id,
  b.product_name,
  rank() over(partition by customer_id order by order_date) rankk
  from sales a
  join menu b
  on a.product_id = b.product_id)
  
  select customer_id,
  product_name
  from t1
  where rankk =1;
  
  --What is the most purchased item on the menu and how many times was it purchased by all customers?

  select b.product_name,
  count(a.product_id) "total_purchases"
  from menu b 
  join sales a
  on a.product_id = b.product_id
  group by b.product_name
  order by total_purchases desc
  limit 1;
  
select customer_id,
count(product_id)
from sales
where product_id=3
group by customer_id

--Which item was the most popular for each customer?
  
  select customer_id,
  b.product_name, count(b.product_name) "purchase_count"
  from sales a
  join menu b 
  on a.product_id = b.product_id
  group by customer_id, b.product_name;

    -- Which item was purchased first by the customer after they became a member?
  
  with cte AS(
  select s.customer_id,s.order_date,s.product_id,m.join_date,product_name,
  row_number() over(partition by customer_id) rankk
  from sales s
  left join members m 
  on s.customer_id = m.customer_id
  join menu c
  on s.product_id = c.product_id
  where order_date>=join_date)
  
  SELECT CUSTOMER_ID, product_name
  FROM CTE 
  WHERE RANKK = 1
  
--Which item was purchased just before the customer became a member?
  
  with cte as(
  select s.customer_id,s.order_date,s.product_id,m.join_date,product_name,
  rank() over(partition by customer_id order by order_date) rankk
  from sales s
  left join members m 
  on s.customer_id = m.customer_id
  join menu c
  on s.product_id = c.product_id
  where order_date<join_date)
  
  select customer_id, product_name
  from cte 
  where rankk = 1
  
  
  What is the total items and amount spent for each member before they became a member?
   
   select a.customer_id, count(distinct a.product_id) total_product,
   sum(m.price) total_spent
   from sales a
   join menu m
   on a.product_id = m.product_id
   left join members c
   on a.customer_id = c.customer_id
   where order_date<join_date
   group by customer_id;

   If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
   
   select customer_id,
   sum(case when product_name = "sushi" then 10*2*price 
        else 10*price
        end) as points
   from sales s
   join menu m
   on m.product_id = s.product_id
   group by customer_id
   
In the first week after a customer joins the program (including their join date) they earn 2x points on all items,
not just sushi - how many points do customer A and B have at the end of January?


select s.customer_id,
sum(case when product_name = "sushi" then 10*2*price 
		 when order_date between join_date and (join_date+ interval 6 day)  then 2*10*price
        else 10*price
        end) as points
from sales s
join members m
on s.customer_id = m.customer_id
join menu c 
on s.product_id = c.product_id
and month(order_date)=1
group by customer_id;

bonus Question 1

select s.customer_id,s.order_date,m.product_name,m.price,
case when order_date>= join_date then "Y" else "N" end as "Member" 
from 
sales s
join menu m
on s.product_id = m.product_id
left join members m1 
on s.customer_id = m1.customer_id;

Bonus Question 2
with cte as(
select s.customer_id,s.order_date,m.product_name,m.price,
case when order_date>= join_date then "Y" else "N" end as "Member"
from 
sales s
join menu m
on s.product_id = m.product_id
left join members m1 
on s.customer_id = m1.customer_id)

select *,
case when member = "N" then "null"
else rank() over(partition by customer_id,member order by order_date) end as "ranking"  
from cte;



 



   
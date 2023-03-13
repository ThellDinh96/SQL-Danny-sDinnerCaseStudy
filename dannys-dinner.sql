DROP SCHEMA IF EXISTS dannys_dinner;
 CREATE SCHEMA dannys_dinner;
CREATE TABLE dannys_dinner.sales (
    customer_id VARCHAR(1),
    order_date DATE,
    product_id INT
);
INSERT INTO dannys_dinner.sales
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
SELECT * FROM dannys_dinner.sales;

CREATE TABLE dannys_dinner.menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);
INSERT INTO dannys_dinner.menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
CREATE TABLE dannys_dinner.members (
  customer_id VARCHAR(1),
  join_date DATE
);
INSERT INTO dannys_dinner.members
  (customer_id,join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  SELECT * FROM dannys_dinner.members;
  
  # 1. What is the total amount each customer spent at the restaurant?
  USE dannys_dinner;
  SELECT sales.customer_id, SUM(menu.price) AS total_spent
  FROM sales JOIN menu
  ON sales.product_id = menu.product_id
  GROUP BY sales.customer_id;
  
  # 2. How many days has each customer visited the restaurant?
  USE dannys_dinner;
  SELECT sales.customer_id, COUNT(sales.order_date) AS Days
  FROM sales
  GROUP BY sales.customer_id;
# 3. What was the first item from the menu purchased by each customer?
SELECT DISTINCT sales.customer_id, menu.product_name, sales.order_date
FROM menu JOIN sales
ON menu.product_id = sales.product_id
WHERE sales.order_date = (SELECT MIN(sales.order_date) FROM sales );

 # 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
  SELECT menu.product_name AS Product, COUNT(sales.product_id) AS "Number of Purchase"
  FROM menu JOIN sales
  ON menu.product_id = sales.product_id
  GROUP BY
  menu.product_name, sales.product_id
  ORDER BY COUNT(sales.product_id) DESC;
  
  # 5. Which item was the most popupar for each customer
  CREATE TEMPORARY TABLE best_sales
AS
  SELECT s.customer_id, m.product_name, COUNT(*) as Num_Purchased
  FROM sales s JOIN menu m
  ON s.product_id = m.product_id
 GROUP BY s.customer_id, m.product_name
 ORDER BY s.customer_id, Num_Purchased DESC;
## Based on the table above, we can get the answer as below
SELECT * FROM best_sales bs
GROUP BY bs.customer_id;

# 6. Which item was purchased first by the customer after became a member?
SELECT s.customer_id,m.product_name, s.order_date, mb.join_date
FROM sales s JOIN members mb
ON s.customer_id = mb.customer_id
JOIN menu m
ON s.product_id = m.product_id
WHERE s.order_date >= mb.join_date
GROUP BY s.customer_id
ORDER BY s.order_date ASC;

# 7. Which item was purchased just before the customer became a member?
SELECT DISTINCT s.customer_id, m.product_name, s.order_date, mb.join_date
FROM sales s 
JOIN menu m ON s.product_id = m.product_id
JOIN members mb ON s.customer_id = mb.customer_id
WHERE s.order_date < mb.join_date
ORDER BY s.customer_id;

# 8. What is the total items and amount spent for each member before they became a member?
SELECT s.customer_id, COUNT(*) AS total_items, COUNT(*) * m.price AS amount_spent
FROM sales s JOIN menu m
ON s.product_id = m.product_id
GROUP BY s.customer_id;

# 9. If each $1 spent to 10 points and sushi has a 2x points multiplier 
#- how many points would each customer have?
SELECT t.customer_id, SUM(t.total_points) AS total_points 
FROM
(SELECT s.customer_id, m.product_name, m.price, 
CASE WHEN m.product_name = 'sushi' THEN m.price * 20 ELSE m.price * 10 END AS total_points
FROM sales s JOIN menu m
ON s.product_id = m.product_id) t
GROUP BY t.customer_id;

# 10. In the first week after a customer joins the program  (including their join date) 
# they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January
USE dannys_dinner;
SELECT a.customer_id, SUM(a.total_points) AS  Jan_points
FROM
(SELECT s.customer_id, m.product_id, m.price, s.order_date, mb.join_date,
CASE WHEN m.product_name ='sushi' THEN m.price * 20 
WHEN DATEDIFF(s.order_date, mb.join_date) = 7 THEN m.price *20
ELSE m.price * 10 END as total_points
FROM sales s 
JOIN menu m ON s.product_id = m.product_id
JOIN members mb ON s.customer_id = mb.customer_id
WHERE s.order_date < '2021-01-31') a
GROUP BY a.customer_id;


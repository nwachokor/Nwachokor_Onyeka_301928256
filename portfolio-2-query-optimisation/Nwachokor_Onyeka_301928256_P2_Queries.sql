-- Portfolio 2 queries

-- Q1 Stock picking: unexpired batches with stock, earliest expiry first
SELECT batch_id, quantity, received_date, expiry_date
FROM stock_batch
WHERE product_id = 1
  AND warehouse_id = 1
  AND quantity > 0
  AND expiry_date > current_date
ORDER BY expiry_date;

-- Q2 Order history: a customer's 10 most recent orders with totals
SELECT o.order_id, o.order_date, sum(oi.quantity * oi.unit_price) AS total
FROM orders o
JOIN order_item oi ON oi.order_id = o.order_id
WHERE o.customer_id = 42
GROUP BY o.order_id, o.order_date
ORDER BY o.order_date DESC
LIMIT 10;

-- Q3 Rider workload: a rider's deliveries not yet delivered
SELECT d.delivery_id, d.order_id, d.status, d.assigned_at, o.delivery_address
FROM delivery d
JOIN orders o ON o.order_id = d.order_id
WHERE d.rider_id = 3
  AND d.status <> 'delivered'
ORDER BY d.assigned_at;

-- Q4 Daily revenue: successful payments per day, last 30 days
SELECT date(paid_at) AS day, count(*) AS payments, sum(amount) AS revenue
FROM payment
WHERE status = 'success'
  AND paid_at >= current_date - interval '30 days'
GROUP BY day
ORDER BY day;

-- Q5 Best sellers: top 10 products by units sold in the last 30 days
SELECT p.product_id, p.name, sum(oi.quantity) AS units_sold
FROM order_item oi
JOIN orders o ON o.order_id = oi.order_id
JOIN product p ON p.product_id = oi.product_id
WHERE o.order_date >= now() - interval '30 days'
GROUP BY p.product_id, p.name
ORDER BY units_sold DESC
LIMIT 10;
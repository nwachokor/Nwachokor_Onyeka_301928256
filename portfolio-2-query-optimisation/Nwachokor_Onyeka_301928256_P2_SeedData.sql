-- Meridon Store seed data (Portfolio 2)
-- Run on a freshly loaded '../portfolio-1-database-design/Nwachokor_Onyeka_301928256_P1_Schema.sql' so IDs start at 1.

BEGIN;

INSERT INTO warehouse (name, location_address) VALUES
  ('Mainland', '15 Ikorodu Road, Yaba, Lagos'),
  ('Island',   '12 Admiralty Way, Lekki, Lagos');

INSERT INTO customer (name, email, phone, delivery_address)
SELECT 'Customer ' || g,
       'customer' || g || '@example.com',
       '080' || lpad(g::text, 8, '0'),
       'Address ' || g || ', Lagos'
FROM generate_series(1, 5000) g;

INSERT INTO product (name, price, weight_g, category, species)
SELECT 'Product ' || g,
       round((random() * 20000 + 500)::numeric, 2),
       round((random() * 900 + 50)::numeric, 2),
       CASE WHEN g % 2 = 0 THEN 'human' ELSE 'pet' END,
       CASE WHEN g % 2 = 0 THEN NULL WHEN g % 4 = 1 THEN 'dog' ELSE 'cat' END
FROM generate_series(1, 200) g;

INSERT INTO stock_batch (product_id, warehouse_id, quantity, received_date, expiry_date)
SELECT p, w, (random() * 500)::int, d, d + (180 + (random() * 540)::int)
FROM (
  SELECT (g % 200) + 1 AS p,
         (g % 2) + 1 AS w,
         current_date - (random() * 365)::int AS d
  FROM generate_series(1, 2000) g
) s;

INSERT INTO staff (name, email, role, password_hash)
SELECT 'Staff ' || g, 'staff' || g || '@meridon.ng', 'admin', 'hash_placeholder_' || g
FROM generate_series(1, 5) g;

INSERT INTO rider (name, phone, status)
SELECT 'Rider ' || g, '090' || lpad(g::text, 8, '0'),
       CASE WHEN g % 10 = 0 THEN 'inactive' ELSE 'active' END
FROM generate_series(1, 20) g;

INSERT INTO orders (customer_id, warehouse_id, order_date, delivery_address)
SELECT c, (g % 2) + 1, now() - random() * interval '365 days', 'Address ' || c || ', Lagos'
FROM (SELECT g, (random() * 4999)::int + 1 AS c FROM generate_series(1, 50000) g) s;

-- 1 to 3 different products per order
INSERT INTO order_item (order_id, product_id, quantity, unit_price)
SELECT o.order_id, p.product_id, (random() * 4)::int + 1, p.price
FROM orders o
CROSS JOIN generate_series(1, 3) k
JOIN product p ON p.product_id = ((o.order_id * 7 + k * 13) % 200) + 1
WHERE k <= (o.order_id % 3) + 1;

-- 90% of orders paid successfully, 10% failed
INSERT INTO payment (order_id, amount, payment_method, status, paid_at)
SELECT o.order_id, t.total,
       CASE WHEN o.order_id % 2 = 0 THEN 'card' ELSE 'transfer' END,
       CASE WHEN o.order_id % 10 = 0 THEN 'failed' ELSE 'success' END,
       CASE WHEN o.order_id % 10 = 0 THEN NULL ELSE o.order_date + interval '5 minutes' END
FROM orders o
JOIN (SELECT order_id, sum(quantity * unit_price) AS total
      FROM order_item GROUP BY order_id) t USING (order_id);

-- deliveries only for paid orders (rule 14), at different stages
INSERT INTO delivery (order_id, rider_id, assigned_by_staff_id, status, delivery_code,
                      assigned_at, picked_up_at, delivered_at)
SELECT o.order_id, (o.order_id % 20) + 1, (o.order_id % 5) + 1,
       CASE o.order_id % 3 WHEN 0 THEN 'assigned' WHEN 1 THEN 'picked_up' ELSE 'delivered' END,
       lpad((random() * 9999)::int::text, 4, '0'),
       o.order_date + interval '1 hour',
       CASE WHEN o.order_id % 3 IN (1, 2) THEN o.order_date + interval '2 hours' END,
       CASE WHEN o.order_id % 3 = 2 THEN o.order_date + interval '5 hours' END
FROM orders o
JOIN payment p ON p.order_id = o.order_id AND p.status = 'success';

COMMIT;

ANALYZE;
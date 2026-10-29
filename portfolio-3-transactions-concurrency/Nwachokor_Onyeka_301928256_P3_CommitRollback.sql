-- Portfolio 3: commit and rollback
-- Run Nwachokor_Onyeka_301928256_P3_Setup.sql first so the batch starts at 5 tubs.

-------------------------------------------------------------
-- Part 1: COMMIT - a successful order for 2 tubs
-------------------------------------------------------------
BEGIN;

INSERT INTO orders (customer_id, warehouse_id, delivery_address)
SELECT customer_id, 1, delivery_address
FROM customer WHERE email = 'test@meridon.ng';

INSERT INTO order_item (order_id, product_id, quantity, unit_price)
SELECT (SELECT max(order_id) FROM orders
        WHERE customer_id = (SELECT customer_id FROM customer WHERE email = 'test@meridon.ng')),
       product_id, 2, price
FROM product WHERE name = 'Test Omega 3';

UPDATE stock_batch
SET quantity = quantity - 2
WHERE product_id = (SELECT product_id FROM product WHERE name = 'Test Omega 3');

INSERT INTO payment (order_id, amount, payment_method, status, paid_at)
SELECT max(order_id), 17000, 'card', 'success', now()
FROM orders
WHERE customer_id = (SELECT customer_id FROM customer WHERE email = 'test@meridon.ng');

COMMIT;

-- Check: stock should now be 3, and there should be 1 test order
SELECT quantity FROM stock_batch
WHERE product_id = (SELECT product_id FROM product WHERE name = 'Test Omega 3');

SELECT count(*) AS test_orders FROM orders
WHERE customer_id = (SELECT customer_id FROM customer WHERE email = 'test@meridon.ng');

-------------------------------------------------------------
-- Part 2: ROLLBACK - an order for 10 tubs when only 3 are left
-------------------------------------------------------------
BEGIN;

INSERT INTO orders (customer_id, warehouse_id, delivery_address)
SELECT customer_id, 1, delivery_address
FROM customer WHERE email = 'test@meridon.ng';

INSERT INTO order_item (order_id, product_id, quantity, unit_price)
SELECT (SELECT max(order_id) FROM orders
        WHERE customer_id = (SELECT customer_id FROM customer WHERE email = 'test@meridon.ng')),
       product_id, 10, price
FROM product WHERE name = 'Test Omega 3';

-- This fails: 3 - 10 would make quantity negative (rule 5)
UPDATE stock_batch
SET quantity = quantity - 10
WHERE product_id = (SELECT product_id FROM product WHERE name = 'Test Omega 3');

ROLLBACK;

-- Check: stock is still 3, and there is still only 1 test order
SELECT quantity FROM stock_batch
WHERE product_id = (SELECT product_id FROM product WHERE name = 'Test Omega 3');

SELECT count(*) AS test_orders FROM orders
WHERE customer_id = (SELECT customer_id FROM customer WHERE email = 'test@meridon.ng');
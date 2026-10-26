-- Portfolio 3 setup: a known starting point for every demo
-- Safe to run again; it resets the test data each time.

-- Test customer
INSERT INTO customer (name, email, phone, delivery_address)
VALUES ('Test Customer', 'test@meridon.ng', '08000000000', '1 Test Street, Yaba, Lagos')
ON CONFLICT (email) DO NOTHING;

-- Test product
INSERT INTO product (name, price, weight_g, category, species)
SELECT 'Test Omega 3', 8500, 250, 'human', NULL
WHERE NOT EXISTS (SELECT 1 FROM product WHERE name = 'Test Omega 3');

-- Clear test orders from earlier runs (items are removed by cascade)
DELETE FROM payment
WHERE order_id IN (SELECT order_id FROM orders
                   WHERE customer_id = (SELECT customer_id FROM customer
                                        WHERE email = 'test@meridon.ng'));

DELETE FROM orders
WHERE customer_id = (SELECT customer_id FROM customer
                     WHERE email = 'test@meridon.ng');

-- Reset stock: one Mainland batch with exactly 5 tubs
DELETE FROM stock_batch
WHERE product_id = (SELECT product_id FROM product WHERE name = 'Test Omega 3');

INSERT INTO stock_batch (product_id, warehouse_id, quantity, received_date, expiry_date)
SELECT product_id, 1, 5, current_date, current_date + 365
FROM product WHERE name = 'Test Omega 3';

-- Show the starting point
SELECT p.name, b.batch_id, b.quantity, b.expiry_date
FROM stock_batch b
JOIN product p ON p.product_id = b.product_id
WHERE p.name = 'Test Omega 3';
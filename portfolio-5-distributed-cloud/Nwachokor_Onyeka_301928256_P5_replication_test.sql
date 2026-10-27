-- Portfolio 5 replication test

-- 1. On the PRIMARY (port 5432): create a table and add an order
CREATE TABLE orders (order_id INT PRIMARY KEY, customer TEXT, warehouse TEXT);
INSERT INTO orders VALUES (1, 'Ada', 'Island');

-- 2. On the REPLICA (port 5433): read it back
-- Ada's order shows up even though nothing was written here
SELECT * FROM orders;

-- 3. On the REPLICA (port 5433): try to write
-- Fails with: cannot execute INSERT in a read-only transaction
INSERT INTO orders VALUES (2, 'Bola', 'Mainland');

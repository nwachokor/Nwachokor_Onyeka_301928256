-- Portfolio 2 queries

-- Q1 Stock picking: unexpired batches with stock, earliest expiry first
SELECT batch_id, quantity, received_date, expiry_date
FROM stock_batch
WHERE product_id = 1
  AND warehouse_id = 1
  AND quantity > 0
  AND expiry_date > current_date
ORDER BY expiry_date;

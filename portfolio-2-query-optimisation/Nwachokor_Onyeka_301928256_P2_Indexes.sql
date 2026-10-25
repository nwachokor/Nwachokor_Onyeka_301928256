-- Portfolio 2 indexes

-- Q1 Stock picking: find a product's batches in a warehouse, already sorted by expiry
CREATE INDEX idx_stock_batch_product_wh_expiry
  ON stock_batch (product_id, warehouse_id, expiry_date);

-- Q2 Order history: find a customer's orders, newest first
CREATE INDEX idx_orders_customer_date
  ON orders (customer_id, order_date DESC);

-- Q3 Rider workload: only index deliveries that are still open
CREATE INDEX idx_delivery_rider_open
  ON delivery (rider_id, assigned_at)
  WHERE status <> 'delivered';

-- Q4 Daily revenue: only index successful payments, by date
CREATE INDEX idx_payment_success_date
  ON payment (paid_at)
  WHERE status = 'success';

-- Q5 Best sellers: find recent orders by date
CREATE INDEX idx_orders_date
  ON orders (order_date);

ANALYZE;
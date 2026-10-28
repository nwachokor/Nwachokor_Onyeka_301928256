# Portfolio 2 Performance Analysis

All timings come from EXPLAIN ANALYZE on the seeded database (50,000 orders, 5,000 customers, 2,000 stock batches). Before = no extra indexes. After = indexes from Nwachokor_Onyeka_301928256_P2_Indexes.sql.

## Summary
| Query | Before (ms) | After (ms) | Improvement | Index |
|---|---|---|---|---|
| Q1 Stock picking | 0.140 | 0.075 | about 2x faster | idx_stock_batch_product_wh_expiry |
| Q2 Order history | 4.225 | 0.174 | about 24x faster | idx_orders_customer_date |
| Q3 Rider workload | 19.787 | 12.943 | about 1.5x faster | idx_delivery_rider_open |
| Q4 Daily revenue | 14.160 | 3.575 | about 4x faster | idx_payment_success_date |
| Q5 Best sellers | 25.561 | 22.225 | about 13% faster | idx_orders_date |

## Q1 Stock picking
Before, Postgres read all 2,000 batches and threw away 1,992 of them to find the 8 I wanted. After adding the index on product, warehouse and expiry date, it used a bitmap scan to go straight to product 1's batches. It got about twice as fast, but the table is small, so it was already quick. The index will matter more as more batches are added.

## Q2 Order history
This was the biggest win. Before, Postgres had to read all 50,000 orders to find customer 42's. Postgres doesn't create indexes on foreign keys by itself, so customer_id had none. With the index on customer and order date, it finds that customer's orders straight away, already newest first, so it went from 4.2 ms to 0.17 ms.

## Q3 Rider workload
I used a partial index that only holds deliveries that aren't delivered yet, because that's all this query asks for. The after plan shows it working: a bitmap index scan on idx_delivery_rider_open found rider 3's open deliveries quickly. But it found 1,666 of them, and Postgres then read all 50,000 orders to join them for the delivery address. That join is where most of the time went, so it only got about 1.5 times faster.

The 1,666 open deliveries for one rider come from my seed data, which left about two thirds of a year's deliveries still open. That isn't realistic. A real rider would have a handful of open deliveries, and with that few rows the index would help a lot more.

## Q4 Daily revenue
I used a partial index on paid_at that only holds successful payments. Before, Postgres read every payment and checked the status and date. After, it only reads successful payments from the last 30 days, so it got about 4 times faster.

## Q5 Best sellers
The plan uses the new date index to find the last 30 days of orders, about 4,100 of them. But it then reads the whole order_item table, all 100,001 rows, to find their items. That's the real bottleneck, and it's why the time only dropped by about 13%.

It isn't a missing index. order_item already has an index starting with order_id, from the UNIQUE (order_id, product_id) constraint. Postgres chose to read the whole table in one pass because that was cheaper than about 4,100 separate lookups. Then most of the remaining time goes on adding up the units for each product, which no index can skip.

## What I learned
- Indexes help most when a query wants a small number of rows from a big table, like Q2.
- When a query still has to read and add up a lot of rows, like Q5, an index doesn't help much, and Postgres may decide reading the whole table is cheaper.
- Partial indexes (Q3 and Q4) only hold the rows a query cares about, so they stay small.
- Test data matters. My Q3 result was weaker than it would be in real life, because the seed left too many deliveries open.
- Indexes aren't free. Every insert or update has to update them too, so I only added ones that a real query needs.
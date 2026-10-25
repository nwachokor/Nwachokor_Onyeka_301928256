# Portfolio 2 Query Optimisation

This portfolio uses the Meridon Store database from Portfolio 1 to write realistic queries, look at how PostgreSQL runs them, add indexes, and measure the difference.

## Business questions
1. **Stock picking:** For a given product in a given warehouse, which unexpired batches have stock, earliest expiry first? (rules 7 and 8)
2. **Order history:** What are a customer's most recent orders, with their totals?
3. **Rider workload:** Which deliveries are assigned to a given rider but not yet delivered?
4. **Daily revenue:** How much money came in from successful payments each day over the last 30 days?
5. **Best sellers:** Which ten products sold the most units in the last month?

## How to run
1. Load `../portfolio-1-database-design/schema.sql` to create a fresh database.
2. Run `seed_data.sql` to fill it with sample data.
3. Run each query in `queries.sql` with EXPLAIN ANALYZE and save the plans as the "before" results.
4. Run `indexes.sql` to add the indexes.
5. Run each query again with EXPLAIN ANALYZE and save the plans as the "after" results.

## Files
| File / folder | What it contains |
|---|---|
| `seed_data.sql` | Sample data: 2 warehouses, 5,000 customers, 200 products, 2,000 stock batches, 50,000 orders with items, payments and deliveries |
| `queries.sql` | The five queries, one for each business question |
| `indexes.sql` | One index for each query, including two partial indexes |
| `plans/` | EXPLAIN ANALYZE output for each query, before and after indexes (q1_before.txt to q5_after.txt) |
| `screenshots/` | Seed data loaded, table sizes, query results (q1_result.png to q5_result.png) and indexes created |
| `analysis.md` | What changed in each plan and why |

## Results summary
| Query | Time before (ms) | Time after (ms) | Index used |
|---|---|---|---|
| Q1 Stock picking | 0.140 | 0.075 | idx_stock_batch_product_wh_expiry |
| Q2 Order history | 4.225 | 0.174 | idx_orders_customer_date |
| Q3 Rider workload | 19.787 | 12.943 | idx_delivery_rider_open |
| Q4 Daily revenue | 14.160 | 3.575 | idx_payment_success_date |
| Q5 Best sellers | 25.561 | 22.225 | idx_orders_date |

## Notes
- Timings come from one run each, so they can vary slightly between runs.
- The seed data uses random values, so exact rows and times will differ if it's reloaded.
- Full explanations are in analysis.md.

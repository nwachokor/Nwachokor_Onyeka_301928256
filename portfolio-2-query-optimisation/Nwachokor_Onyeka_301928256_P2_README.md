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

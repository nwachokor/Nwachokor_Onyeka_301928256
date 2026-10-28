# Isolation

This shows that one session can't see another session's changes until they're committed, and how the isolation level changes what a session sees.

Run Nwachokor_Onyeka_301928256_P3_Setup.sql first so the test batch starts at 5 tubs. I used two terminals connected to the same database: Session A and Session B.

## Part 1: Read committed (Postgres default)

Left column = Session A, right column = Session B.

| Step | Session A | Session B |
|---|---|---|
| 1 | `BEGIN;` | |
| 2 | `UPDATE stock_batch SET quantity = 1 WHERE product_id = (SELECT product_id FROM product WHERE name = 'Test Omega 3');` (not committed yet) | |
| 3 | | `SELECT quantity FROM stock_batch WHERE product_id = (SELECT product_id FROM product WHERE name = 'Test Omega 3');` → still **5** |
| 4 | `COMMIT;` | |
| 5 | | Same SELECT again → now **1** |

Screenshots: `screenshots/Isolation_before_commit.png` (step 3), `screenshots/Isolation_after_commit.png` (step 5)

**What this shows:** while A's change wasn't committed, B still saw 5. As soon as A committed, B's next SELECT saw 1. Under read committed, every new statement looks at the latest committed data, so B never saw a half-finished change. That's what "no dirty reads" means.

## Part 2: Repeatable read

Run the setup file again first, so stock is back to 5.

Left column = Session A, right column = Session B.

| Step | Session A | Session B |
|---|---|---|
| 1 | | `BEGIN ISOLATION LEVEL REPEATABLE READ;` |
| 2 | | Same SELECT → **5** |
| 3 | `UPDATE stock_batch SET quantity = 1 WHERE product_id = (SELECT product_id FROM product WHERE name = 'Test Omega 3');` (commits straight away) | |
| 4 | | Same SELECT again → still **5** |
| 5 | | `COMMIT;` |
| 6 | | Same SELECT again → now **1** |

Screenshots: `screenshots/Isolation_repeatable_read.png` (step 4), `screenshots/Isolation_repeatable_read_after.png` (step 6)

**What this shows:** even after A committed, B kept seeing 5 until its own transaction ended. Under repeatable read, a transaction keeps one snapshot from its first query to the end, so the same SELECT always gives the same answer inside it. Under read committed, step 4 would have shown 1.

## When I'd use each at Meridon
- **Read committed** for normal things like a customer checking if a product is in stock. They should see the latest stock, and it's Postgres's default.
- **Repeatable read** for something like an end-of-day stock report that reads many tables. If stock changed halfway through, the totals wouldn't add up, so the report needs one fixed snapshot.

Neither level ever shows uncommitted data.
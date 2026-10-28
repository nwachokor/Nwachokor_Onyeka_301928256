# Race Condition: Overselling

Two customers try to buy 4 tubs each of Test Omega 3 at the same time, but there are only 5 in stock. Like a real app, each session first reads the stock, works out the new amount itself, then saves it. Without locking, both orders go through and the store sells 8 tubs it doesn't have. This is called a lost update.

Run Nwachokor_Onyeka_301928256_P3_Setup.sql first so the test batch starts at 5 tubs. Use two terminals: Session A and Session B.

Left column = Session A, right column = Session B.

| Step | Session A | Session B |
|---|---|---|
| 1 | `BEGIN;` | |
| 2 | `SELECT quantity FROM stock_batch WHERE product_id = (SELECT product_id FROM product WHERE name = 'Test Omega 3');` → **5** | |
| 3 | | `BEGIN;` |
| 4 | | Same SELECT → also **5** |
| 5 | Both see 5, so both decide 4 tubs is fine. A saves 5 − 4 = 1: `UPDATE stock_batch SET quantity = 1 WHERE product_id = (SELECT product_id FROM product WHERE name = 'Test Omega 3');` | |
| 6 | | B saves 5 − 4 = 1 too, using the same UPDATE → it **waits**, because A is holding the row |
| 7 | `COMMIT;` | |
| 8 | | B's update now finishes (UPDATE 1). `COMMIT;` |
| 9 | Run the SELECT again → **1** | |

**What this shows:** 8 tubs were sold, but stock only went down by 4. A's update was overwritten by B's, because B worked out its new value from a reading that was already out of date. Stock should have run out, and B's order should have been refused.

**Why the check constraint didn't catch it:** the rule "quantity can't be negative" only stops a value below 0. Each session saved 1, which looks valid on its own. The problem is that B's decision was based on old data.

Screenshots:
- `screenshots/race_both_read_5.png` (step 4, both sessions read 5)
- `screenshots/race_b_waiting.png` (step 6, B waiting)
- `screenshots/race_result.png` (step 9, stock shows 1)

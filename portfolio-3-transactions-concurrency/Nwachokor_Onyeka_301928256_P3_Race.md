# Race Condition: Overselling

Two customers try to buy 3 tubs each of Test Omega 3 at the same time, but there are only 5 in stock. Like a real app, each session first reads the stock, works out the new amount itself, then saves it. Without locking, both orders go through and the store sells 6 tubs it doesn't have. This is called a lost update.

Run setup.sql first so the test batch starts at 5 tubs. Use two terminals: Session A and Session B.

| Step | Session A | Session B |
|---|---|---|
| 1 | `BEGIN;` | |
| 2 | `SELECT quantity FROM stock_batch WHERE product_id = (SELECT product_id FROM product WHERE name = 'Test Omega 3');` → **5** | |
| 3 | | `BEGIN;` |
| 4 | | Same SELECT → also **5** |
| 5 | Both see 5, so both decide 3 tubs is fine. A saves 5 − 3 = 2: `UPDATE stock_batch SET quantity = 2 WHERE product_id = (SELECT product_id FROM product WHERE name = 'Test Omega 3');` | |
| 6 | | B saves 5 − 3 = 2 too, using the same UPDATE → it **waits**, because A is holding the row |
| 7 | `COMMIT;` | |
| 8 | | B's update now finishes (UPDATE 1). `COMMIT;` |
| 9 | Run the SELECT again → **2** | |

**What this shows:** 6 tubs were sold, but stock only went down by 3. A's update was overwritten by B's, because B worked out its new value from a reading that was already out of date. Stock should have run out, and B's order should have been refused.

**Why the check constraint didn't catch it:** the rule "quantity can't be negative" only stops a value below 0. Each session saved 2, which looks valid on its own. The problem is that B's decision was based on old data.

Screenshots:
- `screenshots/race_waiting.png` (step 6, B waiting)
- `screenshots/race_result.png` (step 9, stock shows 2)

## My notes
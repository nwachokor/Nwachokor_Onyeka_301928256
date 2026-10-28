# Fix: row locking with SELECT ... FOR UPDATE

The fix is to lock the stock row when reading it. SELECT ... FOR UPDATE makes the second customer wait until the first one has finished, so they read the real stock instead of an old value.

Run setup.sql first so the batch starts at 5 tubs.

| Step | Session A (customer 1) | Session B (customer 2) |
|---|---|---|
| 1 | `BEGIN;` | |
| 2 | `SELECT quantity FROM stock_batch WHERE product_id = (SELECT product_id FROM product WHERE name = 'Test Omega 3') FOR UPDATE;` → **5**, row is now locked | |
| 3 | | `BEGIN;` |
| 4 | | Same SELECT ... FOR UPDATE → **waits** |
| 5 | `UPDATE stock_batch SET quantity = quantity - 4 WHERE product_id = (SELECT product_id FROM product WHERE name = 'Test Omega 3');` | still waiting |
| 6 | `COMMIT;` | B's SELECT now returns **1**, not enough for 4 |
| 7 | | `ROLLBACK;` (order refused) |
| 8 | | SELECT again → **1** |

## What changed
B couldn't read the stock until A had finished, so it saw the true amount, 1 tub, and the order was refused. Only 4 tubs were sold, and the stock is correct.

The update also uses `quantity = quantity - 4` instead of a fixed number, so it always works from the current value. And if anything still tried to sell more than was left, the CHECK (quantity >= 0) from Portfolio 1 would stop it, as shown in the rollback demo.

Screenshots: `screenshots/fix_b_waiting.png`, `screenshots/fix_result.png`

Left column = Session A, right column = Session B.

## Trade-off

**The cost:** FOR UPDATE makes other customers wait. If lots of people buy the same product at the same time, they queue one by one on that stock row, so the app slows down at busy times like a sale.

**The risk:** if two transactions lock rows in opposite order, for example A locks Omega 3 then Fish Oil while B locks Fish Oil then Omega 3, they end up waiting for each other forever. That's a deadlock. Postgres spots it and cancels one of them, so the app has to be ready to retry that order.

**Other options:**
- An atomic update: `UPDATE stock_batch SET quantity = quantity - 4 WHERE product_id = ... AND quantity >= 4;` If it says UPDATE 0, there wasn't enough stock, so the order is refused. It's one step, so there's no gap between reading and saving.
- SERIALIZABLE isolation, where Postgres cancels one of the clashing transactions and the app retries it.

**Why I chose FOR UPDATE:** it's the easiest to show step by step in two terminals, since you can actually see Session B waiting. It's also clear to read: lock the row, check the stock, then save. For Meridon, where most products aren't bought by many people at once, the waiting cost is small.
# Portfolio 3 Transactions and Concurrency

This portfolio uses the Meridon Store database to show how transactions keep the data correct, and what happens when two people use the database at the same time.

## Scenarios
1. **Commit:** A customer orders 2 tubs. The order, its item, the stock deduction and the payment are saved together in one transaction, then committed.
2. **Rollback:** An order asks for 10 tubs when only 3 are left. The stock update breaks the quantity >= 0 check, so the whole transaction is rolled back and nothing is saved.
3. **Isolation:** Two sessions run at the same time. One changes stock but hasn't committed, and the other can't see that change until it commits. Repeatable read keeps the same snapshot for the whole transaction.
4. **Concurrency problem and fix:** Two customers try to buy 4 of the last 5 tubs at the same time. Without locking, both orders go through and stock is oversold. With SELECT ... FOR UPDATE, the second customer waits and sees the real stock.

## How to run
1. Load `../portfolio-1-database-design/Nwachokor_Onyeka_301928256_P1_Schema.sql` and `../portfolio-2-query-optimisation/Nwachokor_Onyeka_301928256_P2_SeedData.sql`.
2. Run `Nwachokor_Onyeka_301928256_P3_Setup.sql` before each demo. It resets Test Omega 3 to exactly 5 tubs.
3. Run `Nwachokor_Onyeka_301928256_P3_CommitRollback.sql` in one session (part 1, then part 2).
4. For isolation, race and fix, open two terminals (Session A and Session B) and follow the steps in each .md file.

## Files
| File / folder | What it contains |
|---|---|
| `Nwachokor_Onyeka_301928256_P3_Setup.sql` | Test customer, test product and a batch of 5 tubs; resets the test data each run |
| `Nwachokor_Onyeka_301928256_P3_CommitRollback.sql` | Demo 1 (commit) and demo 2 (rollback) |
| `Nwachokor_Onyeka_301928256_P3_Isolation.md` | Read committed and repeatable read, step by step |
| `Nwachokor_Onyeka_301928256_P3_Race.md` | The lost update: stock oversold without locking |
| `Nwachokor_Onyeka_301928256_P3_Fix.md` | The fix using SELECT ... FOR UPDATE |
| `screenshots/` | Evidence for every demo |

## Results
| Demo | What happened | Stock at the end |
|---|---|---|
| Commit | Order for 2 saved | 3 |
| Rollback | Order for 10 refused, nothing saved | 3 |
| Read committed | B saw 5 until A committed, then 1 | 1 |
| Repeatable read | B kept seeing 5 after A committed, until B committed | 1 |
| Race (no lock) | Both orders of 4 went through, 8 sold from 5 | 1 (wrong) |
| Fix (FOR UPDATE) | Second order waited, saw 1, and was refused | 1 (correct) |

## Conclusion
- Transactions make an order all or nothing, so a failed order never leaves half its data behind.
- PostgreSQL's default isolation stops one session from seeing another's uncommitted changes.
- Isolation alone doesn't stop overselling. When two sessions read and then update the same stock, one update can overwrite the other.
- Locking the row with SELECT ... FOR UPDATE, and updating with quantity = quantity - n, makes the second customer wait and work from the real stock.
- The CHECK (quantity >= 0) from Portfolio 1 is the final safety net if anything still tries to sell more than exists.

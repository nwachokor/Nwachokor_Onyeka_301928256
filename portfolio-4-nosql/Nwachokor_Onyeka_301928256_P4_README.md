# Portfolio 4 NoSQL and Advanced Data Models

This portfolio adds product reviews to Meridon Store using MongoDB, a document database. Orders, stock and payments stay in PostgreSQL, and reviews link back to them by ID.

## What I built
- A `reviews` collection where each review is one document.
- 10 sample reviews for human and pet products, with different fields (pet details, photos, sub-ratings, tags, staff replies).
- Queries that search nested fields and arrays, work out average ratings, update a review, and use an index.

## How to run
1. Start MongoDB in Docker:
   `docker run --name meridon-mongo -d mongo:7`
   `docker exec -it meridon-mongo mongosh`
2. Paste `Nwachokor_Onyeka_301928256_P4_insert_reviews.js` to create the reviews.
3. Run each query in `Nwachokor_Onyeka_301928256_P4_queries.js` one at a time.

## Files
| File / folder | What it contains |
|---|---|
| `Nwachokor_Onyeka_301928256_P4_model.md` | The review document design, with examples |
| `Nwachokor_Onyeka_301928256_P4_insert_reviews.js` | Inserts the 10 sample reviews |
| `Nwachokor_Onyeka_301928256_P4_queries.js` | The six queries |
| `Nwachokor_Onyeka_301928256_P4_suitability.md` | Why MongoDB fits reviews, and why orders stay in PostgreSQL |
| `screenshots/` | Evidence for each step |

## Queries and evidence
| Query | What it shows | Screenshot |
|---|---|---|
| Insert | 10 reviews created | reviews_inserted.png |
| Q1 | All reviews for one product, newest first | q1_result.png |
| Q2 | Dog reviews only, searching inside the pet object | q2_result.png |
| Q3 | Reviews tagged "fast delivery", searching inside an array | q3_result.png |
| Q4 | Average rating per product, using aggregation | q4_result.png |
| Q5 | Adding a staff reply to a review | q5_result.png |
| Q6 | Index on product and date; the plan uses IXSCAN | q6_index_plan.png |

## Summary
Reviews are flexible, read a lot, and self-contained, so they suit a document database. Orders, stock and payments need strict rules and transactions, so they stay in PostgreSQL. Full reasoning is in the suitability file.

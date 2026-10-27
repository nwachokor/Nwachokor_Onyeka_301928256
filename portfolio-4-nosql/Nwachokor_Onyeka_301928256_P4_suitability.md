# Portfolio 4 Suitability: Why MongoDB for Reviews

## Why a document database fits reviews
- **Reviews don't all look the same.** Pet reviews have a pet section, some have photos, some rate taste and value separately. In MongoDB each review only stores the fields it has. In PostgreSQL I'd need lots of empty columns or extra tables.
- **Everything about a review stays together.** The pet details, photos, tags and staff reply are all inside the one document, so showing a review on the product page is one read with no joins.
- **It's easy to add new fields.** If Meridon starts asking "would you buy again?", new reviews can just include it. Old reviews don't need changing.
- **Reviews are read a lot more than they're changed.** People write a review once, but many customers read it, and the index on product_id and created_at keeps that main lookup fast (Q6 shows IXSCAN).
- **Useful queries still work.** I can search inside nested fields (Q2), inside arrays (Q3), and work out averages with aggregation (Q4).

## Why orders and stock stay in PostgreSQL
- Orders, payments and stock need transactions and strict rules, like stock never going below zero and only one successful payment per order (Portfolios 1 and 3).
- That data has a fixed structure and lots of relationships, which suits tables, keys and joins.
- Getting a stock or payment wrong costs real money. Getting a review slightly out of date doesn't.

## How the two work together
Reviews store product_id, customer_id and order_id from PostgreSQL. The order_id shows the review comes from a real purchase.

## Limitations
- MongoDB can't check that product_id or customer_id actually exist in PostgreSQL. The app has to make sure of that.
- If a product is renamed in PostgreSQL, reviews don't need changing, because they only store the ID.
- Reports that combine reviews with sales, like "best-rated products that sold the most", need data from both databases, so they're harder to write.

## Conclusion
MongoDB suits reviews because they're flexible, read-heavy and self-contained. PostgreSQL suits orders, stock and payments because they need strict rules and transactions. Using both, each for what it's good at, is called polyglot persistence.

# Meridon Store Normalisation

Normalisation checks that each fact is stored in one place only, so updates cannot leave the data contradicting itself. The design was tested against the first three normal forms.

## Starting point: one flat order record
Without normalisation, an order might be stored as a single row:

| order_id | customer_name | customer_email | warehouse_name | warehouse_address | products | quantities | prices |
|---|---|---|---|---|---|---|---|
| 101 | Ada | ada@mail.com | Island | 12 Admiralty Way | Omega 3, Dog Joint Chews | 2, 1 | 8500, 12000 |

This causes three problems:
- **Update problem:** if Ada changes her email, every one of her orders must be changed, and missing one leaves conflicting data.
- **Insert problem:** a new product cannot be recorded until someone orders it.
- **Delete problem:** deleting Ada's only order also deletes the only record of Ada as a customer.

## First normal form (1NF)
**Rule:** each cell holds a single value, and there are no repeating groups.

The products, quantities and prices columns above each hold lists. They are moved into a separate **OrderItem** table with one row per product per order. In the final design every column holds one value, and every table has a primary key.

## Second normal form (2NF)
**Rule:** every non-key column depends on the whole primary key, not part of it.

Partial dependency can only happen when a key has more than one column. In the 1NF version, an order line is identified by (order_id, product_id), and the product's name and current price depend on product_id alone. These columns are moved to **Product**, and only the facts about that line (quantity and unit_price) stay in **OrderItem**.

In the final design every table uses a single-column primary key, so no partial dependency is possible. OrderItem also has a unique pair (order_id, product_id), and its quantity and unit_price depend on that whole pair.

## Third normal form (3NF)
**Rule:** no non-key column depends on another non-key column.

In the 1NF version, customer_name and customer_email depend on the customer, not the order, and warehouse_address depends on warehouse_name. These are moved out:
- Customer details go to **Customer**, and Orders keeps only customer_id.
- Warehouse details go to **Warehouse**, and Orders and StockBatch keep only warehouse_id.
- Rider and staff details go to **Rider** and **Staff**, and Delivery keeps only rider_id and assigned_by_staff_id.

Each remaining column describes only the row its key identifies:

| Table | Every non-key column describes… |
|---|---|
| Warehouse | the warehouse |
| Customer | the customer |
| Product | the product |
| StockBatch | that batch of stock |
| Orders | the order as placed |
| OrderItem | one product line in one order |
| Payment | one payment attempt |
| Staff | the staff member |
| Rider | the rider |
| Delivery | the delivery of one order |

Product.species is not a 3NF problem. Category does not determine species (a pet product can be for a dog or a cat), so species is an independent fact about the product.

## Deliberate repeated data
Some columns look like duplication but record a different fact.

- **OrderItem.unit_price** is not a copy of Product.price. It is the price at the moment of the order (rule 11). Product.price can change later, but past orders must not.
- **Orders.delivery_address** is not a copy of Customer.delivery_address. It is where this order was sent. A customer who moves house should not change the address on past orders.
- **Payment.amount** is stored even though the order total can be calculated from OrderItem. It records what was actually charged in that attempt, which is what the payment record must show.
- **Delivery.status** could be worked out from the timestamps (picked_up_at and delivered_at). It is kept as its own column so the current stage is easy to query and filter, and check constraints keep it consistent with the timestamps.

## Result
All ten tables are in third normal form. The only repeated values are historical snapshots or deliberate, controlled exceptions, each explained above.
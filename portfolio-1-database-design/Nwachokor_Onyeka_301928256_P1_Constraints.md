# Meridon Store Constraints

## 1. Primary keys
Every table has a single-column numeric primary key (warehouse_id, customer_id, product_id, batch_id, order_id, order_item_id, payment_id, staff_id, rider_id, delivery_id). A primary key is always unique and never empty, so each row can be identified on its own, even if two rows share other values such as a name.

## 2. Foreign keys
Each foreign key can only hold a value that exists in the table it points to. The delete behaviour is chosen to protect order and payment history.

| Foreign key | Points to | On delete | Reason |
|---|---|---|---|
| StockBatch.product_id | Product | Restrict | A product with stock records cannot be deleted |
| StockBatch.warehouse_id | Warehouse | Restrict | A warehouse holding stock cannot be deleted |
| Orders.customer_id | Customer | Restrict | Past orders must keep their customer |
| Orders.warehouse_id | Warehouse | Restrict | Past orders must keep their warehouse |
| OrderItem.order_id | Orders | Cascade | Items have no meaning without their order |
| OrderItem.product_id | Product | Restrict | Sold products stay on record |
| Payment.order_id | Orders | Restrict | Payment records must never be lost |
| Delivery.order_id | Orders | Restrict | Delivery history stays with the order |
| Delivery.rider_id | Rider | Restrict | Past deliveries keep their rider |
| Delivery.assigned_by_staff_id | Staff | Restrict | Keeps the record of who assigned the delivery |

- StockBatch.product_id and StockBatch.warehouse_id are both required, so every batch belongs to exactly one product and one warehouse (rule 4).
- Orders.warehouse_id is a single required foreign key, so every order is fulfilled from exactly one warehouse (rule 10).

## 3. Unique constraints
- Customer.email: no two customers share an email (rule 18).
- Staff.email: each staff login is unique.
- Warehouse.name: only one Mainland and one Island warehouse.
- Delivery.order_id: each order has at most one delivery (rule 15).
- OrderItem (order_id, product_id): the same product cannot appear twice in one order; the quantity is increased instead.

## 4. Not null
Every column is required, except:
- Product.species: empty for human products (rule 2).
- Payment.paid_at: empty until a payment succeeds.
- Delivery.picked_up_at and Delivery.delivered_at: empty until the delivery reaches that stage.

## 5. Check constraints
| Rule | Check |
|---|---|
| 1 | Product.category must be 'human' or 'pet' |
| 2 | If category is 'pet', species must be 'dog' or 'cat'; if 'human', species must be empty |
| 3 | Product.price must be greater than 0 |
| – | Product.weight_g must be greater than 0 |
| 5 | StockBatch.quantity must be 0 or more |
| 6 | StockBatch.expiry_date must be later than received_date |
| 9 | OrderItem.quantity must be at least 1 |
| – | OrderItem.unit_price and Payment.amount must be greater than 0 |
| 12 | Payment.payment_method must be 'card' or 'transfer' |
| – | Payment.status must be 'pending', 'success' or 'failed'; paid_at must be filled when status is 'success' |
| – | Rider.status must be 'active' or 'inactive' |
| 16 | Delivery.status must be 'assigned', 'picked_up' or 'delivered'; delivered_at must be filled when status is 'delivered' |

## 6. Rules enforced beyond simple constraints
Some rules involve more than one row or table, so a single column check cannot enforce them.

- Rule 13 (only one successful payment per order): a partial unique index on Payment.order_id, applied only where status is 'success'.
- Rules 7 and 8 (no expired stock, earliest expiry first): the order-placement transaction takes stock only from unexpired batches in the order's warehouse, earliest expiry first.
- Rule 9 (at least one item per order): an order row is inserted before its items, so a normal constraint cannot check this. A deferred trigger checks at commit time that the order has at least one item, and rolls the transaction back if not.
- Rule 11 (price fixed at time of order): unit_price is copied from Product when the item is added, and a trigger blocks any later update to it.
- Rule 14 (no dispatch before payment): a trigger blocks creating a delivery unless the order has a successful payment.
- Rule 16 (status only moves forward): a trigger rejects any update that moves a delivery's status backwards.
- Rule 17 (delivery confirmed by code): the code the rider enters is not stored. The application compares it with Delivery.delivery_code and only sets the status to 'delivered' if they match.

## 7. Known limitation
OrderItem records which product was sold but not which batch it came from. Stock is deducted earliest-expiry-first (rule 8), but afterwards the database cannot show which batch an item was taken from, so a recalled batch cannot be traced to the customers who received it. Adding an OrderItemBatch table (order_item_id, batch_id, quantity) would fix this, but it is outside the scope of this design.

- The schema requires picked_up_at to be filled in once a delivery's status is 'picked_up'
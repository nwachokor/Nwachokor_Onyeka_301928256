# Meridon Store Normalisation

Normalisation for Meridon Store checks that every piece of data given to the system is stored in one place, so updates don't leave the database contradicting itself.

## Starting point: one flat order record
Without normalisation, an order might be stored as a single row:

| order_id | customer_name | customer_email | warehouse_name | warehouse_address | products | quantities | prices |
|---|---|---|---|---|---|---|---|
| 101 | Ada | ada@icloud.com | Island | 12 Admiralty Way | Omega 3, Dog Joint Chews | 2, 1 | 8500, 12000 |

To stop orders, customers and products from being mixed into the same rows, each one gets its own table. That fixes three problems with the flat record:

- **Update anomaly:** if Ada changes her email from ada@icloud.com to ada@gmail.com, it only changes in one place, and we still know she's the same customer with the same order history.
- **Delete anomaly:** if she deletes or cancels an order, her customer record doesn't disappear with it.
- **Insert anomaly:** because products have their own table, a new product can be added to the store before anyone has ordered it.

## The three normal forms
There are three normal forms.

**First normal form** means each product in an order gets its own row, so no cell holds a list. That is why OrderItem is its own table.

**Second normal form** means every column depends on the whole key, not just part of it.

Imagine OrderItem with the key (order_id, product_id), and it also stored product_name:

| order_id | product_id | product_name | quantity | unit_price |
|---|---|---|---|---|
| 101 | 7 | Omega 3 | 2 | 8500 |
| 102 | 7 | Omega 3 | 1 | 8500 |

product_name depends only on product_id, not on the whole key. That's a partial dependency, which breaks 2NF. So the name moves to the Product table.

quantity and unit_price depend on both together, meaning how many of this product were in this order and at what price, so they stay in OrderItem.

**Third normal form** means no column describes something else. A warehouse's address goes in Warehouse, not in Orders, because it describes the warehouse, not the order. In the same way, customer details stay in Customer, and rider and staff details stay in Rider and Staff, with other tables only holding their IDs.

Species is dog or cat for pet products and empty for human products. It isn't repeating category, because knowing a product is for pets doesn't tell you if it's for a dog or a cat.

## Repeated data I kept on purpose
Some data looks repeated, but it's actually recording something different.
- **OrderItem.unit_price** is what the customer paid at the time they ordered. Product.price can go up or down later, but that shouldn't change what someone already paid.
- **Orders.delivery_address** is where that order was actually sent. If a customer moves house, their old orders should still show the old address.
- **Payment.amount** is what was charged in that payment attempt. I store it instead of adding up the items again, because the payment record should show what really happened.
- **Delivery.status** could be worked out from the timestamps, but I kept it because it makes it easy to check what stage a delivery is at. The check constraints stop the status and timestamps from disagreeing.

## How the design changed
- **Total price on Orders.** At first I had a total_price column on Orders. I took it out because the total can be worked out from OrderItem (quantity × unit_price), and if I stored it as well, the two could end up different.
- **Species for human products.** At first I gave human products the species 'human'. But that was just repeating the category, and the store doesn't sell for a 'human' species. So I changed it to NULL, and now only pet products have a species.
- **Rider status.** At first rider status was 'busy' or 'available'. But you can tell if a rider is busy by checking if they have a delivery that isn't finished, so storing it could go out of date. I changed it to 'active' or 'inactive', which shows if the rider still works for the store.

## Result
All the tables are in third normal form. The only repeated values are snapshots of what was true at the time, which I kept on purpose.
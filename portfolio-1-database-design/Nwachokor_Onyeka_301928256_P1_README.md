# Portfolio 1 Database Design and Modelling

## Case study
Meridon Store is a simulated online store based in Lagos that sells supplements for humans and pets (dogs and cats). It sells online only and runs two warehouses, one on the Mainland and one on the Island, each holding its own stock.

## Nature of the business
Meridon sells its own stock rather than acting as a marketplace for other sellers. Customers place and pay for orders online by card or bank transfer, and the store delivers them using its own in-house delivery team. Stock is received in batches, and each batch has an expiry date.

## Users
- Customers: place orders, make payments and track their deliveries.
- Staff/Admin: add and remove products, manage stock and manage orders.
- Delivery Riders: Update delivery statuses and confirm drop-offs at the customer's address.

## Major data
- Products: name, price, weight, category (human or pet), and species for pet products
- Stock batches: quantity, expiry date, and warehouse location.
- Warehouses: Mainland and Island locations.
- Customers: name, deivery address and contact details
- Orders & Items: Order records and the specific items included in each order.
- Payments: method (card or transfer), amount and status
- Deliveries: addigned rider, status, timestamps and confirmation code

## Main operations
- Staff add and remove products and record new stock batches.
- Customers place orders, with inventory deducted from the appropriate batch.
- Customers pay by card or transfer.
- Staff assign each order to a rider.
- Customers monitor their delivery progress.
- Riders confirm delivery by requesting the code sent to the customer upon arrival. Entering this matching code serves as proof of delivery.

## Business rules
Products

1. Every product is either a human or a pet product.
2. A pet product must have a species (dog or cat), whereas a human product has no species.
3. A product's price must be greater than zero.

Stock

4. Stock is held in batches. Each batch belongs to one product and one warehouse.
5. A batch's quantity can never be negative.
6. A batch's expiry date must be later than the date it was received.
7. Stock from an expired batch cannot be sold.
8. When an order is placed, stock is taken from the batch with the earliest expiry date first.

Orders and payments

9. Every order belongs to one customer and contains at least one product, each with a quantity of at least 1.
10. Each order is fulfilled from one warehouse.
11. The price paid for each product is recorded on the order, so later price changes do not alter past orders.
12. Payment method must be card or transfer.
13. An order may have several payment attempts, but only one can succeed.
14. An order is not dispatched until its payment has succeeded.

Deliveries

15. Each order has one delivery, assigned to one rider.
16. Delivery status moves only forward: assigned → picked up → delivered.
17. A delivery can only be marked delivered when the rider enters the code that matches the one sent to the customer.

Customers

18. Each customer's email address is unique.

## Scope
Included: Product catalogue; batch stock across the two warehouses; customer accounts; orders; payment records; delivery assignment, tracking, and code confirmation; staff and rider records.

Left out:
- Real card processing (the database logs the payment outcome rather than connecting directly to a payment gateway)
- Returns, refunds, discounts and coupons
- Failed or rescheduled delivery attempts
- Purchasing stock from suppliers
- Deliveries outside Lagos
- Product reviews and shopping carts in the relational design (Portfolio 4 may model one of these in NoSQL)
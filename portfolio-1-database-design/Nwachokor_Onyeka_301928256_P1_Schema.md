# Meridon Store Relational Schema

PK = primary key, FK = foreign key, UK = unique.

- **Warehouse**(warehouse_id PK, name UK, location_address)
- **Customer**(customer_id PK, name, email UK, phone, delivery_address)
- **Product**(product_id PK, name, price, weight_g, category, species)
- **StockBatch**(batch_id PK, product_id FK → Product, warehouse_id FK → Warehouse, quantity, received_date, expiry_date)
- **Orders**(order_id PK, customer_id FK → Customer, warehouse_id FK → Warehouse, order_date, delivery_address)
- **OrderItem**(order_item_id PK, order_id FK → Orders, product_id FK → Product, quantity, unit_price)
- **Payment**(payment_id PK, order_id FK → Orders, amount, payment_method, status, paid_at)
- **Staff**(staff_id PK, name, email UK, role, password_hash)
- **Rider**(rider_id PK, name, phone, status)
- **Delivery**(delivery_id PK, order_id FK → Orders UK, rider_id FK → Rider, assigned_by_staff_id FK → Staff, status, delivery_code, assigned_at, picked_up_at, delivered_at)
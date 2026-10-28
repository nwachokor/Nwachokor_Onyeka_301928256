# Meridon Store Database Design

## Entities and attributes    
PK = primary key, FK = foreign key.

### Warehouse

- warehouse_id (PK)
- name (unique: Mainland or Island)
- location_address

### Customer
- customer_id (PK)
- name
- email (unique)
- phone
- delivery_address

### Product
- product_id (PK)
- name
- price
- weight_g (in grams)
- category (human or pet)
- species (dog or cat; empty for human products)

### Stock batch
- batch_id (PK)
- product_id (FK to Product)
- warehouse_id (FK to Warehouse)
- quantity
- received_date
- expiry_date

### Orders
- order_id (PK)
- customer_id (FK to Customer)
- warehouse_id (FK to Warehouse)
- order_date
- delivery_address

### Order item
- order_item_id (PK)
- order_id (FK to Orders)
- product_id (FK to Product)
- quantity
- unit_price

### Payment
- payment_id (PK)
- order_id (FK to Orders)
- amount
- payment_method (card or transfer)
- status (pending, success or failed)
- paid_at

### Staff
- staff_id (PK)
- name
- email (unique)
- role
- password_hash

### Rider
- rider_id (PK)
- name
- phone
- status (active or inactive)

### Delivery
- delivery_id (PK)
- order_id (FK to Orders, unique)
- rider_id (FK to Rider)
- assigned_by_staff_id (FK to Staff)
- status (assigned, picked_up or delivered)
- delivery_code
- assigned_at
- picked_up_at
- delivered_at


## Relationships      
- Warehouse 1 : N Stock batch
- Warehouse 1 : N Orders
- Customer 1 : N Orders
- Product 1 : N Stock batch
- Product 1 : N Order item
- Orders 1 : N Order item
- Orders 1 : N Payment
- Orders 1 : 1 Delivery (an order has zero or one delivery)
- Rider 1 : N Delivery
- Staff 1 : N Delivery


## Design decisions  
- Staff and riders are separate tables: staff are in-house and full-time, while riders in house but can change often.
- Product keeps both category and species; species is empty for human. 
- - Reason: Human products have no species so that column is left empty = NULL
- Staff passwords are stored as password_hash. 
- - Reason:  If we store password as typed, in cases of database leak, the password leaks but as hash, the password is scrambled on way, the system can check a password against a hash but not the other way round, nobody can turn a hash to a password. 
- Orders stores its own delivery_address. 
- - Reason: The order will go to the address provided at time order was placed because customers could move houses and will want to set a different address
- Delivery records assigned_by_staff_id. 
- - Reason: This record will help if something goes wrong, we can trace it back to the staff who carried the action. 
- The table is called orders, not order, because ORDER is a reserved word in SQL.
- - The ER diagram and design files use readable names like StockBatch and OrderItem. The SQL uses Postgres-style lowercase names with underscores, like stock_batch and order_item, so the two refer to the same tables.




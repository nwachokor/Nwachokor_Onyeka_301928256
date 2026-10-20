# Meridon Store ER Diagram

## ER diagram

```mermaid
erDiagram
    direction LR
    Warehouse {
        int warehouse_id PK
        string name UK
        string location_address
    }
    Customer {
        int customer_id PK
        string name
        string email UK
        string phone
        string delivery_address
    }
    Product {
        int product_id PK
        string name
        decimal price
        float weight
        string category
        string species
    }
    StockBatch {
        int batch_id PK
        int product_id FK
        int warehouse_id FK
        int quantity
        date received_date
        date expiry_date
    }
    Orders {
        int order_id PK
        int customer_id FK
        int warehouse_id FK
        datetime order_date
        string delivery_address
    }
    OrderItem {
        int order_item_id PK
        int order_id FK
        int product_id FK
        int quantity
        decimal unit_price
    }
    Payment {
        int payment_id PK
        int order_id FK
        decimal amount
        string payment_method
        string status
        datetime paid_at
    }
    Staff {
        int staff_id PK
        string name
        string email UK
        string role
        string password_hash
    }
    Rider {
        int rider_id PK
        string name
        string phone
        string status
    }
    Delivery {
        int delivery_id PK
        int order_id FK, UK
        int rider_id FK
        int assigned_by_staff_id FK
        string status
        string delivery_code
        datetime assigned_at
        datetime picked_up_at
        datetime delivered_at
    }

    Warehouse ||--o{ StockBatch : holds
    Warehouse ||--o{ Orders : fulfills
    Customer ||--o{ Orders : places
    Product ||--o{ StockBatch : stocked_in
    Product ||--o{ OrderItem : included_in
    Orders ||--|{ OrderItem : contains
    Orders ||--o{ Payment : receives
    Orders ||--o| Delivery : has
    Rider ||--o{ Delivery : handles
    Staff ||--o{ Delivery : assigns
```

## PK (primary key)
- Every table has one: customer_id, product_id…
- No two rows can share the same value
- Can never be empty
- Not the same as "rows can't look alike": two customers can share a name

## FK (foreign key)
- A column holding another table's PK; it points to a row there
- e.g. orders.customer_id → which customer placed the order
- Can only hold a value that exists in the other table
- The table holding the FK is the "many" side

## UK (unique)
- No two rows can have the same value in that column
- Customer email (rule 18), staff email, warehouse name
- Delivery.order_id, which is what makes Orders → Delivery one-to-one

## The symbols
- || exactly one · o| zero or one · o{ zero or many · |{ one or many
- Customer ||--o{ Orders: a customer can have no orders yet
- Orders ||--|{ OrderItem: an order must have at least one item (rule 9)
- Orders ||--o| Delivery: no delivery until paid (rule 14)

## Delivery timestamps
- picked_up_at and delivered_at are empty when the delivery is created
- They're filled in as the status moves forward
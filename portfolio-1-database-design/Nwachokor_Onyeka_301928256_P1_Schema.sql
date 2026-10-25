-- Meridon Store schema (Portfolio 1)

DROP TABLE IF EXISTS delivery, payment, order_item, orders, stock_batch,
  product, customer, warehouse, staff, rider CASCADE;

CREATE TABLE warehouse (
  warehouse_id      INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name              TEXT NOT NULL UNIQUE CHECK (name IN ('Mainland', 'Island')),
  location_address  TEXT NOT NULL
);

CREATE TABLE customer (
  customer_id       INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name              TEXT NOT NULL,
  email             TEXT NOT NULL UNIQUE,                         -- rule 18
  phone             TEXT NOT NULL,
  delivery_address  TEXT NOT NULL
);

CREATE TABLE product (
  product_id  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name        TEXT NOT NULL,
  price       NUMERIC(10,2) NOT NULL CHECK (price > 0),          -- rule 3
  weight_g    NUMERIC(8,2)  NOT NULL CHECK (weight_g > 0),
  category    TEXT NOT NULL CHECK (category IN ('human', 'pet')), -- rule 1
  species     TEXT,
  CHECK (                                                         -- rule 2
    (category = 'pet'   AND species IN ('dog', 'cat')) OR
    (category = 'human' AND species IS NULL)
  )
);

CREATE TABLE stock_batch (
  batch_id       INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  product_id     INT NOT NULL REFERENCES product(product_id) ON DELETE RESTRICT,     -- rule 4
  warehouse_id   INT NOT NULL REFERENCES warehouse(warehouse_id) ON DELETE RESTRICT, -- rule 4
  quantity       INT  NOT NULL CHECK (quantity >= 0),             -- rule 5
  received_date  DATE NOT NULL,
  expiry_date    DATE NOT NULL,
  CHECK (expiry_date > received_date)                             -- rule 6
);

CREATE TABLE orders (
  order_id          INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  customer_id       INT NOT NULL REFERENCES customer(customer_id) ON DELETE RESTRICT,
  warehouse_id      INT NOT NULL REFERENCES warehouse(warehouse_id) ON DELETE RESTRICT, -- rule 10
  order_date        TIMESTAMP NOT NULL DEFAULT now(),
  delivery_address  TEXT NOT NULL
);

CREATE TABLE order_item (
  order_item_id  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  order_id       INT NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
  product_id     INT NOT NULL REFERENCES product(product_id) ON DELETE RESTRICT,
  quantity       INT NOT NULL CHECK (quantity >= 1),              -- rule 9
  unit_price     NUMERIC(10,2) NOT NULL CHECK (unit_price > 0),   -- rule 11
  UNIQUE (order_id, product_id)
);

CREATE TABLE payment (
  payment_id      INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  order_id        INT NOT NULL REFERENCES orders(order_id) ON DELETE RESTRICT,
  amount          NUMERIC(10,2) NOT NULL CHECK (amount > 0),
  payment_method  TEXT NOT NULL CHECK (payment_method IN ('card', 'transfer')), -- rule 12
  status          TEXT NOT NULL CHECK (status IN ('pending', 'success', 'failed')),
  paid_at         TIMESTAMP,
  CHECK (status <> 'success' OR paid_at IS NOT NULL)
);

-- rule 13: only one successful payment per order
CREATE UNIQUE INDEX one_success_per_order
  ON payment(order_id) WHERE status = 'success';

CREATE TABLE staff (
  staff_id       INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name           TEXT NOT NULL,
  email          TEXT NOT NULL UNIQUE,
  role           TEXT NOT NULL,
  password_hash  TEXT NOT NULL
);

CREATE TABLE rider (
  rider_id  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name      TEXT NOT NULL,
  phone     TEXT NOT NULL,
  status    TEXT NOT NULL CHECK (status IN ('active', 'inactive'))
);

CREATE TABLE delivery (
  delivery_id           INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  order_id              INT NOT NULL UNIQUE REFERENCES orders(order_id) ON DELETE RESTRICT, -- rule 15
  rider_id              INT NOT NULL REFERENCES rider(rider_id) ON DELETE RESTRICT,
  assigned_by_staff_id  INT NOT NULL REFERENCES staff(staff_id) ON DELETE RESTRICT,
  status                TEXT NOT NULL DEFAULT 'assigned'
                        CHECK (status IN ('assigned', 'picked_up', 'delivered')),
  delivery_code         TEXT NOT NULL,
  assigned_at           TIMESTAMP NOT NULL DEFAULT now(),
  picked_up_at          TIMESTAMP,
  delivered_at          TIMESTAMP,
  CHECK (                                   -- status and timestamps must agree
    (status = 'assigned'  AND picked_up_at IS NULL     AND delivered_at IS NULL) OR
    (status = 'picked_up' AND picked_up_at IS NOT NULL AND delivered_at IS NULL) OR
    (status = 'delivered' AND picked_up_at IS NOT NULL AND delivered_at IS NOT NULL)
  )
);

-- rule 9: every order must have at least one item (checked at commit)
CREATE FUNCTION order_has_items() RETURNS trigger AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM order_item WHERE order_id = NEW.order_id) THEN
    RAISE EXCEPTION 'Order % has no items', NEW.order_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER trg_order_has_items
  AFTER INSERT ON orders
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW EXECUTE FUNCTION order_has_items();

-- rule 11: unit_price cannot change after the item is added
CREATE FUNCTION lock_unit_price() RETURNS trigger AS $$
BEGIN
  IF NEW.unit_price <> OLD.unit_price THEN
    RAISE EXCEPTION 'unit_price cannot be changed after the order is placed';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_lock_unit_price
  BEFORE UPDATE ON order_item
  FOR EACH ROW EXECUTE FUNCTION lock_unit_price();

-- rule 14: no delivery until the order has a successful payment
CREATE FUNCTION require_payment() RETURNS trigger AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM payment
                 WHERE order_id = NEW.order_id AND status = 'success') THEN
    RAISE EXCEPTION 'Order % has no successful payment', NEW.order_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_require_payment
  BEFORE INSERT ON delivery
  FOR EACH ROW EXECUTE FUNCTION require_payment();

-- rule 16: delivery status can only move forward
CREATE FUNCTION status_forward_only() RETURNS trigger AS $$
DECLARE
  stages TEXT[] := ARRAY['assigned', 'picked_up', 'delivered'];
BEGIN
  IF array_position(stages, NEW.status) < array_position(stages, OLD.status) THEN
    RAISE EXCEPTION 'Delivery status cannot move from % back to %', OLD.status, NEW.status;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_status_forward_only
  BEFORE UPDATE ON delivery
  FOR EACH ROW EXECUTE FUNCTION status_forward_only();
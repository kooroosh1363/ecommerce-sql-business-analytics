-- DA-02: E-commerce SQL Business Analytics
-- PostgreSQL 15+

DROP TABLE IF EXISTS order_items, orders, products, customers CASCADE;

CREATE TABLE customers (
    customer_id BIGINT PRIMARY KEY,
    signup_date DATE NOT NULL,
    region TEXT NOT NULL,
    acquisition_channel TEXT NOT NULL CHECK (acquisition_channel IN ('organic','paid_search','social','referral','email'))
);

CREATE TABLE products (
    product_id BIGINT PRIMARY KEY,
    product_name TEXT NOT NULL,
    category TEXT NOT NULL,
    unit_price NUMERIC(12,2) NOT NULL CHECK (unit_price > 0),
    unit_cost NUMERIC(12,2) NOT NULL CHECK (unit_cost >= 0 AND unit_cost < unit_price)
);

CREATE TABLE orders (
    order_id BIGINT PRIMARY KEY,
    customer_id BIGINT NOT NULL REFERENCES customers(customer_id),
    order_date DATE NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('completed','cancelled','refunded')),
    payment_method TEXT NOT NULL CHECK (payment_method IN ('card','paypal','wallet','bank_transfer')),
    shipping_region TEXT NOT NULL
);

CREATE TABLE order_items (
    order_id BIGINT NOT NULL REFERENCES orders(order_id),
    product_id BIGINT NOT NULL REFERENCES products(product_id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(12,2) NOT NULL CHECK (unit_price > 0),
    discount_pct NUMERIC(5,4) NOT NULL DEFAULT 0 CHECK (discount_pct BETWEEN 0 AND 1),
    PRIMARY KEY (order_id, product_id)
);

CREATE INDEX idx_orders_customer_date ON orders(customer_id, order_date);
CREATE INDEX idx_orders_date_status ON orders(order_date, status);
CREATE INDEX idx_order_items_product ON order_items(product_id);
CREATE INDEX idx_customers_signup ON customers(signup_date);

COMMENT ON TABLE order_items IS 'Line-item fact table; revenue is calculated from quantity, unit_price and discount_pct.';

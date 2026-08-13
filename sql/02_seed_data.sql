-- Deterministic synthetic dataset: 1,200 customers, 120 products, 8,000 orders.
-- No external dataset is required; rerunning this script produces the same analytical population.

INSERT INTO customers
SELECT i,
       DATE '2023-01-01' + ((i * 17) % 730),
       (ARRAY['North America','Europe','Asia-Pacific','Middle East'])[(i % 4) + 1],
       (ARRAY['organic','paid_search','social','referral','email'])[(i % 5) + 1]
FROM generate_series(1,1200) AS g(i);

INSERT INTO products
SELECT i,
       'Product ' || LPAD(i::text, 3, '0'),
       (ARRAY['Electronics','Home','Beauty','Sports','Books','Fashion'])[(i % 6) + 1],
       ROUND((9.99 + (i % 50) * 3.70)::numeric, 2),
       ROUND(((9.99 + (i % 50) * 3.70) * 0.58)::numeric, 2)
FROM generate_series(1,120) AS g(i);

-- Order dates are derived from each customer's signup date so the synthetic
-- dataset is temporally valid by construction while remaining deterministic.
WITH generated_orders AS (
    SELECT
        i AS order_id,
        ((i * 37) % 1200) + 1 AS customer_id
    FROM generate_series(1,8000) AS g(i)
)
INSERT INTO orders
SELECT
       g.order_id,
       g.customer_id,
       c.signup_date + ((g.order_id * 11) % 366),
       CASE WHEN g.order_id % 20 = 0 THEN 'cancelled'
            WHEN g.order_id % 20 = 1 THEN 'refunded'
            ELSE 'completed' END,
       (ARRAY['card','paypal','wallet','bank_transfer'])[(g.order_id % 4) + 1],
       (ARRAY['North America','Europe','Asia-Pacific','Middle East'])[(g.order_id % 4) + 1]
FROM generated_orders g
JOIN customers c USING (customer_id);

-- 2-4 line items per order, with deterministic product selection and discounts.
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount_pct)
SELECT o.order_id,
       p.product_id,
       1 + ((o.order_id + x.n) % 4),
       p.unit_price,
       CASE WHEN (o.order_id + x.n) % 10 = 0 THEN 0.15
            WHEN (o.order_id + x.n) % 7 = 0 THEN 0.10
            ELSE 0 END
FROM orders o
CROSS JOIN LATERAL generate_series(1, 2 + (o.order_id % 3)) AS x(n)
JOIN products p ON p.product_id = (((o.order_id * 13 + x.n * 17) % 120) + 1)
ON CONFLICT (order_id, product_id) DO NOTHING;

ANALYZE customers;
ANALYZE products;
ANALYZE orders;
ANALYZE order_items;

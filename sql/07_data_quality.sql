-- Data-quality checks. Every query should return zero rows unless stated otherwise.

-- Orphan orders
SELECT o.* FROM orders o LEFT JOIN customers c USING(customer_id) WHERE c.customer_id IS NULL;

-- Orphan line items
SELECT oi.* FROM order_items oi LEFT JOIN orders o USING(order_id) WHERE o.order_id IS NULL;

-- Invalid economics
SELECT * FROM products WHERE unit_cost < 0 OR unit_price <= 0 OR unit_cost >= unit_price;

-- Invalid line items
SELECT * FROM order_items WHERE quantity <= 0 OR unit_price <= 0 OR discount_pct NOT BETWEEN 0 AND 1;

-- Duplicate grain
SELECT order_id, product_id, COUNT(*) FROM order_items GROUP BY 1,2 HAVING COUNT(*) > 1;

-- Orders that predate customer signup (synthetic data is allowed to expose this check; production pipelines should quarantine violations)
SELECT COUNT(*) AS temporal_violations
FROM orders o JOIN customers c USING(customer_id)
WHERE o.order_date < c.signup_date;

-- Reconciliation: realized revenue should equal sum of completed line-item net revenue.
WITH source_total AS (
    SELECT SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct)) AS revenue
    FROM orders o JOIN order_items oi USING(order_id)
    WHERE o.status='completed'
), view_total AS (
    SELECT SUM(net_revenue) AS revenue FROM v_order_financials
)
SELECT ROUND(s.revenue,2) AS source_revenue, ROUND(v.revenue,2) AS view_revenue,
       ROUND(s.revenue-v.revenue,2) AS difference
FROM source_total s CROSS JOIN view_total v;

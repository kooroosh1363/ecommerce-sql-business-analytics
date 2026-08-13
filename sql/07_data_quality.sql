-- Data-quality and reconciliation checks.
-- Exception queries should return zero rows. Aggregate checks state their expected result.

-- Orphan orders: expected 0 rows.
SELECT o.* FROM orders o LEFT JOIN customers c USING(customer_id) WHERE c.customer_id IS NULL;

-- Orphan line items: expected 0 rows.
SELECT oi.* FROM order_items oi LEFT JOIN orders o USING(order_id) WHERE o.order_id IS NULL;

-- Invalid economics: expected 0 rows.
SELECT * FROM products WHERE unit_cost < 0 OR unit_price <= 0 OR unit_cost >= unit_price;

-- Invalid line items: expected 0 rows.
SELECT * FROM order_items WHERE quantity <= 0 OR unit_price <= 0 OR discount_pct NOT BETWEEN 0 AND 1;

-- Duplicate grain: expected 0 rows.
SELECT order_id, product_id, COUNT(*) FROM order_items GROUP BY 1,2 HAVING COUNT(*) > 1;

-- Temporal consistency: expected temporal_violations = 0.
SELECT COUNT(*) AS temporal_violations
FROM orders o JOIN customers c USING(customer_id)
WHERE o.order_date < c.signup_date;

-- Reconciliation: expected difference = 0.00.
-- v_order_financials stores one rounded currency amount per completed order,
-- so source reconciliation uses the same order-level grain before summing.
WITH source_by_order AS (
    SELECT
        o.order_id,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct))::numeric(14,2) AS net_revenue
    FROM orders o
    JOIN order_items oi USING(order_id)
    WHERE o.status='completed'
    GROUP BY o.order_id
), source_total AS (
    SELECT SUM(net_revenue) AS revenue FROM source_by_order
), view_total AS (
    SELECT SUM(net_revenue) AS revenue FROM v_order_financials
)
SELECT ROUND(s.revenue,2) AS source_revenue,
       ROUND(v.revenue,2) AS view_revenue,
       ROUND(s.revenue-v.revenue,2) AS difference
FROM source_total s CROSS JOIN view_total v;

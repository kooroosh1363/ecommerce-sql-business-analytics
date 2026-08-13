-- Query-performance examples for PostgreSQL.
-- Run with EXPLAIN (ANALYZE, BUFFERS) after loading the dataset.

EXPLAIN (ANALYZE, BUFFERS)
SELECT customer_id, COUNT(*) AS orders, SUM(net_revenue) AS revenue
FROM v_order_financials
WHERE order_date >= DATE '2025-01-01'
GROUP BY customer_id
ORDER BY revenue DESC
LIMIT 20;

EXPLAIN (ANALYZE, BUFFERS)
SELECT o.order_date, p.category,
       SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct)) AS revenue
FROM orders o
JOIN order_items oi USING(order_id)
JOIN products p USING(product_id)
WHERE o.status='completed'
  AND o.order_date BETWEEN DATE '2025-01-01' AND DATE '2025-12-31'
GROUP BY o.order_date, p.category;

-- Indexes in 01_schema.sql target common access paths:
-- (customer_id, order_date), (order_date, status), and product_id.
-- In a real warehouse, compare plans before/after indexes and retain only indexes
-- whose read benefit justifies write/storage cost.

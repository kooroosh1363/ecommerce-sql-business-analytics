-- Reusable analytical layer. Cancelled/refunded orders are excluded from realized revenue.

CREATE OR REPLACE VIEW v_order_financials AS
SELECT
    o.order_id,
    o.customer_id,
    o.order_date,
    o.shipping_region,
    o.payment_method,
    SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct))::numeric(14,2) AS net_revenue,
    SUM(oi.quantity * p.unit_cost)::numeric(14,2) AS cogs,
    (SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct)) - SUM(oi.quantity * p.unit_cost))::numeric(14,2) AS gross_profit
FROM orders o
JOIN order_items oi USING (order_id)
JOIN products p USING (product_id)
WHERE o.status = 'completed'
GROUP BY 1,2,3,4,5;

CREATE OR REPLACE VIEW v_customer_metrics AS
SELECT
    c.customer_id,
    c.region,
    c.acquisition_channel,
    COUNT(f.order_id) AS completed_orders,
    COALESCE(SUM(f.net_revenue),0)::numeric(14,2) AS lifetime_revenue,
    COALESCE(SUM(f.gross_profit),0)::numeric(14,2) AS lifetime_gross_profit,
    MIN(f.order_date) AS first_order_date,
    MAX(f.order_date) AS last_order_date
FROM customers c
LEFT JOIN v_order_financials f USING (customer_id)
GROUP BY 1,2,3;

CREATE OR REPLACE VIEW v_monthly_kpis AS
SELECT
    DATE_TRUNC('month', order_date)::date AS month,
    COUNT(*) AS orders,
    COUNT(DISTINCT customer_id) AS active_customers,
    SUM(net_revenue)::numeric(14,2) AS revenue,
    SUM(gross_profit)::numeric(14,2) AS gross_profit,
    ROUND(AVG(net_revenue),2) AS aov
FROM v_order_financials
GROUP BY 1
ORDER BY 1;

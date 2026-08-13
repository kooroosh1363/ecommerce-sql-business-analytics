-- BUSINESS QUESTION 1: What is the executive performance snapshot?
SELECT
    COUNT(*) AS completed_orders,
    COUNT(DISTINCT customer_id) AS purchasing_customers,
    ROUND(SUM(net_revenue),2) AS revenue,
    ROUND(SUM(gross_profit),2) AS gross_profit,
    ROUND(100 * SUM(gross_profit) / NULLIF(SUM(net_revenue),0),2) AS gross_margin_pct,
    ROUND(AVG(net_revenue),2) AS average_order_value
FROM v_order_financials;

-- BUSINESS QUESTION 2: How are revenue and orders trending month over month?
WITH monthly AS (
    SELECT * FROM v_monthly_kpis
)
SELECT
    month, orders, active_customers, revenue, gross_profit, aov,
    ROUND(100 * (revenue - LAG(revenue) OVER (ORDER BY month)) /
          NULLIF(LAG(revenue) OVER (ORDER BY month),0), 2) AS revenue_mom_pct,
    SUM(revenue) OVER (ORDER BY month) AS cumulative_revenue
FROM monthly
ORDER BY month;

-- BUSINESS QUESTION 3: Which regions create the most value?
SELECT
    shipping_region,
    COUNT(*) AS orders,
    ROUND(SUM(net_revenue),2) AS revenue,
    ROUND(SUM(gross_profit),2) AS gross_profit,
    ROUND(AVG(net_revenue),2) AS aov,
    ROUND(100 * SUM(net_revenue) / SUM(SUM(net_revenue)) OVER (),2) AS revenue_share_pct
FROM v_order_financials
GROUP BY shipping_region
ORDER BY revenue DESC;

-- BUSINESS QUESTION 4: What share of placed orders fails to become completed revenue?
SELECT
    status,
    COUNT(*) AS orders,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),2) AS order_share_pct
FROM orders
GROUP BY status
ORDER BY orders DESC;

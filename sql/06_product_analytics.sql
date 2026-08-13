-- BUSINESS QUESTION 8: Which products and categories drive revenue and profit?
WITH product_perf AS (
    SELECT
        p.product_id, p.product_name, p.category,
        SUM(oi.quantity) AS units_sold,
        SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct)) AS revenue,
        SUM(oi.quantity * (oi.unit_price * (1 - oi.discount_pct) - p.unit_cost)) AS gross_profit
    FROM orders o
    JOIN order_items oi USING (order_id)
    JOIN products p USING (product_id)
    WHERE o.status = 'completed'
    GROUP BY 1,2,3
)
SELECT *,
       ROUND(100 * gross_profit / NULLIF(revenue,0),2) AS gross_margin_pct,
       DENSE_RANK() OVER (ORDER BY revenue DESC) AS revenue_rank,
       DENSE_RANK() OVER (ORDER BY gross_profit DESC) AS profit_rank
FROM product_perf
ORDER BY revenue DESC;

-- BUSINESS QUESTION 9: Does the catalog exhibit a Pareto / concentration effect?
WITH product_revenue AS (
    SELECT p.product_id, p.product_name,
           SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct)) AS revenue
    FROM orders o JOIN order_items oi USING(order_id) JOIN products p USING(product_id)
    WHERE o.status = 'completed'
    GROUP BY 1,2
), ranked AS (
    SELECT *,
           SUM(revenue) OVER (ORDER BY revenue DESC) AS cumulative_revenue,
           SUM(revenue) OVER () AS total_revenue,
           ROW_NUMBER() OVER (ORDER BY revenue DESC) AS product_rank,
           COUNT(*) OVER () AS product_count
    FROM product_revenue
)
SELECT *,
       ROUND(100 * cumulative_revenue / total_revenue,2) AS cumulative_revenue_pct,
       ROUND(100.0 * product_rank / product_count,2) AS cumulative_product_pct
FROM ranked
ORDER BY product_rank;

-- BUSINESS QUESTION 10: Which categories combine scale and healthy margin?
SELECT
    p.category,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct)),2) AS revenue,
    ROUND(SUM(oi.quantity * (oi.unit_price * (1 - oi.discount_pct) - p.unit_cost)),2) AS gross_profit,
    ROUND(100 * SUM(oi.quantity * (oi.unit_price * (1 - oi.discount_pct) - p.unit_cost)) /
          NULLIF(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct)),0),2) AS gross_margin_pct
FROM orders o JOIN order_items oi USING(order_id) JOIN products p USING(product_id)
WHERE o.status = 'completed'
GROUP BY p.category
ORDER BY gross_profit DESC;

-- BUSINESS QUESTION 5: Which customers should retention and CRM teams prioritize?
-- RFM scoring with window functions (5 = strongest behavior).
WITH bounds AS (
    SELECT MAX(order_date) + 1 AS as_of_date FROM v_order_financials
), rfm AS (
    SELECT
        customer_id,
        (SELECT as_of_date FROM bounds) - MAX(order_date) AS recency_days,
        COUNT(*) AS frequency,
        SUM(net_revenue) AS monetary
    FROM v_order_financials
    GROUP BY customer_id
), scored AS (
    SELECT *,
        6 - NTILE(5) OVER (ORDER BY recency_days ASC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary ASC) AS m_score
    FROM rfm
)
SELECT *,
    CASE
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
        WHEN r_score >= 3 AND f_score >= 3 THEN 'Loyal'
        WHEN r_score <= 2 AND f_score >= 3 THEN 'At Risk'
        WHEN r_score >= 4 AND f_score <= 2 THEN 'Promising'
        ELSE 'Needs Attention'
    END AS segment
FROM scored
ORDER BY monetary DESC;

-- BUSINESS QUESTION 6: How well do acquisition cohorts retain customers?
WITH first_purchase AS (
    SELECT customer_id, DATE_TRUNC('month', MIN(order_date))::date AS cohort_month
    FROM v_order_financials GROUP BY customer_id
), activity AS (
    SELECT DISTINCT
        f.customer_id,
        fp.cohort_month,
        DATE_TRUNC('month', f.order_date)::date AS activity_month,
        (EXTRACT(YEAR FROM AGE(DATE_TRUNC('month', f.order_date), fp.cohort_month)) * 12 +
         EXTRACT(MONTH FROM AGE(DATE_TRUNC('month', f.order_date), fp.cohort_month)))::int AS month_number
    FROM v_order_financials f
    JOIN first_purchase fp USING (customer_id)
), cohort_size AS (
    SELECT cohort_month, COUNT(DISTINCT customer_id) AS customers
    FROM activity WHERE month_number = 0 GROUP BY cohort_month
)
SELECT
    a.cohort_month,
    a.month_number,
    COUNT(DISTINCT a.customer_id) AS retained_customers,
    cs.customers AS cohort_size,
    ROUND(100.0 * COUNT(DISTINCT a.customer_id) / cs.customers,2) AS retention_pct
FROM activity a
JOIN cohort_size cs USING (cohort_month)
GROUP BY a.cohort_month, a.month_number, cs.customers
ORDER BY a.cohort_month, a.month_number;

-- BUSINESS QUESTION 7: Which acquisition channels produce higher-value customers?
SELECT
    acquisition_channel,
    COUNT(*) FILTER (WHERE completed_orders > 0) AS buyers,
    ROUND(AVG(lifetime_revenue) FILTER (WHERE completed_orders > 0),2) AS avg_customer_revenue,
    ROUND(AVG(completed_orders) FILTER (WHERE completed_orders > 0),2) AS avg_orders_per_buyer,
    ROUND(100.0 * COUNT(*) FILTER (WHERE completed_orders > 1) /
          NULLIF(COUNT(*) FILTER (WHERE completed_orders > 0),0),2) AS repeat_buyer_pct
FROM v_customer_metrics
GROUP BY acquisition_channel
ORDER BY avg_customer_revenue DESC;

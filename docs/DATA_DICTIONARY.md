# Data Dictionary

## Grain

| Table / View | Grain |
|---|---|
| `customers` | one row per customer |
| `products` | one row per product |
| `orders` | one row per order |
| `order_items` | one row per order-product pair |
| `v_order_financials` | one row per completed order |
| `v_customer_metrics` | one row per customer |
| `v_monthly_kpis` | one row per calendar month |

## Core metric definitions

**Net Revenue** = `quantity × unit_price × (1 - discount_pct)` for completed orders only.

**COGS** = `quantity × product.unit_cost` for completed orders.

**Gross Profit** = `Net Revenue - COGS`.

**Gross Margin %** = `Gross Profit / Net Revenue × 100`.

**AOV** = `Net Revenue / Completed Orders`.

**Active Customer** = customer with at least one completed order in the measurement period.

**Repeat Buyer** = customer with more than one completed order.

**Cohort Month** = calendar month of a customer's first completed purchase.

**Retention %** = distinct customers active in cohort month N / original cohort size.

## Modeling decisions

Cancelled and refunded orders are preserved in the operational `orders` table for funnel/failure analysis but excluded from realized revenue. Financial calculations use line-item selling price after discount rather than catalog list price. Product cost is joined from the product dimension to estimate gross profit.

The included dataset is deterministic and synthetic. It exists to make the repository reproducible and to demonstrate SQL technique; findings from it are portfolio demonstrations, not claims about a real company.

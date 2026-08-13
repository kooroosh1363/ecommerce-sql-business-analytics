<div align="center">

# 🛒 DA-02 — E-commerce SQL Business Analytics

### PostgreSQL · Business KPIs · RFM · Cohort Retention · Window Functions · Query Performance

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-Advanced-0A66C2?style=for-the-badge)
![Analytics](https://img.shields.io/badge/Focus-Business_Analytics-2EA44F?style=for-the-badge)
![Data](https://img.shields.io/badge/Dataset-Reproducible-orange?style=for-the-badge)

**A portfolio-grade SQL case study that turns normalized e-commerce transactions into decision-ready customer, product, revenue, retention, and profitability insights.**

</div>

---

## 🎯 Business Problem

An e-commerce leadership team needs more than a revenue total. They need to understand **growth, profitability, customer quality, retention, acquisition performance, product concentration, and operational leakage** from cancelled/refunded orders.

This project builds that analytical layer directly in PostgreSQL and answers ten business questions using reusable SQL rather than notebook-only analysis.

## 🧠 What This Project Demonstrates

`JOINs` · `CTEs` · `CASE` · `FILTER` · `LAG` · `NTILE` · `DENSE_RANK` · `ROW_NUMBER` · cumulative windows · RFM · cohort retention · Pareto analysis · analytical views · indexes · `EXPLAIN ANALYZE` · data-quality reconciliation

Unlike a dashboard-only project, the emphasis here is on the **SQL reasoning and data model underneath business metrics**.

---

## 🏗️ Data Model

```text
customers (1) ─────< orders (1) ─────< order_items >───── (1) products
 customer_id          order_id          order_id               product_id
 signup_date           order_date        product_id             category
 region                status            quantity               unit_price
 acquisition_channel   payment_method    selling price          unit_cost
```

The operational model preserves cancelled/refunded orders for failure analysis, while realized revenue views intentionally include **completed orders only**.

See [`docs/DATA_DICTIONARY.md`](docs/DATA_DICTIONARY.md) for grain and metric definitions.

---

## ❓ Ten Business Questions

1. What is the executive performance snapshot: revenue, orders, AOV, gross profit and margin?
2. How are revenue and active customers trending month over month?
3. Which regions create the most value?
4. What share of placed orders is cancelled or refunded?
5. Which customers should retention teams prioritize using RFM?
6. How does retention evolve by first-purchase cohort?
7. Which acquisition channels produce higher-value and repeat customers?
8. Which products drive revenue and gross profit?
9. Is revenue concentrated in a small share of the catalog?
10. Which categories combine scale with healthy margins?

Full case-study framing: [`docs/BUSINESS_QUESTIONS.md`](docs/BUSINESS_QUESTIONS.md).

---

## 🔍 Advanced SQL Highlights

### RFM segmentation

Customers are scored with `NTILE(5)` across recency, frequency, and monetary value, then translated into actionable CRM segments such as **Champions, Loyal, At Risk, Promising, and Needs Attention**.

### Cohort retention

First-purchase month defines each cohort. Subsequent monthly activity is converted into `month_number`, allowing retention to be compared across cohorts with different start dates.

### Growth analytics

`LAG()` calculates month-over-month revenue growth while cumulative window sums expose the growth trajectory without collapsing row-level monthly context.

### Product concentration

Running revenue totals and catalog rank calculate a Pareto curve: what percentage of products generates what percentage of revenue?

### Profitability

Revenue is not treated as profit. The model tracks product cost and computes gross profit and gross margin independently.

---

## 📁 Repository Structure

```text
.
├── docker-compose.yml
├── Makefile
├── README.md
├── docs/
│   ├── BUSINESS_QUESTIONS.md
│   └── DATA_DICTIONARY.md
└── sql/
    ├── 01_schema.sql
    ├── 02_seed_data.sql
    ├── 03_analytics_views.sql
    ├── 04_business_kpis.sql
    ├── 05_customer_analytics.sql
    ├── 06_product_analytics.sql
    ├── 07_data_quality.sql
    └── 08_performance.sql
```

---

## 🚀 Run Locally

Prerequisite: Docker with Docker Compose.

```bash
git clone https://github.com/kooroosh1363/ecommerce-sql-business-analytics.git
cd ecommerce-sql-business-analytics
docker compose up -d
```

The container initializes the schema, deterministic dataset, and analytical views automatically.

Then run analyses:

```bash
make kpis
make customers
make products
make quality
```

Or open PostgreSQL directly:

```bash
make psql
```

Reset everything with:

```bash
make down
```

---

## 🧪 Reproducibility & Data Quality

The repository generates a deterministic synthetic e-commerce population inside PostgreSQL: **1,200 customers, 120 products, and 8,000 orders**, with multiple line items per order. No private or external dataset is required.

The validation suite checks referential integrity, invalid economics, duplicate grain, temporal consistency, and source-to-view revenue reconciliation.

> The dataset is intentionally synthetic. It exists to demonstrate analytical engineering and SQL technique; its outputs are not presented as findings about a real company.

---

## ⚡ Performance Thinking

The schema includes indexes aligned to common analytical access paths. [`sql/08_performance.sql`](sql/08_performance.sql) provides `EXPLAIN (ANALYZE, BUFFERS)` examples for customer and product queries.

The point is not to add indexes blindly: production optimization should compare execution plans and balance read performance against write/storage cost.

---

## 💼 Why This Is a Portfolio Project

This repository demonstrates the layer between raw transactions and a dashboard:

**Business question → data model → metric definition → SQL analysis → validation → decision-ready output**

It complements visualization-focused analytics work by making the underlying analytical logic reviewable directly in SQL.

---

<div align="center">

### Data → Metrics → Customer & Product Insight → Business Decisions

**DA-02 in the Data Analytics portfolio roadmap**

</div>

DB=ecommerce_analytics
USER=analyst

up:
	docker compose up -d

down:
	docker compose down -v

psql:
	docker compose exec postgres psql -U $(USER) -d $(DB)

kpis:
	docker compose exec -T postgres psql -U $(USER) -d $(DB) -f /dev/stdin < sql/04_business_kpis.sql

customers:
	docker compose exec -T postgres psql -U $(USER) -d $(DB) -f /dev/stdin < sql/05_customer_analytics.sql

products:
	docker compose exec -T postgres psql -U $(USER) -d $(DB) -f /dev/stdin < sql/06_product_analytics.sql

quality:
	docker compose exec -T postgres psql -U $(USER) -d $(DB) -f /dev/stdin < sql/07_data_quality.sql

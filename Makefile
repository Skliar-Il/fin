.PHONY: help seed seed-clean seed-reset up down restart logs db-shell test

# Переменные
DOCKER_COMPOSE = docker-compose
DB_CONTAINER = db
DB_USER = finance_app_user
DB_NAME = finance
SEED_FILE = seed_data.sql

help: ## Показать справку
	@echo "Доступные команды:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

seed: ## Загрузить тестовые данные в БД
	@echo "Загрузка тестовых данных..."
	@if [ -d "venv" ]; then \
		venv/bin/python scripts/load_seed.py; \
	else \
		python3 scripts/load_seed.py; \
	fi
	@echo "Данные успешно загружены!"

seed-clean: ## Очистить все данные из БД
	@echo "Очистка данных..."
	@$(DOCKER_COMPOSE) exec $(DB_CONTAINER) psql -U $(DB_USER) -d $(DB_NAME) -c "TRUNCATE TABLE finance.transactions CASCADE; TRUNCATE TABLE finance.budgets CASCADE; TRUNCATE TABLE finance.accounts CASCADE; TRUNCATE TABLE finance.users_info CASCADE; TRUNCATE TABLE finance.users CASCADE; TRUNCATE TABLE finance.categories CASCADE;"
	@echo "Данные очищены!"

seed-reset: seed-clean seed ## Очистить и загрузить данные заново
	@echo "Данные перезагружены!"

up: ## Запустить контейнеры
	@$(DOCKER_COMPOSE) up -d
	@echo "Контейнеры запущены!"

down: ## Остановить контейнеры
	@$(DOCKER_COMPOSE) down
	@echo "Контейнеры остановлены!"

restart: down up ## Перезапустить контейнеры

logs: ## Показать логи контейнеров
	@$(DOCKER_COMPOSE) logs -f

db-shell: ## Открыть shell для работы с БД
	@$(DOCKER_COMPOSE) exec $(DB_CONTAINER) psql -U $(DB_USER) -d $(DB_NAME)

db-init: ## Инициализировать БД (выполнить init.sql)
	@echo "Инициализация БД..."
	@$(DOCKER_COMPOSE) exec -T $(DB_CONTAINER) psql -U $(DB_USER) -d $(DB_NAME) -f - < init.sql
	@echo "БД инициализирована!"

test-connection: ## Проверить подключение к БД
	@$(DOCKER_COMPOSE) exec $(DB_CONTAINER) psql -U $(DB_USER) -d $(DB_NAME) -c "SELECT version();"

test-data: ## Проверить наличие тестовых данных
	@echo "Проверка данных..."
	@$(DOCKER_COMPOSE) exec $(DB_CONTAINER) psql -U $(DB_USER) -d $(DB_NAME) -c "SELECT 'Users:' as table_name, COUNT(*) as count FROM finance.users UNION ALL SELECT 'Accounts:', COUNT(*) FROM finance.accounts UNION ALL SELECT 'Transactions:', COUNT(*) FROM finance.transactions UNION ALL SELECT 'Categories:', COUNT(*) FROM finance.categories UNION ALL SELECT 'Budgets:', COUNT(*) FROM finance.budgets;"

build: ## Пересобрать контейнеры
	@$(DOCKER_COMPOSE) build
	@echo "Контейнеры пересобраны!"

start-app: ## Запустить приложение (uvicorn)
	@echo "Запуск приложения..."
	@uvicorn src.main:app --reload --host 0.0.0.0 --port 8000


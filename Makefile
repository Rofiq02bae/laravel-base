# Laravel Base Makefile
# Quick commands for development

.PHONY: help start stop restart status logs shell artisan composer migrate fresh test clear build cleanup backup health urls

# Default target
.DEFAULT_GOAL := help

# Variables
COMPOSE := docker-compose
APP_SERVICE := app
DB_SERVICE := database

help: ## Show this help message
	@echo "Laravel Base Development Commands"
	@echo "================================="
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Docker Services
start: ## Start all services
	@echo "🚀 Starting services..."
	@cd laravel12 && $(COMPOSE) up -d
	@echo "✅ Services started!"

stop: ## Stop all services
	@echo "🛑 Stopping services..."
	@cd laravel12 && $(COMPOSE) down
	@echo "✅ Services stopped!"

restart: ## Restart all services
	@echo "🔄 Restarting services..."
	@cd laravel12 && $(COMPOSE) restart
	@echo "✅ Services restarted!"

status: ## Show service status
	@echo "📊 Service status:"
	@cd laravel12 && $(COMPOSE) ps

logs: ## Show logs for all services
	@cd laravel12 && $(COMPOSE) logs -f

logs-app: ## Show logs for app service
	@cd laravel12 && $(COMPOSE) logs -f $(APP_SERVICE)

build: ## Build containers
	@echo "🔨 Building containers..."
	@cd laravel12 && $(COMPOSE) build --no-cache
	@echo "✅ Containers built!"

##@ Development
shell: ## Access app container shell
	@cd laravel12 && $(COMPOSE) exec $(APP_SERVICE) bash

shell-db: ## Access database container shell
	@cd laravel12 && $(COMPOSE) exec $(DB_SERVICE) mysql -u laravel123 -plaravel123 laravel

install: ## Install composer dependencies
	@echo "📦 Installing dependencies..."
	@cd laravel12 && $(COMPOSE) exec $(APP_SERVICE) composer install
	@echo "✅ Dependencies installed!"

update: ## Update composer dependencies
	@echo "📦 Updating dependencies..."
	@cd laravel12 && $(COMPOSE) exec $(APP_SERVICE) composer update
	@echo "✅ Dependencies updated!"

##@ Laravel Commands
artisan-list: ## List all artisan commands
	@cd laravel12 && $(COMPOSE) exec $(APP_SERVICE) php artisan list

migrate: ## Run database migrations
	@echo "🗄️ Running migrations..."
	@cd laravel12 && $(COMPOSE) exec $(APP_SERVICE) php artisan migrate
	@echo "✅ Migrations completed!"

migrate-fresh: ## Fresh migration with seeding
	@echo "🗄️ Running fresh migration..."
	@cd laravel12 && $(COMPOSE) exec $(APP_SERVICE) php artisan migrate:fresh --seed
	@echo "✅ Fresh migration completed!"

seed: ## Run database seeding
	@echo "🌱 Running database seeding..."
	@cd laravel12 && $(COMPOSE) exec $(APP_SERVICE) php artisan db:seed
	@echo "✅ Seeding completed!"

test: ## Run tests
	@echo "🧪 Running tests..."
	@cd laravel12 && $(COMPOSE) exec $(APP_SERVICE) php artisan test
	@echo "✅ Tests completed!"

##@ Cache Management
clear: ## Clear all caches
	@echo "🧹 Clearing caches..."
	@cd laravel12 && $(COMPOSE) exec $(APP_SERVICE) php artisan config:clear
	@cd laravel12 && $(COMPOSE) exec $(APP_SERVICE) php artisan cache:clear
	@cd laravel12 && $(COMPOSE) exec $(APP_SERVICE) php artisan route:clear
	@cd laravel12 && $(COMPOSE) exec $(APP_SERVICE) php artisan view:clear
	@echo "✅ All caches cleared!"

optimize: ## Optimize application
	@echo "⚡ Optimizing application..."
	@cd laravel12 && $(COMPOSE) exec $(APP_SERVICE) php artisan config:cache
	@cd laravel12 && $(COMPOSE) exec $(APP_SERVICE) php artisan route:cache
	@cd laravel12 && $(COMPOSE) exec $(APP_SERVICE) php artisan view:cache
	@echo "✅ Application optimized!"

##@ Database Management
backup: ## Backup database
	@echo "💾 Creating database backup..."
	@cd laravel12 && $(COMPOSE) exec $(DB_SERVICE) mysqldump -u laravel123 -plaravel123 laravel > backup_$$(date +%Y%m%d_%H%M%S).sql
	@echo "✅ Database backup created!"

##@ Maintenance
cleanup: ## Clean up containers and images
	@echo "🧹 Cleaning up Docker resources..."
	@cd laravel12 && $(COMPOSE) down --volumes --remove-orphans
	@docker system prune -f
	@echo "✅ Cleanup completed!"

permissions: ## Fix file permissions
	@echo "🔐 Fixing permissions..."
	@cd laravel12 && $(COMPOSE) exec --user root $(APP_SERVICE) chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache
	@cd laravel12 && $(COMPOSE) exec --user root $(APP_SERVICE) chmod -R 775 /var/www/storage /var/www/bootstrap/cache
	@echo "✅ Permissions fixed!"

##@ Health & Monitoring
health: ## Check application health
	@echo "🏥 Checking application health..."
	@curl -f http://localhost/health > /dev/null 2>&1 && echo "✅ Application is healthy" || echo "❌ Application is not responding"
	@curl -f http://localhost:8888 > /dev/null 2>&1 && echo "✅ phpMyAdmin is healthy" || echo "❌ phpMyAdmin is not responding"
	@curl -f http://localhost:8025 > /dev/null 2>&1 && echo "✅ Mailhog is healthy" || echo "❌ Mailhog is not responding"

urls: ## Show service URLs
	@echo "📱 Service URLs:"
	@echo "=================================="
	@echo "🌐 Laravel App:      http://localhost"
	@echo "💊 Health Check:     http://localhost/health"
	@echo "🗄️ phpMyAdmin:       http://localhost:8888"
	@echo "📧 Mailhog:          http://localhost:8025"
	@echo ""
	@echo "🧪 Test Endpoints:"
	@echo "=================================="
	@echo "Simple Email:     http://localhost/test-mail"
	@echo "HTML Email:       http://localhost/test-mail-html"
	@echo "Multiple Email:   http://localhost/test-mail-multiple"

##@ Quick Setup
quick-start: ## Quick start for new setup
	@echo "🚀 Quick starting Laravel Base..."
	@./quick-start.sh

setup: start migrate permissions ## Complete setup (start + migrate + permissions)
	@echo "🎉 Setup completed successfully!"
	@make urls

##@ Email Testing
test-email: ## Send test email
	@echo "📧 Sending test email..."
	@curl -s http://localhost/test-mail && echo ""

test-email-html: ## Send HTML test email
	@echo "📧 Sending HTML test email..."
	@curl -s http://localhost/test-mail-html && echo ""

test-email-multiple: ## Send multiple recipient test email
	@echo "📧 Sending multiple recipient test email..."
	@curl -s http://localhost/test-mail-multiple && echo ""

##@ Custom Artisan Commands (examples)
make-controller: ## Create a new controller (usage: make make-controller name=UserController)
	@cd laravel12 && $(COMPOSE) exec $(APP_SERVICE) php artisan make:controller $(name)

make-model: ## Create a new model (usage: make make-model name=User)
	@cd laravel12 && $(COMPOSE) exec $(APP_SERVICE) php artisan make:model $(name)

make-migration: ## Create a new migration (usage: make make-migration name=create_users_table)
	@cd laravel12 && $(COMPOSE) exec $(APP_SERVICE) php artisan make:migration $(name)

make-seeder: ## Create a new seeder (usage: make make-seeder name=UserSeeder)
	@cd laravel12 && $(COMPOSE) exec $(APP_SERVICE) php artisan make:seeder $(name)

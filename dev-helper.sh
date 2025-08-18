#!/bin/bash

# Laravel Base Development Helper Script
# Author: Rofiq02bae
# Description: Helper script for common development tasks

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_header() {
    echo -e "${BLUE}"
    echo "======================================"
    echo "  Laravel Base Development Helper"
    echo "======================================"
    echo -e "${NC}"
}

# Check if in laravel12 directory
check_directory() {
    if [ ! -f "docker-compose.yaml" ]; then
        if [ -d "laravel12" ]; then
            cd laravel12
        else
            print_error "Please run this script from the project root or laravel12 directory"
            exit 1
        fi
    fi
}

# Show help
show_help() {
    echo "Usage: $0 <command> [options]"
    echo
    echo "Available commands:"
    echo "  start              Start all services"
    echo "  stop               Stop all services"
    echo "  restart            Restart all services"
    echo "  status             Show service status"
    echo "  logs [service]     Show logs (optional: specific service)"
    echo "  shell [service]    Access service shell (default: app)"
    echo "  artisan <cmd>      Run artisan command"
    echo "  composer <cmd>     Run composer command"
    echo "  migrate            Run database migrations"
    echo "  fresh              Fresh install (migrate:fresh + seed)"
    echo "  test               Run tests"
    echo "  clear              Clear all caches"
    echo "  build              Rebuild containers"
    echo "  cleanup            Clean up containers and images"
    echo "  backup             Backup database"
    echo "  restore <file>     Restore database from backup"
    echo "  health             Check application health"
    echo "  urls               Show service URLs"
    echo
    echo "Examples:"
    echo "  $0 start"
    echo "  $0 logs app"
    echo "  $0 artisan make:controller UserController"
    echo "  $0 composer require laravel/sanctum"
    echo "  $0 shell"
    echo "  $0 backup"
}

# Start services
start_services() {
    print_info "Starting services..."
    docker-compose up -d
    print_success "Services started!"
}

# Stop services
stop_services() {
    print_info "Stopping services..."
    docker-compose down
    print_success "Services stopped!"
}

# Restart services
restart_services() {
    print_info "Restarting services..."
    docker-compose restart
    print_success "Services restarted!"
}

# Show service status
show_status() {
    print_info "Service status:"
    docker-compose ps
}

# Show logs
show_logs() {
    local service=$1
    if [ -n "$service" ]; then
        print_info "Showing logs for $service..."
        docker-compose logs -f "$service"
    else
        print_info "Showing logs for all services..."
        docker-compose logs -f
    fi
}

# Access shell
access_shell() {
    local service=${1:-app}
    print_info "Accessing $service shell..."
    if [ "$service" = "app" ]; then
        docker-compose exec app bash
    else
        docker-compose exec "$service" sh
    fi
}

# Run artisan command
run_artisan() {
    local cmd="$*"
    print_info "Running: php artisan $cmd"
    docker-compose exec app php artisan $cmd
}

# Run composer command
run_composer() {
    local cmd="$*"
    print_info "Running: composer $cmd"
    docker-compose exec app composer $cmd
}

# Run migrations
run_migrate() {
    print_info "Running database migrations..."
    docker-compose exec app php artisan migrate
    print_success "Migrations completed!"
}

# Fresh install
fresh_install() {
    print_info "Running fresh install..."
    docker-compose exec app php artisan migrate:fresh --seed
    print_success "Fresh install completed!"
}

# Run tests
run_tests() {
    print_info "Running tests..."
    docker-compose exec app php artisan test
}

# Clear caches
clear_caches() {
    print_info "Clearing all caches..."
    docker-compose exec app php artisan config:clear
    docker-compose exec app php artisan cache:clear
    docker-compose exec app php artisan route:clear
    docker-compose exec app php artisan view:clear
    print_success "All caches cleared!"
}

# Build containers
build_containers() {
    print_info "Building containers..."
    docker-compose build --no-cache
    print_success "Containers built!"
}

# Cleanup
cleanup() {
    print_warning "This will remove all containers and unused images. Continue? (y/N)"
    read -r confirm
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        print_info "Cleaning up..."
        docker-compose down --volumes --remove-orphans
        docker system prune -f
        print_success "Cleanup completed!"
    else
        print_info "Cleanup cancelled."
    fi
}

# Backup database
backup_database() {
    local backup_file="backup_$(date +%Y%m%d_%H%M%S).sql"
    print_info "Creating database backup: $backup_file"
    
    docker-compose exec database mysqldump -u laravel123 -plaravel123 laravel > "$backup_file"
    
    if [ -f "$backup_file" ]; then
        print_success "Database backup created: $backup_file"
    else
        print_error "Failed to create database backup"
        exit 1
    fi
}

# Restore database
restore_database() {
    local backup_file=$1
    
    if [ -z "$backup_file" ]; then
        print_error "Please specify backup file: $0 restore <backup_file>"
        exit 1
    fi
    
    if [ ! -f "$backup_file" ]; then
        print_error "Backup file not found: $backup_file"
        exit 1
    fi
    
    print_warning "This will replace the current database. Continue? (y/N)"
    read -r confirm
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        print_info "Restoring database from: $backup_file"
        docker-compose exec -T database mysql -u laravel123 -plaravel123 laravel < "$backup_file"
        print_success "Database restored successfully!"
    else
        print_info "Database restore cancelled."
    fi
}

# Check health
check_health() {
    print_info "Checking application health..."
    
    local services=(
        "http://localhost|Application"
        "http://localhost/health|Health Check"
        "http://localhost:8888|phpMyAdmin"
        "http://localhost:8025|Mailhog"
    )
    
    for service in "${services[@]}"; do
        IFS='|' read -r url name <<< "$service"
        if curl -f "$url" > /dev/null 2>&1; then
            print_success "$name is healthy"
        else
            print_error "$name is not responding"
        fi
    done
}

# Show service URLs
show_urls() {
    echo -e "${BLUE}📱 Service URLs:${NC}"
    echo "=================================="
    echo -e "🌐 Laravel App:      ${GREEN}http://localhost${NC}"
    echo -e "💊 Health Check:     ${GREEN}http://localhost/health${NC}"
    echo -e "🗄️  phpMyAdmin:      ${GREEN}http://localhost:8888${NC}"
    echo -e "📧 Mailhog:          ${GREEN}http://localhost:8025${NC}"
    echo
    echo -e "${BLUE}🧪 Test Endpoints:${NC}"
    echo "=================================="
    echo -e "Simple Email:     ${GREEN}http://localhost/test-mail${NC}"
    echo -e "HTML Email:       ${GREEN}http://localhost/test-mail-html${NC}"
    echo -e "Multiple Email:   ${GREEN}http://localhost/test-mail-multiple${NC}"
}

# Main execution
main() {
    check_directory
    
    local command=$1
    shift
    
    case $command in
        start)
            start_services
            ;;
        stop)
            stop_services
            ;;
        restart)
            restart_services
            ;;
        status)
            show_status
            ;;
        logs)
            show_logs "$@"
            ;;
        shell)
            access_shell "$@"
            ;;
        artisan)
            run_artisan "$@"
            ;;
        composer)
            run_composer "$@"
            ;;
        migrate)
            run_migrate
            ;;
        fresh)
            fresh_install
            ;;
        test)
            run_tests
            ;;
        clear)
            clear_caches
            ;;
        build)
            build_containers
            ;;
        cleanup)
            cleanup
            ;;
        backup)
            backup_database
            ;;
        restore)
            restore_database "$@"
            ;;
        health)
            check_health
            ;;
        urls)
            show_urls
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            if [ -z "$command" ]; then
                print_header
                show_help
            else
                print_error "Unknown command: $command"
                echo "Use 'help' for available commands"
                exit 1
            fi
            ;;
    esac
}

# Run main function with all arguments
main "$@"

#!/bin/bash

# Laravel Base Quick Start Script
# Author: Rofiq02bae
# Description: Quick setup script for Laravel 12 with Docker

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
    echo "  Laravel Base Quick Start Setup"
    echo "======================================"
    echo -e "${NC}"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    local missing_tools=()
    
    if ! command_exists docker; then
        missing_tools+=("docker")
    fi
    
    if ! command_exists docker-compose; then
        missing_tools+=("docker-compose")
    fi
    
    if ! command_exists git; then
        missing_tools+=("git")
    fi
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        print_error "Missing required tools: ${missing_tools[*]}"
        echo "Please install the missing tools and try again."
        exit 1
    fi
    
    print_success "All prerequisites are installed!"
}

# Setup environment
setup_environment() {
    print_info "Setting up environment..."
    
    # Navigate to laravel12 directory
    if [ ! -d "laravel12" ]; then
        print_error "laravel12 directory not found!"
        exit 1
    fi
    
    cd laravel12
    
    # Copy .env file if it doesn't exist
    if [ ! -f ".env" ]; then
        if [ -f ".env.example" ]; then
            cp .env.example .env
            print_success "Environment file created from .env.example"
        else
            print_error ".env.example file not found!"
            exit 1
        fi
    else
        print_warning ".env file already exists, skipping..."
    fi
}

# Build and start containers
start_containers() {
    print_info "Building and starting Docker containers..."
    
    # Stop any existing containers
    docker-compose down --remove-orphans 2>/dev/null || true
    
    # Build and start containers
    docker-compose up -d --build
    
    print_success "Docker containers started successfully!"
}

# Wait for services to be ready
wait_for_services() {
    print_info "Waiting for services to be ready..."
    
    # Wait for database
    print_info "Waiting for database..."
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if docker-compose exec -T database mysqladmin ping -h "localhost" --silent; then
            break
        fi
        echo -n "."
        sleep 2
        ((attempt++))
    done
    
    if [ $attempt -gt $max_attempts ]; then
        print_error "Database failed to start within expected time"
        exit 1
    fi
    
    print_success "Database is ready!"
    
    # Wait for web application
    print_info "Waiting for web application..."
    max_attempts=30
    attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if curl -f http://localhost/health > /dev/null 2>&1; then
            break
        fi
        echo -n "."
        sleep 2
        ((attempt++))
    done
    
    if [ $attempt -gt $max_attempts ]; then
        print_warning "Web application might not be fully ready, but continuing..."
    else
        print_success "Web application is ready!"
    fi
}

# Setup Laravel
setup_laravel() {
    print_info "Setting up Laravel application..."
    
    # Install dependencies
    print_info "Installing Composer dependencies..."
    docker-compose exec app composer install --no-dev --optimize-autoloader
    
    # Generate application key
    print_info "Generating application key..."
    docker-compose exec app php artisan key:generate
    
    # Run migrations
    print_info "Running database migrations..."
    docker-compose exec app php artisan migrate --force
    
    # Clear caches
    print_info "Clearing application caches..."
    docker-compose exec app php artisan config:clear
    docker-compose exec app php artisan cache:clear
    docker-compose exec app php artisan route:clear
    docker-compose exec app php artisan view:clear
    
    # Set proper permissions
    print_info "Setting proper permissions..."
    docker-compose exec --user root app chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache
    docker-compose exec --user root app chmod -R 775 /var/www/storage /var/www/bootstrap/cache
    
    print_success "Laravel application setup completed!"
}

# Test installation
test_installation() {
    print_info "Testing installation..."
    
    # Test main application
    if curl -f http://localhost > /dev/null 2>&1; then
        print_success "Main application is working!"
    else
        print_error "Main application is not responding"
    fi
    
    # Test health endpoint
    if curl -f http://localhost/health > /dev/null 2>&1; then
        print_success "Health endpoint is working!"
    else
        print_warning "Health endpoint is not responding"
    fi
    
    # Test phpMyAdmin
    if curl -f http://localhost:8888 > /dev/null 2>&1; then
        print_success "phpMyAdmin is working!"
    else
        print_warning "phpMyAdmin is not responding"
    fi
    
    # Test Mailhog
    if curl -f http://localhost:8025 > /dev/null 2>&1; then
        print_success "Mailhog is working!"
    else
        print_warning "Mailhog is not responding"
    fi
}

# Show service URLs
show_services() {
    echo
    echo -e "${GREEN}🎉 Setup completed successfully!${NC}"
    echo
    echo -e "${BLUE}📱 Available Services:${NC}"
    echo "=================================="
    echo -e "🌐 Laravel App:      ${GREEN}http://localhost${NC}"
    echo -e "💊 Health Check:     ${GREEN}http://localhost/health${NC}"
    echo -e "🗄️  phpMyAdmin:      ${GREEN}http://localhost:8888${NC}"
    echo -e "📧 Mailhog:          ${GREEN}http://localhost:8025${NC}"
    echo
    echo -e "${BLUE}🔧 Database Connection:${NC}"
    echo "=================================="
    echo "Host: localhost"
    echo "Port: 33061"
    echo "Database: laravel"
    echo "Username: laravel123"
    echo "Password: laravel123"
    echo
    echo -e "${BLUE}🧪 Test Email:${NC}"
    echo "=================================="
    echo -e "Simple Email:     ${GREEN}http://localhost/test-mail${NC}"
    echo -e "HTML Email:       ${GREEN}http://localhost/test-mail-html${NC}"
    echo -e "Multiple Email:   ${GREEN}http://localhost/test-mail-multiple${NC}"
    echo
    echo -e "${YELLOW}💡 Useful Commands:${NC}"
    echo "=================================="
    echo "View logs:           docker-compose logs -f"
    echo "Stop services:       docker-compose down"
    echo "Restart services:    docker-compose restart"
    echo "Run artisan:         docker-compose exec app php artisan"
    echo "Access container:    docker-compose exec app bash"
    echo
}

# Cleanup function
cleanup() {
    if [ $? -ne 0 ]; then
        print_error "Setup failed!"
        print_info "Cleaning up..."
        docker-compose down --remove-orphans 2>/dev/null || true
        exit 1
    fi
}

# Main execution
main() {
    # Set trap for cleanup
    trap cleanup EXIT
    
    print_header
    
    # Parse arguments
    local skip_build=false
    local production=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --skip-build)
                skip_build=true
                shift
                ;;
            --production)
                production=true
                shift
                ;;
            --help|-h)
                echo "Usage: $0 [OPTIONS]"
                echo "Options:"
                echo "  --skip-build    Skip Docker build step"
                echo "  --production    Use production configuration"
                echo "  --help, -h      Show this help message"
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
    
    if [ "$production" = true ]; then
        print_warning "Production mode is not yet implemented in this script"
        exit 1
    fi
    
    # Execute setup steps
    check_prerequisites
    setup_environment
    
    if [ "$skip_build" = false ]; then
        start_containers
        wait_for_services
        setup_laravel
    else
        print_info "Skipping build and starting existing containers..."
        docker-compose up -d
        wait_for_services
    fi
    
    test_installation
    show_services
    
    # Remove trap
    trap - EXIT
    
    print_success "🚀 Laravel Base is ready for development!"
}

# Run main function with all arguments
main "$@"

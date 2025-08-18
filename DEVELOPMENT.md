# 🛠️ Development Guide

This guide helps you get started with developing the Laravel Base application.

## 🚀 Quick Setup

### Prerequisites

- Docker & Docker Compose
- Git
- Make (optional, for convenience)

### 1. Clone and Setup

```bash
git clone https://github.com/Rofiq02bae/laravel-base.git
cd laravel-base

# Quick setup with script
./quick-start.sh

# Or manually
cd laravel12
docker compose up -d
```

### 2. Access Services

| Service | URL | Purpose |
|---------|-----|---------|
| Laravel App | http://localhost | Main application |
| phpMyAdmin | http://localhost:8888 | Database management |
| Mailhog | http://localhost:8025 | Email testing |

## 🔧 Development Commands

### Using Helper Scripts

```bash
# Show all available commands
./dev-helper.sh help

# Common development tasks
./dev-helper.sh start          # Start all services
./dev-helper.sh stop           # Stop all services
./dev-helper.sh restart        # Restart all services
./dev-helper.sh logs           # Show logs
./dev-helper.sh health         # Check health status
./dev-helper.sh urls           # Show service URLs
```

### Using Makefile

```bash
# Show all available commands
make help

# Development workflow
make start                     # Start development environment
make stop                      # Stop all services
make restart                   # Restart services
make logs                      # Show container logs
make health                    # Health check all services
make shell                     # Access Laravel container shell
```

### Laravel Commands

```bash
# Run Artisan commands
./dev-helper.sh artisan migrate
./dev-helper.sh artisan make:controller ExampleController

# Or with Make
make artisan cmd="migrate"
make artisan cmd="make:controller ExampleController"

# Direct access to container
docker compose exec app php artisan migrate
```

### Composer Commands

```bash
# Install packages
./dev-helper.sh composer require package-name

# Or with Make
make composer cmd="require package-name"

# Direct access
docker compose exec app composer install
```

## 📧 Testing Email

The application includes email testing endpoints:

```bash
# Send test emails
curl http://localhost/test-mail
curl http://localhost/test-mail-html
curl http://localhost/test-mail-multiple

# Or use Make
make test-email

# View emails in Mailhog
open http://localhost:8025
```

## 🗄️ Database

### Access Database

- **phpMyAdmin**: http://localhost:8888
  - Server: `database`
  - Username: `laravel123`
  - Password: `laravel123`
  - Database: `laravel`

### Run Migrations

```bash
./dev-helper.sh artisan migrate
# or
make artisan cmd="migrate"
```

### Database Seeding

```bash
./dev-helper.sh artisan db:seed
# or
make artisan cmd="db:seed"
```

## 🔍 Health Monitoring

### Health Check Endpoints

| Endpoint | Purpose |
|----------|---------|
| `/health` | Application health status |
| `/api/health` | API health check |

### Check Service Health

```bash
# Check all services
./dev-helper.sh health

# Or use Make
make health

# Individual service status
docker compose ps
```

## 🛠️ Troubleshooting

### Common Issues

1. **Permission Issues**
   ```bash
   # Fix Laravel storage permissions
   ./dev-helper.sh fix-permissions
   # or
   make fix-permissions
   ```

2. **Container Won't Start**
   ```bash
   # Check logs
   ./dev-helper.sh logs
   # or
   make logs
   
   # Rebuild containers
   docker compose down
   docker compose up -d --build
   ```

3. **Database Connection Issues**
   ```bash
   # Check database status
   docker compose ps database
   
   # Check Laravel .env file
   cat laravel12/.env | grep DB_
   ```

4. **Clear Application Cache**
   ```bash
   ./dev-helper.sh artisan cache:clear
   ./dev-helper.sh artisan config:clear
   ./dev-helper.sh artisan view:clear
   ```

### Reset Environment

```bash
# Complete reset
docker compose down -v
docker compose up -d --build

# Run quick setup again
./quick-start.sh
```

## 📂 Project Structure

```
laravel-base/
├── laravel12/                 # Laravel application
│   ├── app/                  # Application code
│   ├── config/               # Configuration
│   ├── database/             # Migrations & seeders
│   ├── resources/            # Views & assets
│   ├── routes/               # Route definitions
│   ├── storage/              # Storage & logs
│   ├── tests/                # Test files
│   ├── app.dockerfile        # Development Dockerfile
│   ├── Dockerfile.prod       # Production Dockerfile
│   ├── docker-compose.yml    # Development services
│   └── nginx.dockerfile      # Nginx configuration
├── .github/workflows/        # CI/CD workflows
├── quick-start.sh            # Quick setup script
├── dev-helper.sh             # Development helper script
├── Makefile                  # Make commands
└── README.md                 # Project documentation
```

## 🧪 Testing

### Run Tests

```bash
# Run all tests
./dev-helper.sh test

# Or use Make
make test

# Run specific test
./dev-helper.sh artisan test --filter=ExampleTest

# With coverage
make test-coverage
```

### Test Database

The tests use a separate database configuration. Check `laravel12/phpunit.xml` for test database settings.

## 🚀 Deployment

### Build Production Image

```bash
# Build production Docker image
docker build -f laravel12/Dockerfile.prod -t laravel-base:prod laravel12/

# Or use the CI/CD pipeline
git push origin main
```

### CI/CD Pipeline

The project includes a complete CI/CD pipeline that:

1. **Tests** - Runs PHPUnit tests with coverage
2. **Security** - Scans for vulnerabilities
3. **Build** - Creates Docker image
4. **Deploy** - Pushes to Docker Hub

## 💡 Tips

1. **Use the helper scripts** - They handle common tasks automatically
2. **Check health regularly** - Use `make health` to ensure all services are running
3. **Monitor logs** - Use `make logs` to debug issues
4. **Test emails** - Use Mailhog to verify email functionality
5. **Keep dependencies updated** - Regularly run `composer update`

## 📚 Additional Resources

- [Laravel Documentation](https://laravel.com/docs)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [PHPUnit Documentation](https://phpunit.de/documentation.html)

---

Happy coding! 🎉

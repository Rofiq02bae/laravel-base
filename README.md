# 🚀 Laravel Base - Development Ready

[![CI/CD Pipeline](https://github.com/Rofiq02bae/laravel-base/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/Rofiq02bae/laravel-base/actions/workflows/ci-cd.yml)
[![Docker Image](https://img.shields.io/badge/docker-rofiq02bae%2Flaravel--base--app-blue)](https://hub.docker.com/r/rofiq02bae/laravel-base-app)
[![Laravel](https://img.shields.io/badge/Laravel-12.x-red.svg)](https://laravel.com)
[![PHP](https://img.shields.io/badge/PHP-8.3-purple.svg)](https://php.net)

A development-ready Laravel 12 application with Docker containerization, CI/CD pipeline, and comprehensive development tools.

## ✨ Features

- 🐘 **Laravel 12** - Latest version with all modern features
- 🐳 **Docker** - Complete containerization for development
- 🔄 **CI/CD** - Automated testing, building, and deployment
- 📧 **Email Testing** - Mailhog integration for development
- 🗄️ **Database** - MySQL 8.0 with phpMyAdmin
- 🔒 **Security** - Automated vulnerability scanning
- 📊 **Monitoring** - Health checks and status endpoints
- 🛠️ **Dev Tools** - Quick start scripts, Makefile, and helper commands
- 🚀 **Docker Hub** - Automated image building and deployment

## 🏗️ Architecture

```
├── laravel12/              # Laravel application
│   ├── app/               # Application code
│   ├── config/            # Configuration files
│   ├── database/          # Migrations & seeders
│   ├── resources/         # Views & assets
│   ├── routes/            # Application routes
│   ├── app.dockerfile     # Development Dockerfile
│   └── Dockerfile.prod    # Production Dockerfile
├── .github/
│   └── workflows/         # GitHub Actions workflows
│       ├── ci-cd.yml      # Main CI/CD pipeline
│       ├── manual-deploy.yml # Manual deployment
│       └── monitoring.yml # Health monitoring
├── docker-compose.yml     # Development environment
├── docker-compose.prod.yml # Production environment
└── CICD-SETUP.md         # Detailed setup guide
```

## 🚀 Quick Start

### Using Quick Start Script (Recommended)

```bash
# Clone the repository
git clone https://github.com/Rofiq02bae/laravel-base.git
cd laravel-base

# Run the quick start script
chmod +x quick-start.sh
./quick-start.sh

# Or use Make
make setup
```

### Manual Development Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Rofiq02bae/laravel-base.git
   cd laravel-base
   ```

2. **Start development environment:**
   ```bash
   cd laravel12
   docker compose up -d
   ```

3. **Access the application:**
   - **Laravel App**: http://localhost
   - **phpMyAdmin**: http://localhost:8888
   - **Mailhog**: http://localhost:8025

### Available Scripts

| Script | Description |
|--------|-------------|
| `./quick-start.sh` | Complete setup and start |
| `./dev-helper.sh help` | Show all development commands |
| `make help` | Show all available make commands |
| `make start` | Start all services |
| `make stop` | Stop all services |
| `make health` | Check services health |
| `make test-email` | Send test email |
| `make artisan` | Run Laravel Artisan commands |
| `make composer` | Run Composer commands |

2. **Start development environment:**
   ```bash
   docker compose up -d
   ```

3. **Access the application:**
   - **Laravel App**: http://localhost
   - **phpMyAdmin**: http://localhost:8888
   - **Mailhog**: http://localhost:8025

### Production Deployment

1. **Pull the Docker image:**
   ```bash
   docker pull rofiq02bae/laravel-base-app:latest
   ```

2. **Run with Docker Compose:**
   ```bash
   curl -O https://raw.githubusercontent.com/Rofiq02bae/laravel-base/main/docker-compose.prod.yml
   docker-compose -f docker-compose.prod.yml up -d
   ```

## 🔧 CI/CD Pipeline

### Pipeline Overview

| Stage | Description | Triggers |
|-------|-------------|----------|
| **🧪 Test** | PHPUnit tests, code coverage | All pushes & PRs |
| **🔒 Security** | Vulnerability scanning | All pushes & PRs |
| **🐳 Build** | Docker image build & push | Push to main |
| **🚀 Deploy** | Automatic deployment | Push to main/release |

### Automated Processes

- ✅ **Code Quality**: PHPUnit tests with coverage
- ✅ **Security**: Composer audit and dependency scanning  
- ✅ **Multi-platform**: Builds for amd64 and arm64
- ✅ **Auto-tagging**: Semantic versioning and latest tags
- ✅ **Health Monitoring**: Automated health checks every 15 minutes

### Manual Actions

- 🔧 **Manual Deploy**: Deploy specific versions to any environment
- 🔍 **Health Check**: On-demand health and performance checks
- 📊 **Security Scan**: Manual security vulnerability scanning

## 📧 Email Testing

The application includes comprehensive email testing with Mailhog:

### Test Endpoints

| Endpoint | Description |
|----------|-------------|
| `/test-mail` | Simple text email |
| `/test-mail-html` | HTML formatted email |
| `/test-mail-multiple` | Multiple recipients with CC/BCC |

### Usage Example

```bash
# Send test email
curl http://localhost/test-mail

# View emails in Mailhog
open http://localhost:8025
```

## 🔍 Monitoring & Health Checks

### Health Endpoints

| Endpoint | Purpose |
|----------|---------|
| `/health` | Application health status |
| `/api/health` | API health check |

### Example Health Response

```json
{
  "status": "healthy",
  "timestamp": "2025-08-18T08:07:35.000000Z",
  "services": {
    "database": "healthy",
    "storage": "healthy",
    "cache": "healthy"
  },
  "version": "1.0.0",
  "environment": "production"
}
```

## 🐳 Docker Images

### Available Tags

| Tag | Description | Usage |
|-----|-------------|-------|
| `latest` | Latest main branch | Production ready |
| `main-{sha}` | Specific commit | Rollback/testing |
| `v{version}` | Release versions | Stable releases |

### Image Details

- **Base**: PHP 8.3 FPM Alpine
- **Size**: ~150MB (optimized)
- **Platforms**: linux/amd64, linux/arm64
- **Features**: OPcache, optimized PHP-FPM, security hardened

## 🛠️ Development

### Local Setup

```bash
# Install dependencies
cd laravel12
composer install

# Setup environment
cp .env.example .env
php artisan key:generate

# Run migrations
php artisan migrate

# Start development server
php artisan serve
```

### Testing

```bash
# Run tests
./vendor/bin/phpunit

# Run with coverage
./vendor/bin/phpunit --coverage-html coverage

# Run specific test
./vendor/bin/phpunit --filter=ExampleTest
```

### Building Docker Image

```bash
# Development build
docker build -f app.dockerfile -t laravel-base:dev .

# Production build
docker build -f Dockerfile.prod -t laravel-base:prod .
```

## ⚙️ Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `APP_ENV` | Application environment | `local` |
| `APP_DEBUG` | Debug mode | `true` |
| `DB_CONNECTION` | Database connection | `mysql` |
| `MAIL_MAILER` | Mail driver | `smtp` |

### GitHub Secrets Required

| Secret | Description |
|--------|-------------|
| `DOCKER_USERNAME` | Docker Hub username |
| `DOCKER_PASSWORD` | Docker Hub password/token |

## 📈 Performance

### Optimizations Included

- ✅ **OPcache**: PHP bytecode caching
- ✅ **Composer**: Production optimized autoloader
- ✅ **Multi-stage builds**: Reduced image size
- ✅ **PHP-FPM tuning**: Better resource utilization
- ✅ **Layer caching**: Faster CI/CD builds

### Benchmarks

- **Cold start**: ~200ms
- **Warm response**: ~50ms
- **Memory usage**: ~32MB baseline
- **Image size**: ~150MB

## 🤝 Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Run tests: `./vendor/bin/phpunit`
4. Commit changes: `git commit -m 'Add amazing feature'`
5. Push to branch: `git push origin feature/amazing-feature`
6. Open Pull Request

## 📚 Documentation

- [CI/CD Setup Guide](CICD-SETUP.md) - Detailed setup instructions
- [Laravel Documentation](https://laravel.com/docs) - Framework documentation
- [Docker Hub](https://hub.docker.com/r/rofiq02bae/laravel-base-app) - Image repository

## 📞 Support

- 🐛 **Issues**: [GitHub Issues](https://github.com/Rofiq02bae/laravel-base/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/Rofiq02bae/laravel-base/discussions)
- 📧 **Email**: [Contact](mailto:your-email@example.com)

## 📄 License

This project is open-sourced software licensed under the [MIT license](LICENSE).

---

⭐ **Star this repository if it helped you!**

🚀 **Ready to deploy? Check out our [CI/CD Setup Guide](CICD-SETUP.md)!**
base configuration for laravel by rofiq02bae

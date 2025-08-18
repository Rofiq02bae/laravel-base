# Deployment Guide

This guide covers deployment strategies for the Laravel Base application.

## Table of Contents

- [Docker Hub Deployment](#docker-hub-deployment)
- [Production Setup](#production-setup)
- [Environment Configuration](#environment-configuration)
- [CI/CD Pipeline](#cicd-pipeline)
- [Monitoring](#monitoring)
- [Troubleshooting](#troubleshooting)

## Docker Hub Deployment

### Prerequisites

1. Docker Hub account
2. GitHub repository with secrets configured
3. Docker installed locally

### Automated Deployment via GitHub Actions

The repository includes automated CI/CD pipeline that:

1. **Triggers on:**
   - Push to `main` branch
   - Pull requests to `main` branch
   - Manual dispatch

2. **Pipeline Steps:**
   - Run tests
   - Build Docker image
   - Push to Docker Hub
   - Deploy to staging (if configured)

### Manual Docker Hub Push

```bash
# Build the image
docker build -t rofiq02bae/laravel-base-app:latest laravel12/

# Tag with version
docker tag rofiq02bae/laravel-base-app:latest rofiq02bae/laravel-base-app:v1.0.0

# Push to Docker Hub
docker push rofiq02bae/laravel-base-app:latest
docker push rofiq02bae/laravel-base-app:v1.0.0
```

### Pull and Run from Docker Hub

```bash
# Pull the latest image
docker pull rofiq02bae/laravel-base-app:latest

# Run with docker-compose (recommended)
cd production/
docker-compose up -d

# Or run directly
docker run -d \
  --name laravel-app \
  -p 80:80 \
  -e APP_ENV=production \
  -e DB_HOST=your-db-host \
  -e DB_DATABASE=your-database \
  -e DB_USERNAME=your-username \
  -e DB_PASSWORD=your-password \
  rofiq02bae/laravel-base-app:latest
```

## Production Setup

### Using Production Docker Compose

1. **Copy production files:**
   ```bash
   cp -r production/ /path/to/production/
   cd /path/to/production/
   ```

2. **Configure environment:**
   ```bash
   cp .env.production .env
   # Edit .env with your production settings
   ```

3. **Start services:**
   ```bash
   docker-compose -f docker-compose.prod.yml up -d
   ```

### Server Requirements

- **Minimum:** 1 CPU, 1GB RAM, 10GB storage
- **Recommended:** 2 CPU, 2GB RAM, 20GB storage
- **OS:** Ubuntu 20.04+ or CentOS 8+
- **Docker:** 20.10+
- **Docker Compose:** 2.0+

## Environment Configuration

### Required Environment Variables

```bash
# Application
APP_NAME="Laravel Base"
APP_ENV=production
APP_KEY=base64:your-32-character-key
APP_DEBUG=false
APP_URL=https://yourdomain.com

# Database
DB_CONNECTION=mysql
DB_HOST=database
DB_PORT=3306
DB_DATABASE=laravel_prod
DB_USERNAME=laravel_user
DB_PASSWORD=secure_password

# Mail
MAIL_MAILER=smtp
MAIL_HOST=your-smtp-host
MAIL_PORT=587
MAIL_USERNAME=your-email
MAIL_PASSWORD=your-password
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=noreply@yourdomain.com
MAIL_FROM_NAME="${APP_NAME}"

# Cache & Sessions
CACHE_DRIVER=redis
SESSION_DRIVER=redis
QUEUE_CONNECTION=redis

# Redis
REDIS_HOST=redis
REDIS_PASSWORD=secure_redis_password
REDIS_PORT=6379

# Security
SESSION_SECURE_COOKIE=true
SANCTUM_STATEFUL_DOMAINS=yourdomain.com
```

### SSL/TLS Configuration

For production, configure SSL certificates:

```nginx
# nginx/ssl.conf
server {
    listen 443 ssl http2;
    server_name yourdomain.com;
    
    ssl_certificate /etc/ssl/certs/yourdomain.crt;
    ssl_certificate_key /etc/ssl/private/yourdomain.key;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512;
    
    # ... rest of nginx config
}
```

## CI/CD Pipeline

### GitHub Secrets Required

Configure these secrets in your GitHub repository:

```
DOCKER_HUB_USERNAME=rofiq02bae
DOCKER_HUB_ACCESS_TOKEN=your_access_token
PRODUCTION_HOST=your.server.ip
PRODUCTION_USER=deploy_user
PRODUCTION_SSH_KEY=your_private_ssh_key
```

### Deployment Flow

1. **Development:**
   ```
   feature branch → PR → code review → merge to main
   ```

2. **Staging:**
   ```
   main branch → GitHub Actions → build → test → deploy to staging
   ```

3. **Production:**
   ```
   manual trigger → GitHub Actions → build → test → deploy to production
   ```

### Manual Deployment

If automatic deployment fails, deploy manually:

```bash
# On production server
cd /path/to/app
git pull origin main
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml pull
docker-compose -f docker-compose.prod.yml up -d
docker-compose -f docker-compose.prod.yml exec app php artisan migrate --force
docker-compose -f docker-compose.prod.yml exec app php artisan config:cache
```

## Monitoring

### Health Checks

Set up monitoring for these endpoints:

- `GET /health` - Application health
- `GET /health/database` - Database connectivity
- `GET /health/cache` - Cache connectivity

### Log Monitoring

Monitor these log files:

```bash
# Application logs
docker-compose logs -f app

# Database logs
docker-compose logs -f database

# Web server logs
docker-compose logs -f web
```

### Metrics to Monitor

- **Application:**
  - Response time
  - Error rate
  - Memory usage
  - CPU usage

- **Database:**
  - Connection count
  - Query performance
  - Storage usage

- **Infrastructure:**
  - Disk space
  - Network traffic
  - Container health

## Backup Strategy

### Database Backup

```bash
# Automated daily backup
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups/database"
mkdir -p $BACKUP_DIR

docker-compose exec database mysqldump \
  -u $DB_USERNAME \
  -p$DB_PASSWORD \
  $DB_DATABASE > $BACKUP_DIR/backup_$DATE.sql

# Keep only last 7 days
find $BACKUP_DIR -name "backup_*.sql" -mtime +7 -delete
```

### Application Files Backup

```bash
# Backup storage and uploads
tar -czf /backups/storage_$(date +%Y%m%d).tar.gz storage/
```

## Troubleshooting

### Common Issues

1. **Container won't start:**
   ```bash
   # Check logs
   docker-compose logs app
   
   # Check resources
   docker system df
   df -h
   ```

2. **Database connection issues:**
   ```bash
   # Test database connection
   docker-compose exec app php artisan tinker
   # In tinker: DB::connection()->getPdo()
   ```

3. **Permission issues:**
   ```bash
   # Fix permissions
   docker-compose exec --user root app chown -R www-data:www-data /var/www/storage
   docker-compose exec --user root app chmod -R 775 /var/www/storage
   ```

4. **High memory usage:**
   ```bash
   # Clear caches
   docker-compose exec app php artisan cache:clear
   docker-compose exec app php artisan config:clear
   docker-compose exec app php artisan route:clear
   ```

### Emergency Recovery

If the application is completely down:

```bash
# Quick recovery
cd /path/to/app
docker-compose down
docker system prune -f
docker-compose pull
docker-compose up -d

# If database is corrupted
docker-compose exec database mysql -u root -p$MYSQL_ROOT_PASSWORD
# In mysql: DROP DATABASE laravel; CREATE DATABASE laravel;
docker-compose exec app php artisan migrate --force
```

### Support

For additional support:

1. Check the [GitHub Issues](https://github.com/Rofiq02bae/laravel-base/issues)
2. Review application logs
3. Contact the development team
4. Check Laravel documentation

---

## Security Considerations

### Production Security Checklist

- [ ] All environment variables properly set
- [ ] SSL/TLS certificates configured
- [ ] Database passwords are strong
- [ ] Redis password is set
- [ ] Application key is generated
- [ ] Debug mode is disabled
- [ ] File permissions are correct
- [ ] Firewall rules are configured
- [ ] Regular security updates applied
- [ ] Backup and recovery tested

### Regular Maintenance

- Weekly security updates
- Monthly dependency updates
- Quarterly disaster recovery tests
- Annual security audits

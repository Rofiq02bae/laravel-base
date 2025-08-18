# 🚀 Laravel Base - CI/CD Setup

This repository contains a Laravel 12 application with complete CI/CD pipeline using GitHub Actions and Docker.

## 📋 Prerequisites

Before setting up the CI/CD pipeline, make sure you have:

1. **Docker Hub Account** - [Create account](https://hub.docker.com/)
2. **GitHub Repository** - This repository
3. **GitHub Secrets configured** (see setup below)

## 🔧 GitHub Secrets Setup

You need to configure the following secrets in your GitHub repository:

### 📍 Navigate to Repository Settings
1. Go to your repository on GitHub
2. Click **Settings** tab
3. Click **Secrets and variables** → **Actions**
4. Click **New repository secret**

### 🔑 Required Secrets

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `DOCKER_USERNAME` | Your Docker Hub username | `rofiq02bae` |
| `DOCKER_PASSWORD` | Your Docker Hub password or access token | `your_password_or_token` |

### 🛡️ Recommended: Use Docker Hub Access Token

Instead of your password, create a Docker Hub access token:

1. Log in to [Docker Hub](https://hub.docker.com/)
2. Go to **Account Settings** → **Security**
3. Click **New Access Token**
4. Name: `github-actions-laravel-base`
5. Permissions: **Read, Write, Delete**
6. Copy the generated token
7. Use this token as `DOCKER_PASSWORD` secret

## 🔄 CI/CD Pipeline Overview

The pipeline consists of several jobs that run automatically:

### 🧪 Test Job
- ✅ Runs PHPUnit tests
- ✅ Code coverage analysis
- ✅ Database migrations testing
- ✅ Laravel application health checks

### 🔒 Security Scan Job
- ✅ Composer security audit
- ✅ Dependency vulnerability scanning
- ✅ Code quality checks

### 🐳 Build & Push Job
- ✅ Builds optimized Docker image
- ✅ Multi-platform builds (amd64, arm64)
- ✅ Pushes to Docker Hub
- ✅ Automatic tagging strategy

### 🚀 Deploy Jobs
- ✅ Staging deployment (auto on main branch)
- ✅ Production deployment (manual on release)

## 📊 Pipeline Triggers

| Event | Jobs Triggered |
|-------|----------------|
| **Push to `main`** | Test → Security → Build → Deploy Staging |
| **Push to `develop`** | Test → Security |
| **Pull Request** | Test → Security |
| **Release Published** | Test → Security → Build → Deploy Production |

## 🏷️ Docker Image Tagging Strategy

| Trigger | Tag |
|---------|-----|
| Push to main | `latest` |
| Push to branch | `branch-name` |
| Commit SHA | `main-abc1234` |
| Release | `v1.0.0` |

## 🚀 Production Deployment

### Using Docker Compose Production

1. **Download production compose file:**
   ```bash
   curl -O https://raw.githubusercontent.com/Rofiq02bae/laravel-base/main/docker-compose.prod.yml
   ```

2. **Create environment file:**
   ```bash
   cp .env.example .env.production
   # Edit .env.production with your production values
   ```

3. **Deploy:**
   ```bash
   docker-compose -f docker-compose.prod.yml --env-file .env.production up -d
   ```

### Using Docker CLI

```bash
# Pull latest image
docker pull rofiq02bae/laravel-base-app:latest

# Run container
docker run -d \
  --name laravel-app \
  -p 8000:9000 \
  -e APP_ENV=production \
  -e APP_DEBUG=false \
  rofiq02bae/laravel-base-app:latest
```

## 🔍 Monitoring & Logs

### View Pipeline Status
- ✅ GitHub Actions tab in repository
- ✅ Status badges in README
- ✅ Email notifications on failure

### Application Logs
```bash
# View application logs
docker logs laravel-app

# Follow logs in real-time
docker logs -f laravel-app
```

### Health Check
```bash
# Check if application is running
curl http://your-domain.com/health

# Check specific endpoints
curl http://your-domain.com/test-mail
```

## 🛠️ Local Development

### Run Development Environment
```bash
cd laravel12
docker-compose up -d
```

### Run Tests Locally
```bash
cd laravel12
./vendor/bin/phpunit
```

### Build Image Locally
```bash
cd laravel12
docker build -f Dockerfile.prod -t laravel-base-app:local .
```

## 📈 Performance Optimizations

The production Docker image includes:

- ✅ **OPcache** - PHP bytecode caching
- ✅ **Optimized Composer** - Production dependencies only
- ✅ **Multi-stage builds** - Smaller image size
- ✅ **PHP-FPM tuning** - Better performance
- ✅ **Layer caching** - Faster builds

## 🔧 Customization

### Modify Pipeline
Edit `.github/workflows/ci-cd.yml` to:
- Add more test suites
- Change deployment targets
- Add notification channels
- Modify build options

### Environment-specific Configs
- **Development**: `docker-compose.yml`
- **Production**: `docker-compose.prod.yml`
- **Testing**: GitHub Actions matrix

## 📚 Additional Resources

- [Laravel Deployment Documentation](https://laravel.com/docs/deployment)
- [Docker Best Practices](https://docs.docker.com/develop/best-practices/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

## 🤝 Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open Pull Request

## 📞 Support

If you encounter any issues:

1. Check [GitHub Actions logs](../../actions)
2. Review [Docker Hub repository](https://hub.docker.com/r/rofiq02bae/laravel-base-app)
3. Open an [issue](../../issues)

---

🚀 **Happy deploying!** The CI/CD pipeline will automatically build and deploy your Laravel application whenever you push changes to the main branch.

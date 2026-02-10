# Monorepo Organization Guide

This document explains how this monorepo is organized and best practices for working with it.

## 📁 Repository Structure

### **`/apps/`** - Applications

Contains all deployable applications:

- **`mobile/`** - Flutter mobile app (iOS & Android)
  - Based on [flutter_riverpod_clean_architecture](https://github.com/ssoad/flutter_riverpod_clean_architecture)
  - Clean Architecture with Riverpod state management
  - Feature-based organization

- **`backend/`** - FastAPI backend server
  - Based on [FastAPI-boilerplate](https://github.com/benavlabs/FastAPI-boilerplate)
  - Async SQLAlchemy 2.0 + Pydantic V2
  - JWT auth, rate limiting, caching, background jobs

### **`/docs/`** - Documentation

All technical documentation:
- Requirements, UML diagrams, sequence diagrams
- Database schema, architecture, tech stack guide
- Figma design reference

### **`/scripts/`** - Automation Scripts

Helper scripts for development and deployment:
- Setup scripts
- Test runners
- Database migrations
- Deployment automation

### **`/.github/`** - CI/CD

GitHub Actions workflows for automated testing and deployment.

---

## 🛠️ Development Workflow

### Working on Mobile

```bash
cd apps/mobile

# Install dependencies
flutter pub get

# Run on iOS simulator
flutter run -d "iPhone 15 Pro"

# Run on Android emulator
flutter run -d emulator-5554

# Run tests
flutter test

# Generate code (Freezed, Riverpod)
dart run build_runner build --delete-conflicting-outputs
```

### Working on Backend

```bash
cd apps/backend

# Activate virtual environment
source venv/bin/activate  # Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run development server (auto-reload)
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Run tests
pytest

# Create migration
alembic revision --autogenerate -m "description"

# Apply migrations
alembic upgrade head
```

### Working on Both (Full Stack)

```bash
# Terminal 1 - Backend
cd apps/backend
uvicorn app.main:app --reload

# Terminal 2 - Mobile
cd apps/mobile
flutter run

# Or use Docker Compose for everything
docker-compose up
```

---

## 🔄 Git Workflow

### Branch Naming

```
feature/mobile-login-screen
feature/backend-recipe-api
bugfix/mobile-image-upload
bugfix/backend-auth-token
docs/update-architecture
```

### Commit Messages

Use conventional commits:

```
feat(mobile): add recipe creation screen
feat(backend): implement meal plan API
fix(mobile): resolve image upload issue
fix(backend): fix JWT token expiration
docs: update setup instructions
chore(mobile): update dependencies
chore(backend): configure Redis
```

### Pull Requests

**Monorepo PR Structure:**

- **Title**: Clear indication of which app(s) are affected
  - `[Mobile] Add recipe search feature`
  - `[Backend] Implement shopping list API`
  - `[Mobile + Backend] Add meal planning feature`

- **Description**: What changed and why
- **Testing**: How to test the changes
- **Screenshots**: For UI changes (mobile)

---

## 🐳 Docker Setup

### Development (docker-compose.yml)

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f backend

# Stop all services
docker-compose down

# Rebuild after changes
docker-compose up -d --build
```

### Services

- **backend**: FastAPI server (port 8000)
- **db**: PostgreSQL database (port 5432)
- **redis**: Redis cache (port 6379)
- **mobile**: Flutter (runs locally, not in Docker)

---

## 📦 Dependency Management

### Mobile (Flutter)

**`apps/mobile/pubspec.yaml`**

```yaml
dependencies:
  dio: ^5.4.0
  riverpod: ^2.4.0
  # ... other packages
```

Update:
```bash
cd apps/mobile
flutter pub upgrade
```

### Backend (Python)

**`apps/backend/requirements.txt`**

```
fastapi==0.109.0
sqlalchemy==2.0.25
# ... other packages
```

Update:
```bash
cd apps/backend
pip install -r requirements.txt --upgrade
pip freeze > requirements.txt
```

---

## 🧪 Testing Strategy

### Mobile Tests

```bash
cd apps/mobile

# Unit tests
flutter test

# Widget tests
flutter test test/widgets

# Integration tests
flutter test integration_test

# Test coverage
flutter test --coverage
```

### Backend Tests

```bash
cd apps/backend

# All tests
pytest

# Specific test file
pytest tests/test_recipes.py

# With coverage
pytest --cov=app tests/
```

### E2E Tests (Future)

```bash
# Run backend
cd apps/backend && uvicorn app.main:app

# Run mobile integration tests
cd apps/mobile && flutter test integration_test
```

---

## 🚀 Deployment

### Mobile

**iOS:**
```bash
cd apps/mobile
flutter build ios --release
# Upload to App Store Connect
```

**Android:**
```bash
cd apps/mobile
flutter build appbundle --release
# Upload to Google Play Console
```

### Backend

**Using Docker:**
```bash
# Build production image
docker build -f apps/backend/Dockerfile -t recipe-api:latest .

# Deploy to Railway/Render
# (Use their CLI or GitHub integration)
```

**Manual:**
```bash
cd apps/backend
gunicorn app.main:app -w 4 -k uvicorn.workers.UvicornWorker
```

---

## 📊 Monitoring & Debugging

### Backend Logs

```bash
# Docker logs
docker-compose logs -f backend

# Application logs
tail -f apps/backend/logs/app.log
```

### Mobile Logs

```bash
# Flutter logs
flutter logs

# iOS logs
xcrun simctl spawn booted log stream --predicate 'process == "Runner"'

# Android logs
adb logcat
```

### Database Access

```bash
# Via Docker
docker-compose exec db psql -U postgres -d recipe_db

# Direct connection
psql postgresql://user:pass@localhost:5432/recipe_db
```

---

## 🔐 Environment Variables

### Backend `.env`

Located at: `apps/backend/.env`

```env
# Database
DATABASE_URL=postgresql://user:pass@localhost:5432/recipe_db

# JWT
SECRET_KEY=your-secret-key-here
ALGORITHM=HS256

# Cloudinary
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
```

### Mobile Configuration

Located at: `apps/mobile/lib/core/config/app_config.dart`

```dart
class AppConfig {
  static const String apiBaseUrl = 'http://localhost:8000';
  static const String environment = 'development';
}
```

**For different environments:**
- Development: `http://localhost:8000` or `http://10.0.2.2:8000` (Android emulator)
- Staging: `https://staging-api.yourapp.com`
- Production: `https://api.yourapp.com`

---

## 🎯 Best Practices

### 1. **Independent Development**

Each app should be independently runnable:
- Mobile should work with mocked API responses during development
- Backend should have comprehensive API tests that don't require mobile

### 2. **Shared Models (Optional)**

If needed, create a shared package for data models:

```
packages/
└── shared_models/
    ├── recipe.dart           # Dart model
    └── recipe.py             # Python model
```

**However**, it's usually better to keep models separate and use API contracts (OpenAPI) as the source of truth.

### 3. **API Contract First**

Use OpenAPI spec as contract:
1. Define API in `backend/app/api/openapi.yaml`
2. Generate Dart models from OpenAPI spec
3. Backend implements the spec

### 4. **Versioned APIs**

Backend uses versioned endpoints:
- `/api/v1/recipes`
- `/api/v2/recipes` (when needed)

Mobile can support multiple versions during transition.

### 5. **Feature Flags**

Use feature flags for gradual rollouts:

**Backend:**
```python
FEATURE_VIDEO_IMPORT = os.getenv("FEATURE_VIDEO_IMPORT", "false") == "true"
```

**Mobile:**
```dart
class FeatureFlags {
  static const bool videoImport = bool.fromEnvironment('VIDEO_IMPORT');
}
```

---

## 📚 Additional Resources

### Flutter + Riverpod
- [Flutter Riverpod Clean Architecture Guide](https://github.com/ssoad/flutter_riverpod_clean_architecture)
- [Riverpod Documentation](https://riverpod.dev)

### FastAPI
- [FastAPI Boilerplate Guide](https://benavlabs.github.io/FastAPI-boilerplate/)
- [FastAPI Documentation](https://fastapi.tiangolo.com)

### Monorepo Tools
- [Turborepo](https://turbo.build/) (if you scale to multiple web apps)
- [Nx](https://nx.dev/) (advanced monorepo tooling)
- [Melos](https://melos.invertase.dev/) (Dart/Flutter specific)

---

## 🤔 FAQ

### Q: Should I use a monorepo tool like Turborepo?

**A:** Not necessary for Flutter + Backend. The apps are different languages, so built-in tools (Flutter CLI, pip) work fine. Consider monorepo tools if you add multiple web frontends.

### Q: How do I keep the mobile and backend APIs in sync?

**A:** Use OpenAPI/Swagger spec from FastAPI (`/docs`) as source of truth. Consider generating Dart models from it using tools like [openapi-generator](https://openapi-generator.tech/).

### Q: Can I deploy mobile and backend from the same CI/CD?

**A:** Yes! Use GitHub Actions with separate jobs:
- `mobile-ci.yml` → Build/test mobile
- `backend-ci.yml` → Build/test/deploy backend

### Q: How do I share code between mobile and backend?

**A:** Generally, don't. Keep them independent with API as contract. If you must, create a shared package, but be aware of the maintenance overhead.

### Q: Should I use a shared database for tests?

**A:** No. Mobile uses local SQLite for tests. Backend uses a test PostgreSQL instance. Keep them independent.

---

## 📞 Getting Help

1. Check the `/docs` folder for technical documentation
2. Review boilerplate documentation:
   - [Flutter boilerplate docs](https://github.com/ssoad/flutter_riverpod_clean_architecture)
   - [FastAPI boilerplate docs](https://benavlabs.github.io/FastAPI-boilerplate/)
3. Open an issue in the repository

---

**Happy coding!** 🚀

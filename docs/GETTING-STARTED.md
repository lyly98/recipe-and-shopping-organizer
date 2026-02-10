# Getting Started - Recipe and Shopping Organizer

This guide will help you set up and run the Recipe and Shopping Organizer monorepo.

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

### Required

1. **Flutter** (3.16+)
   ```bash
   # Install Flutter: https://docs.flutter.dev/get-started/install
   
   # Verify installation
   flutter doctor
   ```

2. **Python** (3.11+)
   ```bash
   # Install Python: https://www.python.org/downloads/
   
   # Verify installation
   python3 --version
   ```

3. **Git**
   ```bash
   git --version
   ```

### Recommended

4. **Docker** & **Docker Compose**
   ```bash
   # Install Docker: https://docs.docker.com/get-docker/
   
   # Verify installation
   docker --version
   docker-compose --version
   ```

5. **PostgreSQL** (15+) - Only if not using Docker
   ```bash
   # macOS
   brew install postgresql@15
   
   # Start PostgreSQL
   brew services start postgresql@15
   ```

### Development Tools

- **VS Code** with extensions:
  - Flutter
  - Python
  - Docker
  - GitLens

- **OR Android Studio / IntelliJ IDEA**

---

## 🚀 Quick Start (Using Docker - Recommended)

### 1. Clone the Repository

```bash
git clone <your-repo-url>
cd recipe-and-shopping-organizer
```

### 2. Run Setup Script

```bash
./scripts/setup-dev.sh
```

This script will:
- Check all prerequisites
- Set up Python virtual environment
- Install backend dependencies
- Install Flutter dependencies
- Create `.env` file from template
- Start Docker services (PostgreSQL & Redis)

### 3. Update Configuration

Edit `apps/backend/.env` and update the necessary values:

```env
# Required: Change this!
SECRET_KEY=generate-a-secure-key-here

# Database (default for Docker Compose)
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/recipe_db

# Cloudinary (add your credentials)
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
```

### 4. Run Database Migrations

```bash
cd apps/backend
source venv/bin/activate  # Windows: venv\Scripts\activate
alembic upgrade head
```

### 5. Create Admin User (Optional)

```bash
docker-compose run --rm backend python -m app.scripts.create_superuser
```

### 6. Start Development Servers

**Option A: Using Docker Compose**

```bash
docker-compose up
```

Then in another terminal:
```bash
cd apps/mobile
flutter run
```

**Option B: Without Docker (Manual)**

Terminal 1 - Backend:
```bash
cd apps/backend
source venv/bin/activate
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Terminal 2 - Mobile:
```bash
cd apps/mobile
flutter run
```

**Option C: Using Helper Script (macOS/Linux)**

```bash
./scripts/run-all.sh
```

### 7. Access Your Application

- **Mobile App**: Running on emulator/simulator
- **Backend API**: http://localhost:8000
- **API Documentation**: http://localhost:8000/docs (Swagger UI)
- **Database**: postgresql://postgres:postgres@localhost:5432/recipe_db

---

## 📱 Mobile Development

### Running the App

```bash
cd apps/mobile

# iOS Simulator
flutter run -d "iPhone 15 Pro"

# Android Emulator
flutter run -d emulator-5554

# Chrome (for web testing)
flutter run -d chrome
```

### Common Tasks

```bash
# Get dependencies
flutter pub get

# Update dependencies
flutter pub upgrade

# Generate code (Freezed, Riverpod)
dart run build_runner build --delete-conflicting-outputs

# Run tests
flutter test

# Run with coverage
flutter test --coverage

# Clean build
flutter clean
```

### Project Structure

```
apps/mobile/
├── lib/
│   ├── core/              # Shared utilities
│   ├── features/          # Feature modules (Clean Architecture)
│   │   ├── auth/
│   │   │   ├── domain/    # Entities, repositories, use cases
│   │   │   ├── data/      # Data sources, models, repositories
│   │   │   └── presentation/ # UI, providers
│   │   ├── recipes/
│   │   └── ...
│   └── main.dart
├── test/
├── assets/
└── pubspec.yaml
```

---

## 🔧 Backend Development

### Running the Server

```bash
cd apps/backend
source venv/bin/activate  # Windows: venv\Scripts\activate

# Development server (auto-reload)
uvicorn app.main:app --reload

# Production-like
gunicorn app.main:app -w 4 -k uvicorn.workers.UvicornWorker
```

### Common Tasks

```bash
# Install dependencies
pip install -r requirements.txt

# Update dependencies
pip freeze > requirements.txt

# Create migration
alembic revision --autogenerate -m "description"

# Run migrations
alembic upgrade head

# Rollback migration
alembic downgrade -1

# Run tests
pytest

# Run tests with coverage
pytest --cov=app --cov-report=html

# Format code
black app/
isort app/

# Lint
flake8 app/
mypy app/
```

### Project Structure

```
apps/backend/
├── app/
│   ├── api/
│   │   └── v1/            # API endpoints
│   ├── models/            # SQLAlchemy models
│   ├── schemas/           # Pydantic schemas
│   ├── services/          # Business logic
│   ├── core/              # Config, security, database
│   └── main.py            # FastAPI app
├── alembic/               # Database migrations
├── tests/
└── requirements.txt
```

---

## 🧪 Testing

### Run All Tests

```bash
# Using helper script
./scripts/test-all.sh

# Or manually:

# Backend tests
cd apps/backend
pytest --cov=app

# Mobile tests
cd apps/mobile
flutter test --coverage
```

### Test Structure

**Backend:**
- Unit tests: `tests/unit/`
- Integration tests: `tests/integration/`
- API tests: `tests/api/`

**Mobile:**
- Unit tests: `test/unit/`
- Widget tests: `test/widgets/`
- Integration tests: `integration_test/`

---

## 🐳 Docker Commands

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f backend

# Stop all services
docker-compose down

# Rebuild after changes
docker-compose up -d --build

# Run command in container
docker-compose exec backend alembic upgrade head

# Access database
docker-compose exec db psql -U postgres -d recipe_db
```

---

## 🌐 API Configuration

### Mobile App API URL

Update `apps/mobile/lib/core/config/app_config.dart`:

```dart
class AppConfig {
  static const String apiBaseUrl = Environment.apiBaseUrl;
  
  // Development (choose based on platform)
  // iOS Simulator: http://localhost:8000
  // Android Emulator: http://10.0.2.2:8000
  // Physical Device: http://YOUR_IP:8000
}
```

### Environment Variables

Create `apps/mobile/lib/core/config/environment.dart`:

```dart
class Environment {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );
}
```

Run with custom API URL:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.100:8000
```

---

## 🔐 Authentication Setup

### Backend JWT Configuration

In `apps/backend/.env`:

```env
SECRET_KEY=your-secret-key-here  # Generate with: openssl rand -hex 32
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
REFRESH_TOKEN_EXPIRE_DAYS=7
```

### Mobile Secure Storage

The mobile app uses `flutter_secure_storage` to store tokens securely.

---

## 📊 Database Management

### Access Database

```bash
# Via Docker
docker-compose exec db psql -U postgres -d recipe_db

# Or directly (if PostgreSQL installed locally)
psql -U postgres -d recipe_db
```

### Useful SQL Commands

```sql
-- List all tables
\dt

-- Describe table
\d users

-- Show all users
SELECT * FROM users;

-- Check recipe count
SELECT COUNT(*) FROM recipes;
```

### Database GUI Tools

- **pgAdmin**: https://www.pgadmin.org/
- **DBeaver**: https://dbeaver.io/
- **TablePlus**: https://tableplus.com/

---

## 🛠️ Troubleshooting

### Backend Issues

**Issue**: `ModuleNotFoundError: No module named 'app'`
```bash
# Make sure you're in the right directory and venv is activated
cd apps/backend
source venv/bin/activate
```

**Issue**: `sqlalchemy.exc.OperationalError: could not connect to server`
```bash
# Check if PostgreSQL is running
docker-compose ps
# or
pg_isready -h localhost -p 5432
```

**Issue**: `Alembic migration fails`
```bash
# Reset migrations (development only!)
cd apps/backend
rm alembic/versions/*.py
alembic revision --autogenerate -m "initial"
alembic upgrade head
```

### Mobile Issues

**Issue**: `flutter: command not found`
```bash
# Add Flutter to PATH
export PATH="$PATH:`pwd`/flutter/bin"
# Or follow: https://docs.flutter.dev/get-started/install
```

**Issue**: `Unable to connect to API`
```bash
# Android emulator: Use 10.0.2.2 instead of localhost
# iOS simulator: Use localhost or 127.0.0.1

# Check API is running:
curl http://localhost:8000/health
```

**Issue**: `Gradle build failed`
```bash
cd apps/mobile/android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Docker Issues

**Issue**: `port 5432 already allocated`
```bash
# Stop existing PostgreSQL
brew services stop postgresql  # macOS
sudo systemctl stop postgresql  # Linux

# Or change port in docker-compose.yml
```

---

## 📚 Additional Resources

### Documentation

- [Monorepo Guide](./MONOREPO-GUIDE.md) - Detailed monorepo structure and best practices
- [Architecture](./docs/05-architecture.md) - System architecture and design decisions
- [Tech Stack](./TECH-STACK.md) - Technology choices and rationale

### Boilerplate Documentation

- [Flutter Riverpod Clean Architecture](https://github.com/ssoad/flutter_riverpod_clean_architecture)
- [FastAPI Boilerplate](https://benavlabs.github.io/FastAPI-boilerplate/)

### Framework Documentation

- [Flutter Docs](https://docs.flutter.dev/)
- [Riverpod Docs](https://riverpod.dev/)
- [FastAPI Docs](https://fastapi.tiangolo.com/)
- [SQLAlchemy Docs](https://docs.sqlalchemy.org/)

---

## 🤝 Getting Help

1. Check the [Troubleshooting](#troubleshooting) section above
2. Review the [Monorepo Guide](./MONOREPO-GUIDE.md)
3. Check existing GitHub issues
4. Open a new GitHub issue with:
   - What you're trying to do
   - What you expected to happen
   - What actually happened
   - Steps to reproduce
   - Your environment (OS, Flutter/Python versions)

---

## ✅ Next Steps

Once you have everything running:

1. **Explore the API**
   - Visit http://localhost:8000/docs
   - Try the authentication endpoints
   - Test creating a recipe

2. **Build Your First Feature**
   - Follow the Clean Architecture pattern in the mobile app
   - Create a new feature using the Flutter boilerplate structure
   - Connect it to the backend API

3. **Set Up CI/CD**
   - Review `.github/workflows/` for GitHub Actions setup
   - Configure secrets for deployment

4. **Deploy**
   - Follow deployment guides in `docs/05-architecture.md`
   - Set up Railway/Render for backend
   - Build mobile app for App Store/Play Store

---

**Happy coding!** 🚀

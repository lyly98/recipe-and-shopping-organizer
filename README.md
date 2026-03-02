# Recipe and Shopping Organizer

A full-stack mobile application for organizing recipes, planning weekly meals, and generating grocery shopping lists.

## Monorepo Structure

```
recipe-and-shopping-organizer/
├── apps/
│   ├── mobile/          # Flutter app (iOS & Android)
│   └── backend/         # FastAPI backend
├── docs/                # Technical documentation
├── scripts/             # Development & deployment scripts
├── docker-compose.yml   # Local development environment
└── MONOREPO-GUIDE.md    # Monorepo documentation
```

## Features

### Recipe Management
- Create and store recipes with title, ingredients, preparation steps, and images
- Organize recipes into customizable categories with emojis and colors
- Default categories: Petit-déjeuner, Déjeuner, Dîner, Desserts
- Search and filter recipes within categories
- Toggle recipes as favorites; track view counts
- Public and private recipe visibility

### Video / Link Recipe Import
- Import recipes by pasting a URL (TikTok, Instagram, YouTube, Facebook)
- Auto-populate recipe fields from extracted content

### Meal Planning
- Weekly planning view (7 days)
- Two meal slots per day
- Assign saved recipes to any slot
- Remove or swap planned meals

### Grocery Shopping List
- Auto-generate a consolidated shopping list from the weekly meal plan
- Specify number of servings/people
- View and manage the full ingredient list

### Other
- WebSocket-based chat screen
- Onboarding/feedback survey flow
- Settings: theme, language (EN, ES, FR, DE, JA, BN), accessibility
- Biometric authentication support
- Offline-aware data layer with sync queue

---

## Tech Stack

### Mobile (Flutter)

| Concern | Library |
|---|---|
| Language | Dart (SDK ≥ 3.10) |
| State management | Riverpod 3 + code generation |
| Routing | `go_router` |
| HTTP client | `dio` |
| Functional error handling | `fpdart` (`Either`) |
| Data classes | `freezed` + `json_serializable` |
| Local storage | `hive`, `shared_preferences` |
| Secure storage | `flutter_secure_storage` |
| Image | `cached_network_image`, `image_picker` |
| Forms | `flutter_form_builder` + validators |
| Biometrics | `local_auth` |
| WebSocket | `web_socket_channel` |
| Background tasks | `workmanager` |
| i18n | Flutter `intl` (6 locales) |

### Backend (FastAPI)

| Concern | Library |
|---|---|
| Language | Python 3.11+ |
| Framework | FastAPI |
| ORM | SQLAlchemy 2.0 (async) |
| Database | PostgreSQL 15 (asyncpg) |
| Cache / Queue | Redis 7 (`redis`, `arq`) |
| Auth | JWT (`python-jose`), bcrypt |
| CRUD abstraction | `fastcrud`, `crudadmin` |
| Migrations | Alembic |
| Validation | Pydantic v2 |
| Linting | Ruff, mypy |
| Logging | `structlog`, `rich` |
| Server | Uvicorn + Gunicorn |

### Infrastructure
- Docker Compose (PostgreSQL 15 + Redis 7)
- Nginx (production reverse proxy)
- Fastlane (iOS & Android deployment automation)
- CI/CD via GitHub Actions

---

## API Reference

All routes are prefixed with `/api/v1`.

### Auth
| Method | Endpoint | Description |
|---|---|---|
| POST | `/login` | Obtain access + refresh tokens |
| POST | `/logout` | Blacklist current token |

### Users
| Method | Endpoint | Description |
|---|---|---|
| POST | `/register` | Create account (seeds default categories) |
| GET | `/user/me/` | Current authenticated user |
| GET | `/user/{username}` | Get user by username |
| PATCH | `/user/{username}` | Update user (owner only) |
| DELETE | `/user/{username}` | Soft-delete user (owner only) |

### Recipes
| Method | Endpoint | Description |
|---|---|---|
| POST | `/recipes` | Create recipe with ingredients & steps |
| GET | `/recipes` | Paginated list (filters: `category_id`, `favorites_only`, `public_only`) |
| GET | `/recipes/my` | Current user's recipes with nested data |
| GET | `/recipes/{recipe_id}` | Recipe detail (increments view count) |
| PATCH | `/recipes/{recipe_id}` | Update recipe |
| DELETE | `/recipes/{recipe_id}` | Delete recipe (cascades) |
| POST | `/recipes/{recipe_id}/favorite` | Toggle favorite |

### Categories
| Method | Endpoint | Description |
|---|---|---|
| POST | `/categories` | Create category |
| GET | `/categories` | User's categories (paginated) |
| GET | `/categories/{category_id}` | Get category |
| PATCH | `/categories/{category_id}` | Update category |
| DELETE | `/categories/{category_id}` | Delete category |

### Meal Plan
| Method | Endpoint | Description |
|---|---|---|
| GET | `/meal-plan` | Entries for date range (`start_date`, `end_date`) |
| POST | `/meal-plan` | Add recipe to a meal slot |
| DELETE | `/meal-plan/{entry_id}` | Remove meal plan entry |

### Upload
| Method | Endpoint | Description |
|---|---|---|
| POST | `/upload/image` | Upload recipe image (JPEG/PNG/WebP/GIF, max 10 MB) |

### Health
| Method | Endpoint | Description |
|---|---|---|
| GET | `/health` | Health check |

Interactive API docs are available at `http://localhost:8000/docs` when the backend is running.

---

## Quick Start

### Prerequisites

- **Flutter** 3.16+ — [Install](https://docs.flutter.dev/get-started/install)
- **Python** 3.11+ — [Install](https://www.python.org/downloads/)
- **Docker** & Docker Compose — [Install](https://docs.docker.com/get-docker/)

### Option 1: Docker (Recommended)

```bash
# Clone the repository
git clone <your-repo-url>
cd recipe-and-shopping-organizer

# Start backend, database, and Redis
docker-compose up -d

# Run the Flutter app
cd apps/mobile
flutter pub get
flutter run
```

### Option 2: Local Development (No Docker)

```bash
# Backend
cd apps/backend
python3 -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate
pip install -r requirements.txt
cd src
alembic upgrade head
uvicorn app.main:app --reload --port 8000

# Mobile (in a separate terminal)
cd apps/mobile
flutter pub get
flutter run
```

### First-Time Setup

```bash
# Run database migrations
cd apps/backend/src
alembic upgrade head

# (Optional) Create a superuser
docker-compose run --rm backend python -m app.scripts.create_superuser
```

---

## Project Structure — Mobile

```
apps/mobile/lib/
├── core/
│   ├── theme/           # App palette and theme definitions
│   ├── router/          # GoRouter configuration and guards
│   ├── network/         # Dio client, interceptors
│   ├── storage/         # Hive, SharedPreferences, SecureStorage wrappers
│   └── ...
├── features/
│   ├── auth/            # Login, registration, biometric auth
│   ├── home/            # Recipes tab, Planning tab, Category management
│   ├── chat/            # WebSocket chat
│   ├── survey/          # Onboarding survey
│   ├── settings/        # Theme, language, accessibility
│   └── ui_showcase/     # Component gallery (dev)
└── main.dart
```

## Project Structure — Backend

```
apps/backend/src/app/
├── api/v1/          # Route handlers (auth, users, recipes, categories, meal-plan, upload)
├── core/            # Config, DB session, security, utils
├── crud/            # fastcrud operation wrappers
├── models/          # SQLAlchemy ORM models
├── schemas/         # Pydantic request/response schemas
├── middleware/       # CORS, logging, Redis cache
└── admin/           # CRUDAdmin interface (mounted at /admin)
```

---

## Documentation

| Document | Purpose |
|---|---|
| [docs/01-requirements.md](./docs/01-requirements.md) | Functional & non-functional requirements |
| [docs/02-uml-diagrams.md](./docs/02-uml-diagrams.md) | Use case, class, activity, state diagrams |
| [docs/03-sequence-diagrams.md](./docs/03-sequence-diagrams.md) | Sequence diagrams for key flows |
| [docs/04-database-schema.md](./docs/04-database-schema.md) | Database ERD and schema |
| [docs/05-architecture.md](./docs/05-architecture.md) | System architecture |
| [docs/06-tech-stack-guide.md](./docs/06-tech-stack-guide.md) | Technology stack evaluation |
| [docs/07-figma-design-reference.md](./docs/07-figma-design-reference.md) | Design system and UI components |
| [MONOREPO-GUIDE.md](./MONOREPO-GUIDE.md) | Monorepo organization and conventions |

## Design

**Figma File**: [View in Figma](https://www.figma.com/make/zYcBkRQoCvYTxrCIS8yiHZ/Recipe-and-Shopping-Organizer?fullscreen=1&t=n9UskWVIBXlHV4cO-1)

The file includes: recipe category grid, category management, video import modal, weekly meal planning calendar, shopping list interface, recipe creation form, and the full design system (color palette, typography, components).

---

## Common Commands

```bash
# Start all services (Docker)
docker-compose up

# Run Flutter app
cd apps/mobile && flutter run

# Run backend with hot reload
cd apps/backend/src && uvicorn app.main:app --reload

# Run Flutter tests
cd apps/mobile && flutter test

# Lint backend
cd apps/backend && ruff check . && mypy .

# Generate Flutter code (Riverpod, Freezed, JSON)
cd apps/mobile && dart run build_runner build --delete-conflicting-outputs
```

## License

[To be determined]

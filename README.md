# Recipe and Shopping Organizer

A comprehensive mobile application for organizing recipes, meal planning, and grocery shopping.

## 📱 Monorepo Structure

This is a **monorepo** containing both the Flutter mobile app and FastAPI backend in a single repository.

```
recipe-and-shopping-organizer/
├── apps/
│   ├── mobile/          # Flutter app (iOS & Android)
│   └── backend/         # FastAPI backend
├── docs/                # Technical documentation
└── scripts/             # Development & deployment scripts
```

## Overview

This application helps users manage their daily cooking, planning, and shopping needs with features including recipe management with categories, video-based recipe import, and automated grocery list generation from weekly meal plans.

## Key Features

### 1. Recipe Management
- Create and store recipes with detailed information (title, ingredients, preparation steps, images)
- Organize recipes into customizable categories (Plats, Pains, Desserts, Jus, Snacks, Soupes, etc.)
- Add recipe images and emojis for visual identification
- Search and filter recipes within categories

### 2. Video Recipe Import
- Import recipes from social media platforms (TikTok, Instagram, YouTube, Facebook)
- Paste video URL to extract and transcribe recipe content
- Auto-populate recipe fields from video content
- Support for multiple video platforms

### 3. Meal Planning
- Weekly meal planning view (7 days)
- Two meal slots per day (Breakfast/Petit-déj and Lunch/Déjeuner, or Snack and Dinner/Dîner)
- Drag-and-drop or select recipes for each meal slot
- View recipe suggestions based on saved categories
- Empty state management for planned meals

### 4. Grocery Shopping List
- Auto-generate shopping list from weekly meal plan
- Specify number of servings/people
- Consolidated list of all ingredients needed
- Export or share shopping list
- Link to external grocery services integration (planned feature)

## Documentation Structure

```
docs/
├── 01-requirements.md          # Functional & non-functional requirements
├── 02-uml-diagrams.md          # Use case, class, activity, state diagrams
├── 03-sequence-diagrams.md     # Sequence diagrams for key flows
├── 04-database-schema.md       # Database ERD and schema
├── 05-architecture.md          # System architecture
├── 06-tech-stack-guide.md      # Technology stack evaluation guide
├── 07-figma-design-reference.md # Figma design system and UI components
└── diagrams/                    # Mermaid diagram source files
```

## Design

**Figma Design File**: [View in Figma](https://www.figma.com/make/zYcBkRQoCvYTxrCIS8yiHZ/Recipe-and-Shopping-Organizer?fullscreen=1&t=n9UskWVIBXlHV4cO-1)

The complete design system and UI components are documented in `docs/07-figma-design-reference.md`.

The Figma file showcases:
- Recipe categories view with grid layout and emoji icons
- Category management interface with add/edit functionality
- Video import modal with platform selection (TikTok, Instagram, YouTube, Facebook)
- Weekly meal planning calendar with two meal slots per day
- Meal detail tooltips showing recipe information
- Shopping list generation and management interface
- Recipe creation form with multi-step workflow
- Color palette, typography, and component specifications

Design screenshots are also available in the `assets/` folder for quick reference.

## 🚀 Quick Start

### Prerequisites

- **Flutter** 3.16+ ([Install](https://docs.flutter.dev/get-started/install))
- **Python** 3.11+ ([Install](https://www.python.org/downloads/))
- **Docker** & Docker Compose ([Install](https://docs.docker.com/get-docker/))
- **PostgreSQL** 15+ (via Docker or local)

### Setup (Development)

**Option 1: Using Docker (Recommended)**

```bash
# Clone the repository
git clone <your-repo-url>
cd recipe-and-shopping-organizer

# Start all services (backend, database, redis)
docker-compose up -d

# Run Flutter app
cd apps/mobile
flutter pub get
flutter run
```

**Option 2: Local Development (No Docker)**

```bash
# Backend setup
cd apps/backend
python3 -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000

# In another terminal - Mobile setup
cd apps/mobile
flutter pub get
flutter run
```

### First Time Setup

1. **Create admin user:**
   ```bash
   docker-compose run --rm backend python -m app.scripts.create_superuser
   ```

2. **Run database migrations:**
   ```bash
   cd apps/backend
   alembic upgrade head
   ```

3. **Access the API docs:**
   - Backend API: http://localhost:8000/docs
   - Mobile App: Running on emulator/simulator

See detailed setup instructions in `docs/05-architecture.md`.

## Tech Stack ✅

**Frontend:**
- Flutter (iOS & Android)
- State Management: Provider/Riverpod
- HTTP Client: Dio

**Backend:**
- Python 3.11+ with FastAPI
- SQLAlchemy ORM
- Pydantic for validation
- Alembic for migrations

**Database:**
- PostgreSQL 15+

**Infrastructure:**
- Hosting: Railway or Render
- Storage: Cloudinary
- Email: SendGrid

See `docs/05-architecture.md` for detailed architecture and setup instructions.

## 📁 Repository Organization

This monorepo follows **standard Flutter + Backend** structure:

```
recipe-and-shopping-organizer/
├── apps/
│   ├── mobile/          # Flutter app (iOS & Android)
│   └── backend/         # FastAPI backend
├── docs/                # Technical documentation
├── scripts/             # Development automation scripts
├── .github/             # CI/CD workflows
├── docker-compose.yml   # Local development environment
└── MONOREPO-GUIDE.md    # Detailed monorepo documentation
```

### Boilerplates Used

- **Mobile**: [Flutter Riverpod Clean Architecture](https://github.com/ssoad/flutter_riverpod_clean_architecture)
- **Backend**: [FastAPI Boilerplate](https://github.com/benavlabs/FastAPI-boilerplate)

## 📖 Documentation

| Document | Purpose |
|----------|---------|
| [GETTING-STARTED.md](./GETTING-STARTED.md) | Complete setup guide for development |
| [MONOREPO-GUIDE.md](./MONOREPO-GUIDE.md) | Monorepo organization and best practices |
| [TECH-STACK.md](./TECH-STACK.md) | Technology stack details and rationale |
| [PROJECT-OVERVIEW.md](./PROJECT-OVERVIEW.md) | Project overview and roadmap |
| [docs/](./docs/) | Technical specifications, diagrams, architecture |

## 🚀 Quick Commands

```bash
# Setup development environment
./scripts/setup-dev.sh

# Run all services
docker-compose up

# Run tests
./scripts/test-all.sh

# Start mobile app
cd apps/mobile && flutter run

# Start backend
cd apps/backend && uvicorn app.main:app --reload
```

## Project Status

**Phase**: Ready for Development  
**Next Steps**: 
1. Clone the boilerplates into `apps/` folders
2. Integrate with project requirements
3. Implement MVP features (Phase 1)

## License

[To be determined]

## Contact

[To be determined]

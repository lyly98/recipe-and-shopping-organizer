# System Architecture - Phased Approach

## Architecture Philosophy: Start Simple, Scale Later

This document presents a **phased architecture** starting with a simple MVP and evolving only when needed.

**Core Principle**: Build a working recipe app first, add AI/video features later.

---

## Phase 1: MVP Architecture (Weeks 1-8) ⭐ **START HERE**

### Overview

**Goal**: Working recipe app without AI/video features  
**Cost**: ~$20-45/month  
**Timeline**: 8 weeks  
**Team**: 1-2 developers

### Architecture Diagram

```mermaid
graph TB
    subgraph "Client"
        Mobile[Mobile App<br/>Flutter<br/>iOS & Android]
    end
    
    subgraph "Server"
        API[Backend API<br/>FastAPI + Python<br/>Single Monolith]
    end
    
    subgraph "Data"
        DB[(PostgreSQL<br/>Single Instance)]
        Storage[Image Storage<br/>Cloudinary]
    end
    
    Mobile --> API
    API --> DB
    API --> Storage
```

### What's Included

**✅ Features:**
- User authentication (register, login)
- Recipe CRUD operations
- Category management  
- Meal planning (weekly calendar)
- Shopping list generation
- Image upload for recipes
- Basic search

**❌ NOT Included:**
- Video import
- AI/ML services
- Caching layer
- Load balancer
- CDN
- Message queues
- Microservices

### Technology Stack ✅ **CHOSEN**

```yaml
Frontend:
  - Flutter (cross-platform mobile: iOS & Android)
  - State Management: Provider or Riverpod
  - HTTP Client: Dio
  
Backend:
  - Python 3.11+
  - FastAPI (modern async web framework)
  - Pydantic (data validation)
  - SQLAlchemy (ORM)
  - Alembic (database migrations)
  - Monolithic architecture (all features in one codebase)

Database:
  - PostgreSQL 15+ (managed on Railway/Render)
  - Single instance, no replicas

Storage:
  - Cloudinary (free tier + CDN included)
  - OR AWS S3 (pay as you go)

Hosting:
  - Railway or Render (easiest deployment)
  - Single server (API + Database)

Authentication:
  - JWT tokens with python-jose
  - Bcrypt for password hashing

Email:
  - SendGrid (free tier: 100/day)
  - OR AWS SES
```

**Why This Stack?**
- **Flutter**: Single codebase for iOS & Android, fast development, beautiful UI
- **FastAPI**: Async support, automatic API docs (Swagger), type safety, perfect for mobile APIs
- **PostgreSQL**: Robust, reliable, great JSON support, perfect for recipe data

### Project Structure

```
recipe-app/
├── mobile/                  # Flutter app
│   ├── lib/
│   │   ├── screens/        # UI screens
│   │   ├── widgets/        # Reusable UI components
│   │   ├── models/         # Data models
│   │   ├── services/       # API & business logic
│   │   ├── providers/      # State management
│   │   └── main.dart       # Entry point
│   ├── assets/             # Images, fonts
│   └── pubspec.yaml        # Dependencies
│
├── backend/                 # FastAPI backend
│   ├── app/
│   │   ├── api/
│   │   │   ├── auth.py          # Authentication endpoints
│   │   │   ├── recipes.py       # Recipe CRUD
│   │   │   ├── categories.py    # Category management
│   │   │   ├── meal_plans.py    # Meal planning
│   │   │   └── shopping_lists.py # Shopping lists
│   │   ├── models/              # SQLAlchemy models
│   │   ├── schemas/             # Pydantic schemas
│   │   ├── services/            # Business logic
│   │   ├── core/                # Config, security, DB
│   │   └── main.py              # FastAPI app
│   ├── alembic/                 # Database migrations
│   │   ├── versions/
│   │   └── env.py
│   └── requirements.txt         # Python dependencies
│
└── README.md
```

### Database Tables (Phase 1)

**Use these from `04-database-schema.md`:**
- ✅ users
- ✅ user_preferences
- ✅ categories
- ✅ recipes
- ✅ ingredients
- ✅ preparation_steps
- ✅ meal_plans
- ✅ meal_slots
- ✅ shopping_lists
- ✅ shopping_list_items
- ✅ recipe_notes

**Skip for now:**
- ⏳ video_imports (Phase 2)
- ⏳ recipe_shares (Phase 2)

### API Endpoints (Phase 1)

```
Auth:
  POST   /api/auth/register
  POST   /api/auth/login
  POST   /api/auth/logout
  GET    /api/auth/me

Recipes:
  GET    /api/recipes
  GET    /api/recipes/:id
  POST   /api/recipes
  PUT    /api/recipes/:id
  DELETE /api/recipes/:id
  GET    /api/recipes/search?q=query

Categories:
  GET    /api/categories
  POST   /api/categories
  PUT    /api/categories/:id
  DELETE /api/categories/:id

Meal Plans:
  GET    /api/meal-plans/current-week
  POST   /api/meal-plans/:id/slots
  PUT    /api/meal-slots/:id
  DELETE /api/meal-slots/:id

Shopping Lists:
  POST   /api/shopping-lists/generate
  GET    /api/shopping-lists/:id
  PUT    /api/shopping-list-items/:id

Images:
  POST   /api/upload/image
```

### Deployment (Railway/Render)

**One-click deployment:**

1. Push code to GitHub
2. Connect Railway/Render to repository
3. Add PostgreSQL database (addon)
4. Set environment variables
5. Deploy automatically

**No need for:**
- Docker configuration
- Kubernetes
- CI/CD pipeline setup
- Load balancer
- CDN configuration

### Request Flow (Simple)

```mermaid
sequenceDiagram
    participant User
    participant App as Mobile App
    participant API as Backend API
    participant DB as PostgreSQL
    
    User->>App: Create Recipe
    App->>API: POST /recipes
    API->>DB: INSERT recipe
    DB-->>API: Recipe created
    API-->>App: Success
    App-->>User: Show success
```

**No complexity:**
- No caching checks
- No queue processing
- No service-to-service calls
- Direct database access

---

## Phase 2: Add AI & Video (Weeks 9-12) - **IMPLEMENT AFTER MVP WORKS**

> ⚠️ **Important**: Only implement this phase AFTER Phase 1 is complete and working well with real users.

### Overview

**Goal**: Add video import with AI recipe extraction  
**Cost**: ~$105-155/month (includes video processing)  
**Timeline**: +4 weeks  
**Prerequisite**: ✅ MVP working, tested, and validated with users

### Architecture Additions

```mermaid
graph TB
    subgraph "Client"
        Mobile[Mobile App]
    end
    
    subgraph "Server"
        API[Backend API<br/>Same as Phase 1]
        Worker[Background Worker<br/>NEW - Video Processing]
    end
    
    subgraph "Data"
        DB[(Database<br/>Same as Phase 1)]
        Queue[(Job Queue<br/>NEW - Redis or pg-boss)]
    end
    
    subgraph "External - NEW"
        VideoAPI[Video APIs<br/>YouTube, TikTok]
        AI[AI Services<br/>Transcription + NLP]
    end
    
    Mobile --> API
    API --> DB
    API --> Queue
    Queue --> Worker
    Worker --> VideoAPI
    Worker --> AI
    Worker --> DB
    
    style Worker fill:#FFE4B5
    style Queue fill:#FFE4B5
    style VideoAPI fill:#FFE4B5
    style AI fill:#FFE4B5
```

**🆕 New Components (highlighted in yellow):**

**1. Background Worker**
- Processes video imports asynchronously
- Runs as separate process (same server or separate)
- Handles slow operations (30s - 2min per video)

**2. Job Queue**
- Simple queue: Bull (Redis) or pg-boss (PostgreSQL)
- Manages video processing jobs
- Handles retries on failure

**3. External Services**
- Video APIs: Fetch metadata from TikTok/YouTube/Instagram
- Transcription: Convert audio to text (AssemblyAI or AWS Transcribe)
- AI/NLP: Parse recipe from text (OpenAI GPT-4)

### New Features

- ✅ Paste video URL (TikTok, Instagram, YouTube, Facebook)
- ✅ Extract video metadata
- ✅ Transcribe audio
- ✅ Parse recipe with AI
- ✅ Let user review/edit before saving

### Database Changes

**Add table:**
```sql
CREATE TABLE video_imports (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    video_url TEXT NOT NULL,
    platform VARCHAR(50),
    status VARCHAR(20), -- pending, processing, completed, failed
    extracted_data JSONB,
    created_at TIMESTAMP
);
```

### Cost Breakdown

```
Phase 1 costs:              $45/month
+ Redis queue:              $10/month
+ Video processing:         $50-100/month (for 100 imports)
  - Transcription:          $20
  - AI parsing (OpenAI):    $30-80
─────────────────────────────────────
Total Phase 2:              ~$105-155/month
```

---

## Phase 3: Scale (Future)

### When to Consider

**Don't scale until:**
- ✅ 1,000+ daily active users
- ✅ Performance issues with current setup
- ✅ Revenue supports higher costs
- ✅ Team size justifies complexity

### Scaling Strategies

**1. Add Caching (when database CPU > 70%)**
```mermaid
graph LR
    API[API] --> Cache[(Redis Cache)]
    API --> DB[(Database)]
    Cache -.Cache Miss.-> DB
```

**2. Add Read Replicas (when read-heavy)**
```mermaid
graph LR
    API[API] --> Primary[(Primary DB<br/>Writes)]
    API --> Replica[(Read Replica<br/>Reads)]
    Primary -.Replication.-> Replica
```

**3. Add Load Balancer (multiple servers)**
```mermaid
graph LR
    Client[Clients] --> LB[Load Balancer]
    LB --> API1[API Server 1]
    LB --> API2[API Server 2]
```

**4. Add CDN (for global users)**
```mermaid
graph LR
    Client[Clients] --> CDN[CDN]
    CDN --> Storage[Image Storage]
```

### Cost at Scale

```
5,000-10,000 active users:
- Infrastructure:           $200-500/month
- Database (with replicas): $100-200/month
- Caching (Redis):          $30-50/month
- CDN:                      $20-50/month
- Video/AI services:        $300-500/month
- Monitoring:               $50-100/month
─────────────────────────────────────
Total Phase 3:              ~$700-1,400/month
```

---

## Database Strategy

### Phase 1: Simple

```
Single PostgreSQL instance
No caching
No replicas
Standard indexes
```

**Why simple:**
- PostgreSQL handles 1000s of users easily
- No premature optimization
- Lower costs
- Easier to manage

### Phase 2: Add Queue

```
PostgreSQL (same)
+ Redis for job queue (or pg-boss using PostgreSQL)
```

### Phase 3: Scale Database

```
Primary database (writes)
+ Read replicas (reads)
+ Redis cache (hot data)
+ Connection pooling
```

---

## Security

### Phase 1 Essentials

**Must have:**
- ✅ JWT authentication (15-min access token, 7-day refresh token)
- ✅ Password hashing with bcrypt (cost factor 12)
- ✅ HTTPS only (enforced by hosting provider)
- ✅ Input validation on all endpoints
- ✅ SQL injection prevention (use ORM/parameterized queries)
- ✅ File upload restrictions (size, type)
- ✅ Basic rate limiting (100 requests/15min per IP)

**Skip for MVP:**
- ❌ Advanced rate limiting per user
- ❌ DDoS protection (hosting provider handles)
- ❌ Web Application Firewall
- ❌ Intrusion detection

### Phase 2: Enhanced

- ✅ Per-user rate limiting
- ✅ Email verification
- ✅ Account lockout after failed logins

### Phase 3: Enterprise

- ✅ Two-factor authentication
- ✅ Security audits
- ✅ Compliance (GDPR, SOC 2)

---

## Monitoring

### Phase 1: Keep Simple

**Essential:**
- Application logs (console/stdout)
- Error tracking: **Sentry** (free tier: 5k errors/month)
- Uptime monitoring: **UptimeRobot** (free)
- Database metrics: Railway/Render dashboard

**Skip:**
- ❌ Custom dashboards
- ❌ APM tools (Datadog, New Relic)
- ❌ Log aggregation systems

### Phase 2: Better Visibility

- ✅ Structured logging
- ✅ Application metrics (response times, error rates)
- ✅ User analytics (Mixpanel free tier)

### Phase 3: Full Observability

- ✅ Distributed tracing
- ✅ Custom dashboards
- ✅ Advanced alerting
- ✅ APM tools

---

## Deployment

### Phase 1: One-Click Deploy

**Workflow:**
```
Local Dev → Git Push → Auto Deploy to Production
```

**No complexity:**
- No Docker (Railway handles it)
- No Kubernetes
- No CI/CD pipeline (built-in)
- No staging environment initially
- No blue-green deployment

### Phase 2: Add Staging

**Workflow:**
```
Local Dev → Git Push → Deploy to Staging → Manual Approval → Production
```

### Phase 3: Full DevOps

- ✅ Docker + Kubernetes
- ✅ CI/CD with GitHub Actions
- ✅ Automated tests
- ✅ Blue-green deployments
- ✅ Infrastructure as Code

---

## Technology Decisions

### Mobile App

**Recommended: React Native + Expo**

**Why:**
- ✅ Cross-platform (iOS + Android)
- ✅ JavaScript (same as backend if using Node.js)
- ✅ Fast development
- ✅ Hot reload
- ✅ Large community

**Alternative: Flutter**
- Good performance
- Beautiful UI
- Need to learn Dart

**Skip: Native (Swift + Kotlin)**
- Too much work for MVP
- Requires separate teams

### Backend

**Recommended: Node.js + Express**

**Why:**
- ✅ JavaScript everywhere (same as frontend)
- ✅ Fast to develop
- ✅ Good for I/O operations
- ✅ Large ecosystem (npm)
- ✅ Easy to find developers

**Alternative: Python + FastAPI**
- Modern and fast
- Great for AI integration (Phase 2)
- Strong typing with Pydantic

### Database

**Use: PostgreSQL**

**Why:**
- ✅ Robust and reliable
- ✅ JSONB support (flexible data)
- ✅ Array support (tags, images)
- ✅ Full-text search built-in
- ✅ Free on Railway/Render

### Hosting

**Recommended: Railway or Render**

**Why:**
- ✅ Easiest deployment
- ✅ Managed PostgreSQL included
- ✅ Auto-deploy from Git
- ✅ Low cost ($20-30/month)
- ✅ No DevOps needed

**Alternative: DigitalOcean App Platform**
- More control
- Similar ease of use

**Skip for MVP: AWS, GCP, Azure**
- Too complex for MVP
- Higher costs
- Requires DevOps expertise

---

## Migration Strategy

### Moving from Phase 1 to Phase 2

**Steps:**
1. Add `video_imports` table (migration)
2. Set up Redis or pg-boss queue
3. Create worker process
4. Integrate video APIs
5. Integrate AI services (OpenAI)
6. Deploy worker alongside API
7. Test thoroughly
8. Launch video import feature

**Estimated time:** 4 weeks

### Moving from Phase 2 to Phase 3

**When performance issues arise:**

1. **First**: Add Redis caching
   - Start with most-accessed endpoints
   - Monitor cache hit rates
   - Expand gradually

2. **Second**: Add read replicas
   - For reporting/analytics queries
   - Split reads from writes in code

3. **Third**: Add load balancer
   - When single server maxes out
   - Use cloud provider's load balancer

4. **Last**: Consider microservices
   - Only if team size justifies it
   - Start with video/AI service
   - Keep others monolithic

---

## Getting Started with Chosen Stack

### Prerequisites

**Install the following:**

1. **Flutter** (3.16+)
   ```bash
   # macOS
   brew install --cask flutter
   
   # Verify installation
   flutter doctor
   ```

2. **Python** (3.11+)
   ```bash
   # macOS
   brew install python@3.11
   
   # Verify
   python3 --version
   ```

3. **PostgreSQL** (15+)
   ```bash
   # macOS
   brew install postgresql@15
   
   # Or use managed service (Railway/Render)
   ```

4. **IDE Setup**
   - **For Flutter**: VS Code with Flutter extension OR Android Studio
   - **For Python**: VS Code with Python extension OR PyCharm

### Quick Start Guide

#### 1. Create Flutter App

```bash
# Create new Flutter project
flutter create recipe_app
cd recipe_app

# Add dependencies
flutter pub add dio provider http flutter_secure_storage

# Run on iOS simulator
flutter run -d "iPhone 15 Pro"

# Run on Android emulator
flutter run -d emulator-5554
```

#### 2. Set Up FastAPI Backend

```bash
# Create backend folder
mkdir backend
cd backend

# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install fastapi uvicorn sqlalchemy psycopg2-binary alembic python-jose[cryptography] passlib[bcrypt] python-multipart cloudinary pydantic-settings

# Create requirements.txt
pip freeze > requirements.txt

# Create project structure
mkdir -p app/api app/models app/schemas app/services app/core
touch app/__init__.py app/main.py
touch app/core/__init__.py app/core/config.py app/core/security.py app/core/database.py

# Run development server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

#### 3. Create PostgreSQL Database

**Option A: Local Development**
```bash
# Create database
createdb recipe_db

# Connection string
DATABASE_URL=postgresql://username:password@localhost:5432/recipe_db
```

**Option B: Railway (Recommended)**
```bash
# 1. Sign up at railway.app
# 2. Create new project
# 3. Add PostgreSQL service
# 4. Copy connection string from Railway dashboard
```

#### 4. Initialize Database with Alembic

```bash
# In backend folder
alembic init alembic

# Edit alembic.ini - set sqlalchemy.url
# Or use env variable in alembic/env.py

# Create first migration
alembic revision --autogenerate -m "Initial tables"

# Apply migration
alembic upgrade head
```

#### 5. Basic FastAPI Setup

**`backend/app/main.py`:**
```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="Recipe Organizer API", version="1.0.0")

# CORS for Flutter app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Update with your Flutter app URL
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def read_root():
    return {"message": "Recipe API is running"}

@app.get("/health")
def health_check():
    return {"status": "healthy"}
```

#### 6. Connect Flutter to FastAPI

**`mobile/lib/services/api_service.dart`:**
```dart
import 'package:dio/dio.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000'; // Update for production
  final Dio _dio = Dio(BaseOptions(baseUrl: baseUrl));

  Future<Map<String, dynamic>> getHealth() async {
    try {
      final response = await _dio.get('/health');
      return response.data;
    } catch (e) {
      throw Exception('Failed to connect to API: $e');
    }
  }
}
```

#### 7. Test the Connection

**Terminal 1 - Run FastAPI:**
```bash
cd backend
source venv/bin/activate
uvicorn app.main:app --reload
```

**Terminal 2 - Run Flutter:**
```bash
cd mobile
flutter run
```

**Visit:**
- API: http://localhost:8000
- API Docs: http://localhost:8000/docs (automatic Swagger UI)
- Mobile app: iOS Simulator or Android Emulator

### Project Structure Reference

```
recipe-app/
├── mobile/                         # Flutter app
│   ├── lib/
│   │   ├── main.dart
│   │   ├── screens/
│   │   ├── widgets/
│   │   ├── models/
│   │   ├── services/
│   │   │   └── api_service.dart
│   │   └── providers/
│   ├── assets/
│   └── pubspec.yaml
│
├── backend/                        # FastAPI backend
│   ├── app/
│   │   ├── __init__.py
│   │   ├── main.py
│   │   ├── api/                   # API routes
│   │   │   ├── __init__.py
│   │   │   ├── auth.py
│   │   │   ├── recipes.py
│   │   │   ├── categories.py
│   │   │   ├── meal_plans.py
│   │   │   └── shopping_lists.py
│   │   ├── models/                # SQLAlchemy models
│   │   │   ├── __init__.py
│   │   │   ├── user.py
│   │   │   ├── recipe.py
│   │   │   └── ...
│   │   ├── schemas/               # Pydantic schemas
│   │   │   ├── __init__.py
│   │   │   ├── user.py
│   │   │   ├── recipe.py
│   │   │   └── ...
│   │   ├── services/              # Business logic
│   │   │   ├── __init__.py
│   │   │   ├── auth_service.py
│   │   │   └── recipe_service.py
│   │   └── core/                  # Config & utilities
│   │       ├── __init__.py
│   │       ├── config.py         # Settings
│   │       ├── security.py       # JWT, passwords
│   │       └── database.py       # DB connection
│   ├── alembic/                   # Migrations
│   │   ├── versions/
│   │   └── env.py
│   ├── requirements.txt
│   ├── .env
│   └── README.md
│
├── .gitignore
└── README.md
```

### Essential Environment Variables

**`backend/.env`:**
```env
DATABASE_URL=postgresql://user:pass@localhost:5432/recipe_db
SECRET_KEY=your-secret-key-here-use-openssl-rand-hex-32
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
```

### Helpful Commands

```bash
# Flutter
flutter clean               # Clean build
flutter pub get            # Install dependencies
flutter pub upgrade        # Update dependencies
flutter doctor             # Check setup

# FastAPI
pip install -r requirements.txt    # Install dependencies
alembic upgrade head              # Run migrations
alembic revision --autogenerate   # Create migration
uvicorn app.main:app --reload     # Run dev server

# Database
psql recipe_db                    # Connect to local DB
\dt                               # List tables
\d users                          # Describe table
```

### Next Steps

1. ✅ Set up development environment
2. ✅ Create Flutter & FastAPI projects
3. ✅ Connect to PostgreSQL
4. 📝 Implement database models (see `04-database-schema.md`)
5. 📝 Build authentication endpoints (see `03-sequence-diagrams.md`)
6. 📝 Create UI screens (see `07-figma-design-reference.md`)
7. 📝 Implement recipe CRUD operations
8. 📝 Build meal planning features
9. 📝 Add shopping list generation

---

## Key Takeaways

### ✅ DO for MVP (Phase 1)

- Build monolithic backend
- Use managed services (Railway/Render)
- Single PostgreSQL database
- No caching, no load balancer
- Focus on features, not infrastructure
- Deploy early and often

### ❌ DON'T for MVP

- Don't implement video features yet
- Don't add caching
- Don't use microservices
- Don't add load balancer
- Don't optimize prematurely
- Don't over-engineer

### ⏳ ADD in Phase 2

- Background worker for video processing
- Job queue (Redis or pg-boss)
- Video API integrations
- AI/ML services (transcription, parsing)

### 🚀 SCALE in Phase 3

- Add caching when database struggles
- Add read replicas when read-heavy
- Add CDN when global users
- Add load balancer when single server insufficient
- Consider microservices only when team justifies it

---

## Summary

| Phase | Features | Architecture | Cost/Month | Timeline |
|-------|----------|--------------|------------|----------|
| **Phase 1 (MVP)** | Core recipe app | Monolith + PostgreSQL | $20-45 | 8 weeks |
| **Phase 2 (AI)** | + Video import | + Worker + Queue | $105-155 | +4 weeks |
| **Phase 3 (Scale)** | + Performance | + Cache + Replicas | $700-1,400 | As needed |

**Start with Phase 1. Build a working recipe app without AI. Validate your idea. Then add complexity when you need it.**

**The goal: Ship fast, learn from users, scale based on actual needs.**

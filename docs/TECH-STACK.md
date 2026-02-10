# Tech Stack - Recipe and Shopping Organizer

## ✅ Final Decision

**Chosen Stack:** Flutter + FastAPI + PostgreSQL

---

## 📱 Frontend: Flutter

**Why Flutter?**
- ✅ Single codebase for iOS & Android
- ✅ Beautiful, native-looking UI components
- ✅ Excellent performance (compiled to native code)
- ✅ Hot reload for rapid development
- ✅ Large community and package ecosystem
- ✅ Strong typing with Dart language
- ✅ Perfect for mobile-first apps

**Key Packages:**
```yaml
dependencies:
  dio: ^5.4.0              # HTTP client
  provider: ^6.1.1         # State management
  flutter_secure_storage:  # Secure token storage
  cached_network_image:    # Image caching
  intl:                    # Internationalization
```

**Development Tools:**
- IDE: VS Code with Flutter extension or Android Studio
- State Management: Provider or Riverpod
- Navigation: go_router
- Local Storage: Hive or SQLite

---

## 🔧 Backend: FastAPI (Python 3.11+)

**Why FastAPI?**
- ✅ Modern, fast async web framework
- ✅ Automatic interactive API documentation (Swagger UI)
- ✅ Type hints with Pydantic for data validation
- ✅ Excellent async support (important for Phase 2 video processing)
- ✅ Easy to learn and develop with
- ✅ Production-ready with great performance
- ✅ Perfect for building REST APIs for mobile apps

**Key Libraries:**
```
fastapi==0.109.0          # Web framework
uvicorn==0.27.0           # ASGI server
sqlalchemy==2.0.25        # ORM
psycopg2-binary==2.9.9    # PostgreSQL driver
alembic==1.13.1           # Database migrations
pydantic==2.6.0           # Data validation
python-jose[cryptography] # JWT tokens
passlib[bcrypt]           # Password hashing
python-multipart          # File uploads
cloudinary                # Image storage
```

**Project Structure:**
```
backend/
├── app/
│   ├── main.py           # FastAPI app entry point
│   ├── api/              # API route handlers
│   ├── models/           # SQLAlchemy models
│   ├── schemas/          # Pydantic schemas
│   ├── services/         # Business logic
│   └── core/             # Config, security, DB
├── alembic/              # Database migrations
└── requirements.txt      # Dependencies
```

---

## 🗄️ Database: PostgreSQL 15+

**Why PostgreSQL?**
- ✅ Robust and reliable relational database
- ✅ Perfect for recipe data with complex relationships
- ✅ JSON/JSONB support for flexible data
- ✅ Array types for tags, images
- ✅ Full-text search capabilities
- ✅ Excellent community and documentation
- ✅ Free on Railway/Render

**ORM:** SQLAlchemy 2.0 (async support)  
**Migrations:** Alembic

---

## ☁️ Infrastructure

### Hosting: Railway or Render

**Railway (Recommended for MVP):**
- Easy deployment from GitHub
- Managed PostgreSQL included
- Simple environment variable management
- ~$10-30/month for starter plan
- One-click deployments

**Render (Alternative):**
- Similar features to Railway
- Free tier available
- Managed PostgreSQL
- Automatic deployments

### Storage: Cloudinary

**Why Cloudinary?**
- Free tier: 25 GB storage, 25 GB bandwidth
- Built-in image optimization and transformations
- CDN included
- Easy API integration
- Upload widget for Flutter
- Automatic format conversion (WebP, etc.)

**Alternative:** AWS S3 (more control, pay-as-you-go)

---

## 🔐 Authentication

**Method:** JWT (JSON Web Tokens)

**Implementation:**
- `python-jose` for JWT creation/validation
- `bcrypt` for password hashing
- Token storage in Flutter: `flutter_secure_storage`
- Token expiration: 30 minutes (access), 7 days (refresh)

---

## 📧 Additional Services

| Service | Purpose | Free Tier | Cost |
|---------|---------|-----------|------|
| **SendGrid** | Email notifications | 100/day | Free |
| **Firebase Cloud Messaging** | Push notifications | Unlimited | Free |
| **Sentry** | Error tracking | 5k errors/month | Free |
| **Google Analytics** | Usage analytics | Basic features | Free |

---

## 💰 Estimated Costs

### Phase 1 (MVP - No AI/Video)
- Railway Hosting: $10-30/month
- PostgreSQL: Included
- Cloudinary: Free tier
- Other services: Free tiers
- **Total: $10-30/month**

### Phase 2 (+ AI/Video Processing)
- Railway: $30-50/month
- AssemblyAI (transcription): ~$15/month (50 videos)
- OpenAI API (parsing): ~$10/month
- Storage increase: +$10/month
- **Total: $65-85/month**

### Phase 3 (Scaling)
- Upgrade hosting: $100-200/month
- Redis caching: $10-20/month
- CDN: $20-50/month
- Monitoring: $20-50/month
- **Total: $150-320/month** (for 1000+ active users)

---

## 📦 Development Environment Setup

### Prerequisites

1. **Flutter SDK** (3.16+)
   ```bash
   brew install --cask flutter
   flutter doctor
   ```

2. **Python** (3.11+)
   ```bash
   brew install python@3.11
   python3 --version
   ```

3. **PostgreSQL** (15+)
   ```bash
   brew install postgresql@15
   # Or use Railway/Render managed database
   ```

4. **IDE**
   - VS Code with Flutter + Python extensions
   - OR Android Studio + PyCharm

### Quick Start

```bash
# 1. Create Flutter app
flutter create recipe_app
cd recipe_app

# 2. Create FastAPI backend
mkdir backend
cd backend
python3 -m venv venv
source venv/bin/activate
pip install fastapi uvicorn sqlalchemy psycopg2-binary

# 3. Run both
# Terminal 1:
cd backend && uvicorn app.main:app --reload

# Terminal 2:
cd mobile && flutter run
```

---

## 📚 Documentation References

- **Architecture & Setup**: See `docs/05-architecture.md`
- **Database Schema**: See `docs/04-database-schema.md`
- **API Flows**: See `docs/03-sequence-diagrams.md`
- **UI Design**: See `docs/07-figma-design-reference.md`

---

## 🚀 Development Phases

### Phase 1: MVP (8 weeks) - No AI/Video
- User authentication
- Recipe CRUD
- Categories
- Meal planning
- Shopping list generation
- **Stack:** Flutter + FastAPI + PostgreSQL

### Phase 2: AI Features (4 weeks)
- Video import
- Transcription (AssemblyAI)
- Recipe parsing (OpenAI)
- Background processing
- **Add:** Celery/RQ + Redis

### Phase 3: Scaling (As needed)
- Performance optimization
- Caching layer
- Load balancing
- CDN integration
- **Add:** Redis Cache, Read Replicas, Load Balancer

---

## 🎯 Why This Stack is Perfect for This Project

1. **Mobile-First**: Flutter provides excellent mobile UX
2. **Fast Development**: Both Flutter and FastAPI enable rapid prototyping
3. **Type Safety**: Dart and Python type hints reduce bugs
4. **API Documentation**: FastAPI generates interactive docs automatically
5. **Scalability**: PostgreSQL and FastAPI handle growth well
6. **Cost-Effective**: Low initial costs with Railway + free tiers
7. **Modern**: Latest best practices and patterns
8. **Community**: Large communities for support and packages
9. **Future-Ready**: Async support for video processing in Phase 2
10. **Developer-Friendly**: Clean, readable code in both Flutter and Python

---

## 📖 Learning Resources

### Flutter
- Official Docs: https://docs.flutter.dev
- Flutter Cookbook: https://docs.flutter.dev/cookbook
- Packages: https://pub.dev

### FastAPI
- Official Docs: https://fastapi.tiangolo.com
- Tutorial: https://fastapi.tiangolo.com/tutorial/
- SQLAlchemy Docs: https://docs.sqlalchemy.org

### PostgreSQL
- Official Docs: https://www.postgresql.org/docs/
- SQLAlchemy + PostgreSQL: https://docs.sqlalchemy.org/en/20/dialects/postgresql.html

---

## ✅ Next Steps

1. ✅ Tech stack chosen
2. 📝 Set up development environment
3. 📝 Create project structure
4. 📝 Implement authentication
5. 📝 Build recipe CRUD
6. 📝 Create UI screens
7. 📝 Add meal planning
8. 📝 Implement shopping lists
9. 📝 Deploy MVP
10. 📝 Add AI features (Phase 2)

---

**Ready to start building!** 🚀

See `docs/05-architecture.md` for detailed setup instructions.

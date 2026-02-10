# Quick Start Guide - Recipe & Shopping Organizer

## 🚀 Start the Application

### 1. Start Backend (Terminal 1)

```bash
cd apps/backend
docker-compose up -d
python create_admin.py
```

**Admin Credentials:**
- Username: `admin`
- Email: `admin@example.com`
- Password: `admin123!`

**Backend URLs:**
- API: http://localhost:8000
- Admin Panel: http://localhost:8000/admin
- API Docs: http://localhost:8000/docs

### 2. Create Test Data

**Option A: Using Admin Panel**
1. Go to http://localhost:8000/admin
2. Login with admin credentials
3. Create categories (e.g., "Desserts 🍰", "Main Dishes 🍽️", "Soups 🍲")
4. Create sample recipes with ingredients and preparation steps

**Option B: Using API (curl)**

Create a category:
```bash
curl -X POST http://localhost:8000/api/v1/categories \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "name": "Desserts",
    "emoji": "🍰",
    "description": "Sweet treats and desserts",
    "color": "#FF6B6B"
  }'
```

Create a recipe:
```bash
curl -X POST http://localhost:8000/api/v1/recipes \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "title": "Chocolate Chip Cookies",
    "category_id": "CATEGORY_UUID_HERE",
    "prep_time_minutes": 15,
    "cook_time_minutes": 12,
    "servings": 24,
    "tags": ["dessert", "cookies", "chocolate"],
    "ingredients": [
      {"name": "flour", "quantity": "2", "unit": "cups", "display_order": 1},
      {"name": "sugar", "quantity": "1", "unit": "cup", "display_order": 2},
      {"name": "chocolate chips", "quantity": "2", "unit": "cups", "display_order": 3}
    ],
    "preparation_steps": [
      {"step_number": 1, "instruction": "Preheat oven to 350°F", "duration_minutes": 2},
      {"step_number": 2, "instruction": "Mix dry ingredients", "duration_minutes": 3},
      {"step_number": 3, "instruction": "Add wet ingredients and mix", "duration_minutes": 5},
      {"step_number": 4, "instruction": "Bake for 12 minutes", "duration_minutes": 12}
    ]
  }'
```

### 3. Run Flutter App (Terminal 2)

**For iOS Simulator:**
```bash
cd apps/mobile
flutter run
```

**For Android Emulator:**
First, update the API base URL in `apps/mobile/lib/core/constants/app_constants.dart`:
```dart
static const String apiBaseUrl = 'http://10.0.2.2:8000';
```

Then run:
```bash
cd apps/mobile
flutter run
```

**For Physical Device:**
1. Find your computer's IP address:
   ```bash
   # On macOS
   ifconfig | grep "inet " | grep -v 127.0.0.1
   
   # On Linux
   hostname -I
   
   # On Windows
   ipconfig
   ```

2. Update API base URL in `apps/mobile/lib/core/constants/app_constants.dart`:
   ```dart
   static const String apiBaseUrl = 'http://YOUR_IP:8000';
   ```

3. Make sure your phone and computer are on the same WiFi network

4. Run:
   ```bash
   cd apps/mobile
   flutter run
   ```

## 📱 Using the App

### First Time Setup
1. **Register**: Create a new account or login with admin credentials
2. **Explore**: Browse recipes on the home screen
3. **Filter**: Use category chips to filter recipes
4. **Details**: Tap any recipe to view full details
5. **Favorite**: Toggle favorite on recipes you like

### Main Features

#### Home Screen
- User profile card
- Quick access tiles:
  - **Recipes**: View all recipes
  - **New Recipe**: Create recipe (coming soon)
  - **Favorites**: View favorite recipes
  - **Settings**: App settings

#### Recipe List
- **All Recipes Tab**: Public recipes from all users
- **My Recipes Tab**: Only your recipes
- **Category Filter**: Filter by category (horizontal scroll)
- **Pull to Refresh**: Swipe down to refresh
- **Grid View**: Beautiful recipe cards with images

#### Recipe Detail
- **Full Image**: Expanding header with recipe image
- **Metadata**: Prep time, cook time, servings
- **Tags**: Visual tags for quick reference
- **Ingredients**: Bulleted list with quantities
- **Steps**: Numbered preparation instructions
- **Favorite**: Heart icon to toggle favorite
- **Actions**: Edit/Delete via menu (top right)

## 🔧 Troubleshooting

### Backend Issues

**Port already in use:**
```bash
docker-compose down
lsof -ti:8000 | xargs kill -9
docker-compose up -d
```

**Database reset:**
```bash
docker-compose down -v
docker-compose up -d
python create_admin.py
```

**View logs:**
```bash
docker-compose logs -f backend
```

### Flutter Issues

**Build errors:**
```bash
cd apps/mobile
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

**Can't connect to backend:**
1. Check API base URL in `app_constants.dart`
2. Verify backend is running: `curl http://localhost:8000/api/v1/health`
3. For Android, use `10.0.2.2` instead of `localhost`
4. For physical devices, use computer's IP address

**App crashes on start:**
1. Check console for errors
2. Verify all dependencies are installed: `flutter pub get`
3. Try running in debug mode: `flutter run --debug`

## 📊 Test Scenarios

### Basic Flow
1. ✅ Register new user
2. ✅ Login with credentials
3. ✅ View recipe list
4. ✅ Filter by category
5. ✅ View recipe details
6. ✅ Toggle favorite
7. ✅ Delete recipe (if owner)
8. ✅ Logout

### Edge Cases
- Empty recipe list
- No internet connection
- Invalid credentials
- Recipe without image
- Recipe without ingredients/steps

## 🎯 What's Working

✅ User registration and login  
✅ JWT authentication  
✅ Recipe list viewing  
✅ Recipe detail viewing  
✅ Category filtering  
✅ Favorite toggling  
✅ Recipe deletion  
✅ Pull to refresh  
✅ Light/Dark theme  

## 🚧 What's Next

⏳ Recipe creation form  
⏳ Recipe editing  
⏳ Image upload  
⏳ Search functionality  
⏳ Shopping list generation  
⏳ Meal planning  

## 🆘 Need Help?

**Check logs:**
- Backend: `docker-compose logs -f backend`
- Frontend: Check Flutter console output

**API Documentation:**
- Interactive API docs: http://localhost:8000/docs
- Admin panel: http://localhost:8000/admin

**Common Commands:**
```bash
# Backend
docker-compose restart backend
docker-compose logs -f backend
python create_admin.py

# Frontend
flutter doctor
flutter clean && flutter pub get
flutter run --verbose
```

## 🎉 You're Ready!

The app should now be running with a beautiful UI connected to your backend. Create some recipes via the admin panel and start exploring the mobile app!

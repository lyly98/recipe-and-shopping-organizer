# Flutter UI Implementation Plan

## Overview
This document outlines the implementation plan for the Recipe & Shopping Organizer mobile app using Flutter with Clean Architecture and Riverpod.

## Current Status

### ✅ What's Already There (From Boilerplate)
- Flutter Riverpod Clean Architecture structure
- Auth screens (Login/Register) with mock implementation
- Routing with GoRouter
- Theme management (light/dark mode)
- Localization support
- Network layer with Dio
- Error handling
- Storage with SharedPreferences

### 🎯 What Needs to be Built

## 1. Update Authentication (Connect to Real Backend)

### Files to Update:
- `lib/features/auth/data/datasources/auth_remote_data_source.dart`
  - Replace mock login/register with real API calls
  - Endpoints: `POST /api/v1/login`, `POST /api/v1/user`
  
- `lib/features/auth/data/models/user_model.dart`
  - Update to match backend UserRead schema
  - Add: `id`, `username`, `profile_image_url`

- `lib/core/storage/token_storage.dart` (Create)
  - Store JWT token securely using flutter_secure_storage
  - Provide token for authenticated requests

## 2. Create Recipe Feature (Full Clean Architecture)

### 2.1 Domain Layer (`lib/features/recipe/domain/`)

**Entities:**
- `recipe_entity.dart` - Core recipe data model
- `category_entity.dart` - Category data model
- `ingredient_entity.dart` - Ingredient data model
- `preparation_step_entity.dart` - Cooking step data model

**Repositories (Interfaces):**
- `recipe_repository.dart` - Recipe CRUD operations interface
- `category_repository.dart` - Category operations interface

**Use Cases:**
- `get_recipes_use_case.dart` - Fetch recipe list
- `get_recipe_detail_use_case.dart` - Fetch single recipe
- `create_recipe_use_case.dart` - Create new recipe
- `update_recipe_use_case.dart` - Update existing recipe
- `delete_recipe_use_case.dart` - Delete recipe
- `get_categories_use_case.dart` - Fetch categories
- `toggle_favorite_use_case.dart` - Toggle favorite status

### 2.2 Data Layer (`lib/features/recipe/data/`)

**Models:**
- `recipe_model.dart` + `recipe_model.g.dart` (json_serializable)
- `category_model.dart` + `category_model.g.dart`
- `ingredient_model.dart` + `ingredient_model.g.dart`
- `preparation_step_model.dart` + `preparation_step_model.g.dart`

**Data Sources:**
- `recipe_remote_data_source.dart`
  - Endpoints:
    - `GET /api/v1/recipes` - List recipes
    - `GET /api/v1/recipes/{id}` - Get recipe detail
    - `POST /api/v1/recipes` - Create recipe
    - `PATCH /api/v1/recipes/{id}` - Update recipe
    - `DELETE /api/v1/recipes/{id}` - Delete recipe
    - `POST /api/v1/recipes/{id}/favorite` - Toggle favorite
    
- `category_remote_data_source.dart`
  - Endpoints:
    - `GET /api/v1/categories` - List categories
    - `POST /api/v1/categories` - Create category

**Repositories (Implementation):**
- `recipe_repository_impl.dart` - Implements recipe_repository interface
- `category_repository_impl.dart` - Implements category_repository interface

### 2.3 Presentation Layer (`lib/features/recipe/presentation/`)

**Providers (`providers/`):**
- `recipe_providers.dart` - Recipe state management
- `category_providers.dart` - Category state management
- `recipe_form_provider.dart` - Form state for create/edit

**Screens (`screens/`):**

1. **RecipeListScreen** (`recipe_list_screen.dart`)
   - Shows grid/list of recipes
   - Filter by category
   - Search functionality
   - Pull to refresh
   - Floating action button to create new recipe
   - Navigate to detail on tap

2. **RecipeDetailScreen** (`recipe_detail_screen.dart`)
   - Recipe header (image, title, category)
   - Metadata (prep time, cook time, servings)
   - Ingredients list
   - Preparation steps with checkboxes
   - Edit/Delete buttons (for owned recipes)
   - Favorite button

3. **RecipeFormScreen** (`recipe_form_screen.dart`)
   - Multi-step form or single scrollable form
   - Basic info (title, category, times, servings)
   - Image upload (Cloudinary integration - Phase 2)
   - Ingredients section (add/remove/reorder)
   - Preparation steps section (add/remove/reorder)
   - Save button

4. **CategorySelectionScreen** (`category_selection_screen.dart`)
   - Grid of categories with icons/colors
   - Create new category option

**Widgets (`widgets/`):**
- `recipe_card.dart` - Recipe card for list view
- `category_chip.dart` - Category filter chip
- `ingredient_tile.dart` - Ingredient list item (with checkbox)
- `preparation_step_tile.dart` - Step item with number
- `recipe_image.dart` - Recipe image with placeholder
- `time_display.dart` - Prep/cook time display widget

## 3. Update Home Screen

### File: `lib/features/home/presentation/screens/home_screen.dart`
- Remove boilerplate examples
- Show recipe categories as horizontal scroll
- Show featured/recent recipes
- Quick actions: Create recipe, view all recipes
- Navigate to recipe list on category tap

## 4. Update Routing

### File: `lib/core/router/app_router.dart`
Add routes:
- `/recipes` - RecipeListScreen
- `/recipes/:id` - RecipeDetailScreen
- `/recipes/create` - RecipeFormScreen (create mode)
- `/recipes/:id/edit` - RecipeFormScreen (edit mode)
- `/categories` - CategorySelectionScreen

## 5. Core Updates

### API Configuration
- Update `lib/core/constants/app_constants.dart`
  - Ensure `apiBaseUrl` points to `http://localhost:8000` (or 10.0.2.2 for Android)

### Interceptors
- Create `lib/core/network/auth_interceptor.dart`
  - Add JWT token to all authenticated requests
  - Handle 401 (unauthorized) - logout user

### Error Handling
- Update `lib/core/error/failures.dart`
  - Add recipe-specific failures if needed

## 6. Dependencies to Add

Add to `pubspec.yaml`:
```yaml
dependencies:
  # Image handling (for future image upload)
  image_picker: ^1.0.7
  cached_network_image: ^3.3.1
  
  # Form handling
  flutter_form_builder: ^9.2.1
  
  # UI enhancements
  shimmer: ^3.0.0  # Loading skeletons
  flutter_slidable: ^3.0.1  # Swipe actions
```

## Implementation Priority

### Phase 1 (MVP - Current Sprint)
1. ✅ Update auth to connect to backend
2. ✅ Create recipe models and data sources
3. ✅ Implement recipe list screen
4. ✅ Implement recipe detail screen
5. ✅ Update home screen
6. ✅ Update routing

### Phase 2 (Next Sprint)
1. ⏳ Implement recipe creation form
2. ⏳ Add image upload (Cloudinary)
3. ⏳ Add search and advanced filtering
4. ⏳ Implement offline support with local database

### Phase 3 (Future)
1. ⏳ Shopping list generation
2. ⏳ Meal planning calendar
3. ⏳ Recipe sharing
4. ⏳ Video recipe import

## Testing Strategy

- Unit tests for use cases and repositories
- Widget tests for individual widgets
- Integration tests for full flows (auth, recipe creation)

## Notes

- Follow existing boilerplate patterns for consistency
- Use Riverpod's `AsyncNotifier` for async state management
- Implement proper error handling and loading states
- Add proper null safety checks
- Follow Material Design 3 guidelines
- Ensure proper accessibility (semantic labels, etc.)

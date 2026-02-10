# Requirements Specification

## 1. Introduction

### 1.1 Purpose

This document describes the functional and non-functional requirements for the Recipe and Shopping Organizer application, a mobile solution designed to help users manage recipes, plan meals, and generate shopping lists.

### 1.2 Scope

The application will provide:

- Recipe creation, storage, and categorization
- Video-based recipe import from social media platforms
- Weekly meal planning interface
- Automated grocery list generation
- Multi-user support with personal recipe collections

### 1.3 Target Users

- Home cooks who plan meals in advance
- Individuals who save recipes from social media
- Families managing weekly grocery shopping
- People seeking to organize their cooking routine

## 2. Functional Requirements

### 2.1 User Management

#### FR-1.1: User Registration

- Users shall be able to create an account with email/password
- System shall support OAuth authentication (Google, Apple, Facebook)
- Email verification shall be required

#### FR-1.2: User Authentication

- Users shall log in with credentials
- System shall maintain user sessions securely
- Password recovery mechanism shall be available

#### FR-1.3: User Profile

- Users shall manage profile information (name, preferences, dietary restrictions)
- Users shall set default serving sizes
- Users shall configure notification preferences

### 2.2 Recipe Management

#### FR-2.1: Create Recipe

- Users shall create recipes with the following fields:
  - Title (required)
  - Category (required, selectable from user's categories)
  - Meal type/usage (optional, e.g., "après pâté, chocolat cake")
  - Ingredients list (required, with quantities and units)
  - Preparation steps (required, multiple steps)
  - Preparation time
  - Cooking time
  - Servings count
  - Recipe image(s)
  - Tags/labels
- System shall support rich text formatting in preparation steps
- System shall auto-save drafts

#### FR-2.2: Edit Recipe

- Users shall modify existing recipes
- System shall maintain version history
- Changes shall be saved immediately or on confirmation

#### FR-2.3: Delete Recipe

- Users shall delete recipes
- System shall request confirmation before deletion
- Deleted recipes shall be moved to trash (recoverable for 30 days)

#### FR-2.4: View Recipe

- Users shall view full recipe details
- System shall display nutritional information (if available)
- Users shall scale recipe servings dynamically
- System shall show which meal plans use this recipe

#### FR-2.5: Search Recipes

- Users shall search recipes by title, ingredients, or tags
- System shall provide autocomplete suggestions
- Search shall work across all user's recipes

#### FR-2.6: Filter Recipes

- Users shall filter by category
- Users shall filter by meal type (breakfast, lunch, dinner, snack)
- Users shall filter by preparation time
- Users shall filter by dietary restrictions

### 2.3 Category Management

#### FR-3.1: Create Category

- Users shall create custom categories with:
  - Category name (required)
  - Category emoji/icon (optional)
  - Category color (optional)
- Default categories shall be provided: Plats, Pains, Desserts, Jus, Snacks, Soupes

#### FR-3.2: Edit Category

- Users shall rename categories
- Users shall change category icons/emojis
- System shall update all associated recipes

#### FR-3.3: Delete Category

- Users shall delete categories
- System shall prompt for action on associated recipes:
  - Move to another category
  - Move to "Uncategorized"
  - Delete recipes (with confirmation)

#### FR-3.4: View Recipes by Category

- Users shall view all recipes in a category as a grid
- System shall display recipe count per category
- Categories shall be displayed as cards with emojis

### 2.4 Video Recipe Import

#### FR-4.1: Import from Video URL

- Users shall paste video URLs from supported platforms:
  - TikTok
  - Instagram (Reels, posts)
  - YouTube
  - Facebook
- System shall validate URL format

#### FR-4.2: Video Processing

- System shall extract video metadata (title, description, captions)
- System shall transcribe video audio (if available)
- System shall extract visible text from video frames (OCR)
- System shall identify recipe components using AI/ML

#### FR-4.3: Recipe Population

- System shall auto-populate recipe fields from video content:
  - Title
  - Ingredients (parsed from text/audio)
  - Preparation steps
  - Recipe image (thumbnail or frame capture)
- Users shall review and edit extracted information before saving

#### FR-4.4: Platform Suggestions

- System shall display suggested platforms (TikTok, Instagram, YouTube, Facebook)
- Users shall select platform for optimized parsing

### 2.5 Meal Planning

#### FR-5.1: Weekly View

- Users shall view meal planning calendar for current week
- System shall display 7 days (configurable start day)
- Each day shall have configurable meal slots (default: 2-4 slots)

#### FR-5.2: Add Recipe to Meal Plan

- Users shall add recipes to specific meal slots via:
  - Selecting from recipe list
  - Dragging and dropping
  - Searching recipes
- System shall support multiple recipes per meal slot

#### FR-5.3: Edit Meal Plan

- Users shall remove recipes from meal slots
- Users shall move recipes between slots
- Users shall copy meals to other days

#### FR-5.4: View Meal Details

- Users shall view recipe details from meal plan (tooltip/modal)
- Tooltip shall show:
  - Recipe title and image
  - Category
  - Ingredients preview
  - Preparation steps preview
  - Servings

#### FR-5.5: Navigate Weeks

- Users shall navigate to previous/next weeks
- System shall save meal plans indefinitely
- Users shall jump to specific date

#### FR-5.6: Repeat Meal Plans

- Users shall duplicate entire week to another week
- Users shall create meal plan templates

### 2.6 Grocery Shopping List

#### FR-6.1: Generate Shopping List

- System shall generate shopping list from current week's meal plan
- Users shall specify number of servings/people
- System shall aggregate identical ingredients
- System shall organize ingredients by category/aisle

#### FR-6.2: Customize Shopping List

- Users shall add custom items manually
- Users shall remove items from generated list
- Users shall edit quantities
- System shall remember custom additions for future lists

#### FR-6.3: View Shopping List

- Users shall view consolidated shopping list
- System shall display:
  - Ingredient name
  - Total quantity needed
  - Unit of measurement
  - Which recipes require it
- List shall be organized by categories/sections

#### FR-6.4: Export Shopping List

- Users shall export list as:
  - Plain text
  - PDF
  - Email
  - Share via messaging apps
- System shall maintain formatting and grouping

#### FR-6.5: Check Off Items

- Users shall mark items as purchased
- System shall persist checked state during shopping session
- Users shall clear all checks after shopping

#### FR-6.6: Shopping List History

- System shall save previous shopping lists
- Users shall view past lists
- Users shall reuse past lists

### 2.7 Additional Features

#### FR-7.1: Recipe Sharing

- Users shall share recipes with other users
- System shall generate shareable recipe links
- Shared recipes shall be viewable without account (read-only)

#### FR-7.2: Recipe Import/Export

- Users shall export recipes to standard formats (JSON, PDF)
- Users shall import recipes from files

#### FR-7.3: Favorites

- Users shall mark recipes as favorites
- System shall provide quick access to favorite recipes

#### FR-7.4: Recipe Notes

- Users shall add personal notes to recipes
- Notes shall be private and editable

## 3. Non-Functional Requirements

### 3.1 Performance

#### NFR-1.1: Response Time

- Application screens shall load within 2 seconds on standard mobile connection
- Recipe search results shall appear within 1 second
- Video processing shall provide progress indication

#### NFR-1.2: Scalability

- System shall support 100,000+ concurrent users
- Database shall handle 1M+ recipes efficiently
- Video processing queue shall handle peak loads

### 3.2 Usability

#### NFR-2.1: User Interface

- Application shall follow platform design guidelines (iOS Human Interface Guidelines, Material Design)
- Interface shall be intuitive with minimal learning curve
- Application shall be accessible (WCAG 2.1 Level AA compliance)

#### NFR-2.2: Responsive Design

- Application shall adapt to different screen sizes (phones, tablets)
- UI shall support both portrait and landscape orientations

#### NFR-2.3: Internationalization

- Application shall support multiple languages (starting with French and English)
- Date, time, and number formats shall follow user's locale
- Unit measurements shall be configurable (metric/imperial)

### 3.3 Security

#### NFR-3.1: Data Protection

- User passwords shall be hashed using industry-standard algorithms (bcrypt, Argon2)
- Sensitive data shall be encrypted at rest and in transit (TLS 1.3)
- API endpoints shall use authentication tokens (JWT, OAuth2)

#### NFR-3.2: Privacy

- User data shall not be shared with third parties without consent
- System shall comply with GDPR and relevant privacy regulations
- Users shall be able to export or delete all their data

#### NFR-3.3: Authorization

- Users shall only access their own recipes and data
- Shared recipes shall have proper access controls
- Administrative functions shall require elevated permissions

### 3.4 Reliability

#### NFR-4.1: Availability

- System shall maintain 99.5% uptime
- Planned maintenance shall be scheduled during low-traffic periods
- System shall have automated backups every 24 hours

#### NFR-4.2: Error Handling

- Application shall handle errors gracefully with user-friendly messages
- System shall log errors for debugging
- Critical errors shall trigger notifications to administrators

#### NFR-4.3: Data Integrity

- System shall prevent data loss during operations
- Transactions shall be atomic (all-or-nothing)
- Database shall maintain referential integrity

### 3.5 Compatibility

#### NFR-5.1: Platform Support

- Application shall support iOS 14+ and Android 10+
- Web version shall support modern browsers (Chrome, Safari, Firefox, Edge) - last 2 versions

#### NFR-5.2: Device Support

- Application shall work on devices with minimum 2GB RAM
- Application shall support offline mode for viewing saved recipes and meal plans

### 3.6 Maintainability

#### NFR-6.1: Code Quality

- Code shall follow established coding standards
- Code coverage shall be minimum 70%
- Documentation shall be maintained alongside code

#### NFR-6.2: Logging and Monitoring

- System shall log all critical operations
- Monitoring shall track system health and performance metrics
- Analytics shall track user behavior and feature usage

### 3.7 Legal and Compliance

#### NFR-7.1: Content Rights

- System shall respect copyright for imported video content
- Users shall be responsible for content they import
- Terms of service shall clarify usage rights

#### NFR-7.2: Third-Party APIs

- Video platform integration shall comply with API terms of service
- System shall handle API rate limits gracefully

## 4. System Constraints

### 4.1 Technical Constraints

- Video processing requires external API or cloud services
- AI/ML for recipe extraction requires trained models or third-party services
- Mobile app size should not exceed 100MB (initial download)

### 4.2 Business Constraints

- Free tier with limitations (recipe count, features)
- Premium tier with advanced features
- API costs for video processing and transcription

### 4.3 Regulatory Constraints

- Must comply with data protection laws (GDPR, CCPA)
- Must comply with platform app store guidelines
- Must comply with accessibility standards

## 5. Assumptions and Dependencies

### 5.1 Assumptions

- Users have stable internet connection for video import
- Users grant necessary permissions (camera, storage)
- Video platforms maintain API access
- Target users are comfortable with mobile apps

### 5.2 Dependencies

- Third-party video transcription services (e.g., AWS Transcribe, Google Speech-to-Text)
- OCR services for text extraction from video
- Cloud storage for images and videos
- Push notification services (FCM, APNs)
- Analytics platform
- Payment processing (if premium features)

## 6. Future Enhancements

### 6.1 Planned Features

- Nutritional information calculation
- Recipe recommendations based on preferences and history
- Social features (follow users, public recipe collections)
- Integration with grocery delivery services
- Meal prep instructions and batch cooking support
- Voice-guided cooking mode
- Smart appliance integration
- Ingredient substitution suggestions
- Leftover management
- Budget tracking for groceries

### 6.2 Potential Integrations

- Fitness tracking apps (calorie tracking)
- Smart home devices (timers, reminders)
- Calendar apps (meal planning sync)
- Health apps (dietary goals, allergies)

## 7. Success Criteria

### 7.1 User Metrics

- 70% user retention after 30 days
- Average session duration > 5 minutes
- 50% of users create meal plans weekly
- 40% of users use video import feature monthly

### 7.2 Technical Metrics

- < 1% crash rate
- Average app rating > 4.2/5
- 95% successful video imports
- < 3 seconds average recipe search time

### 7.3 Business Metrics

- 10,000 active users within 6 months of launch
- 15% conversion rate to premium tier
- Positive user feedback and reviews

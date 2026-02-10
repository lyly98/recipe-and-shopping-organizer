# UML Diagrams

## 1. Use Case Diagram

### 1.1 Overview
This diagram illustrates the main interactions between users and the Recipe and Shopping Organizer system.

### 1.2 Mermaid Diagram

```mermaid
graph TB
    User((User))
    VideoAPI((Video Platform<br/>APIs))
    NotificationService((Notification<br/>Service))
    
    subgraph "Recipe and Shopping Organizer System"
        UC1[Manage Account]
        UC2[Create Recipe]
        UC3[Edit Recipe]
        UC4[Delete Recipe]
        UC5[Browse Recipes]
        UC6[Search Recipes]
        UC7[Manage Categories]
        UC8[Import Recipe from Video]
        UC9[Create Meal Plan]
        UC10[Edit Meal Plan]
        UC11[View Meal Plan]
        UC12[Generate Shopping List]
        UC13[Customize Shopping List]
        UC14[Export Shopping List]
        UC15[Share Recipe]
    end
    
    User --> UC1
    User --> UC2
    User --> UC3
    User --> UC4
    User --> UC5
    User --> UC6
    User --> UC7
    User --> UC8
    User --> UC9
    User --> UC10
    User --> UC11
    User --> UC12
    User --> UC13
    User --> UC14
    User --> UC15
    
    UC8 --> VideoAPI
    UC9 -.notify.-> NotificationService
    UC12 -.notify.-> NotificationService
    
    UC2 -.includes.-> UC7
    UC3 -.includes.-> UC7
    UC8 -.includes.-> UC2
    UC12 -.includes.-> UC11
```

### 1.3 Use Case Descriptions

#### UC1: Manage Account
- **Actor**: User
- **Description**: User registers, logs in, updates profile, manages preferences
- **Preconditions**: None for registration; account exists for other operations
- **Postconditions**: User account created/updated

#### UC2: Create Recipe
- **Actor**: User
- **Description**: User creates a new recipe with details, ingredients, and steps
- **Preconditions**: User is authenticated
- **Postconditions**: Recipe is saved in user's collection
- **Includes**: Manage Categories (optional)

#### UC3: Edit Recipe
- **Actor**: User
- **Description**: User modifies existing recipe information
- **Preconditions**: Recipe exists, user owns the recipe
- **Postconditions**: Recipe changes are saved

#### UC4: Delete Recipe
- **Actor**: User
- **Description**: User removes a recipe from their collection
- **Preconditions**: Recipe exists, user owns the recipe
- **Postconditions**: Recipe is moved to trash/deleted

#### UC5: Browse Recipes
- **Actor**: User
- **Description**: User views recipes by category or all recipes
- **Preconditions**: User is authenticated
- **Postconditions**: Recipes are displayed

#### UC6: Search Recipes
- **Actor**: User
- **Description**: User searches for recipes by keywords, ingredients, or tags
- **Preconditions**: User is authenticated
- **Postconditions**: Matching recipes are displayed

#### UC7: Manage Categories
- **Actor**: User
- **Description**: User creates, edits, or deletes recipe categories
- **Preconditions**: User is authenticated
- **Postconditions**: Categories are updated

#### UC8: Import Recipe from Video
- **Actor**: User
- **External System**: Video Platform APIs
- **Description**: User imports recipe by pasting video URL from social media
- **Preconditions**: User has valid video URL, platform API is accessible
- **Postconditions**: Recipe is extracted and saved

#### UC9: Create Meal Plan
- **Actor**: User
- **Description**: User assigns recipes to specific days and meal slots for the week
- **Preconditions**: User has recipes in collection
- **Postconditions**: Meal plan is saved

#### UC10: Edit Meal Plan
- **Actor**: User
- **Description**: User modifies existing meal plan entries
- **Preconditions**: Meal plan exists
- **Postconditions**: Meal plan changes are saved

#### UC11: View Meal Plan
- **Actor**: User
- **Description**: User views current or past meal plans
- **Preconditions**: User is authenticated
- **Postconditions**: Meal plan is displayed

#### UC12: Generate Shopping List
- **Actor**: User
- **Description**: System generates grocery list from weekly meal plan
- **Preconditions**: Meal plan exists with recipes
- **Postconditions**: Shopping list is created

#### UC13: Customize Shopping List
- **Actor**: User
- **Description**: User adds, removes, or edits items in shopping list
- **Preconditions**: Shopping list exists
- **Postconditions**: Shopping list is updated

#### UC14: Export Shopping List
- **Actor**: User
- **Description**: User exports shopping list as PDF, text, or shares it
- **Preconditions**: Shopping list exists
- **Postconditions**: List is exported/shared

#### UC15: Share Recipe
- **Actor**: User
- **Description**: User shares recipe with others via link or export
- **Preconditions**: Recipe exists
- **Postconditions**: Recipe is shared

## 2. Class Diagram

### 2.1 Overview
This diagram shows the main domain entities and their relationships.

### 2.2 Mermaid Diagram

```mermaid
classDiagram
    class User {
        +UUID id
        +String email
        +String passwordHash
        +String name
        +DateTime createdAt
        +DateTime updatedAt
        +UserPreferences preferences
        +register()
        +login()
        +updateProfile()
        +deleteAccount()
    }
    
    class UserPreferences {
        +UUID userId
        +String language
        +String unitSystem
        +Int defaultServings
        +DayOfWeek weekStartDay
        +Boolean notificationsEnabled
        +update()
    }
    
    class Category {
        +UUID id
        +UUID userId
        +String name
        +String emoji
        +String color
        +Int sortOrder
        +DateTime createdAt
        +create()
        +update()
        +delete()
    }
    
    class Recipe {
        +UUID id
        +UUID userId
        +UUID categoryId
        +String title
        +String mealUsage
        +Int prepTime
        +Int cookTime
        +Int servings
        +String[] images
        +String[] tags
        +DateTime createdAt
        +DateTime updatedAt
        +Boolean isFavorite
        +create()
        +update()
        +delete()
        +scale(newServings)
        +share()
    }
    
    class Ingredient {
        +UUID id
        +UUID recipeId
        +String name
        +Float quantity
        +String unit
        +Int sortOrder
        +Boolean isOptional
        +add()
        +update()
        +delete()
    }
    
    class PreparationStep {
        +UUID id
        +UUID recipeId
        +Int stepNumber
        +String instruction
        +Int durationMinutes
        +String imageUrl
        +add()
        +update()
        +delete()
        +reorder()
    }
    
    class MealPlan {
        +UUID id
        +UUID userId
        +Date weekStartDate
        +DateTime createdAt
        +DateTime updatedAt
        +create()
        +update()
        +delete()
        +duplicate()
    }
    
    class MealSlot {
        +UUID id
        +UUID mealPlanId
        +UUID recipeId
        +DayOfWeek dayOfWeek
        +MealType mealType
        +Int servings
        +String notes
        +add()
        +update()
        +remove()
    }
    
    class MealType {
        <<enumeration>>
        BREAKFAST
        LUNCH
        DINNER
        SNACK
    }
    
    class ShoppingList {
        +UUID id
        +UUID userId
        +UUID mealPlanId
        +Date generatedDate
        +Int servingsPeople
        +Boolean isCompleted
        +DateTime createdAt
        +generate()
        +export()
        +clear()
    }
    
    class ShoppingListItem {
        +UUID id
        +UUID shoppingListId
        +String name
        +Float quantity
        +String unit
        +String category
        +Boolean isChecked
        +Boolean isCustom
        +String[] sourceRecipes
        +add()
        +update()
        +check()
        +uncheck()
    }
    
    class VideoImport {
        +UUID id
        +UUID userId
        +UUID recipeId
        +String videoUrl
        +String platform
        +String status
        +String transcription
        +DateTime createdAt
        +import()
        +process()
        +extractRecipe()
    }
    
    class RecipeShare {
        +UUID id
        +UUID recipeId
        +UUID sharedByUserId
        +String shareToken
        +DateTime createdAt
        +DateTime expiresAt
        +Int viewCount
        +create()
        +revoke()
    }
    
    User "1" -- "1" UserPreferences
    User "1" -- "*" Category : owns
    User "1" -- "*" Recipe : owns
    User "1" -- "*" MealPlan : creates
    User "1" -- "*" ShoppingList : generates
    User "1" -- "*" VideoImport : initiates
    User "1" -- "*" RecipeShare : shares
    
    Category "1" -- "*" Recipe : contains
    
    Recipe "1" -- "*" Ingredient : has
    Recipe "1" -- "*" PreparationStep : contains
    Recipe "1" -- "*" MealSlot : appears in
    Recipe "1" -- "0..1" VideoImport : imported from
    Recipe "1" -- "*" RecipeShare : shared as
    
    MealPlan "1" -- "*" MealSlot : contains
    MealSlot "*" -- "1" MealType : is type of
    
    MealPlan "1" -- "0..1" ShoppingList : generates
    ShoppingList "1" -- "*" ShoppingListItem : contains
```

### 2.3 Key Relationships

- **User to Recipe**: One-to-Many (A user owns multiple recipes)
- **User to Category**: One-to-Many (A user creates multiple categories)
- **Category to Recipe**: One-to-Many (A category contains multiple recipes)
- **Recipe to Ingredient**: One-to-Many (A recipe has multiple ingredients)
- **Recipe to PreparationStep**: One-to-Many (A recipe has multiple steps)
- **User to MealPlan**: One-to-Many (A user creates multiple meal plans)
- **MealPlan to MealSlot**: One-to-Many (A meal plan has multiple meal slots)
- **Recipe to MealSlot**: One-to-Many (A recipe can appear in multiple meal slots)
- **MealPlan to ShoppingList**: One-to-One or One-to-Zero (A meal plan generates one shopping list)
- **ShoppingList to ShoppingListItem**: One-to-Many (A shopping list has multiple items)

## 3. Activity Diagram: Import Recipe from Video

### 3.1 Overview
This activity diagram shows the flow of importing a recipe from a video URL.

### 3.2 Mermaid Diagram

```mermaid
flowchart TD
    Start([User wants to import recipe]) --> Input[User pastes video URL]
    Input --> Validate{Valid URL?}
    
    Validate -->|No| ErrorMsg[Show error message]
    ErrorMsg --> Input
    
    Validate -->|Yes| Platform{Identify platform}
    Platform -->|TikTok| ProcessTikTok[Process TikTok video]
    Platform -->|Instagram| ProcessInsta[Process Instagram video]
    Platform -->|YouTube| ProcessYT[Process YouTube video]
    Platform -->|Facebook| ProcessFB[Process Facebook video]
    Platform -->|Unknown| ErrorPlatform[Show unsupported platform error]
    ErrorPlatform --> Input
    
    ProcessTikTok --> FetchMeta[Fetch video metadata]
    ProcessInsta --> FetchMeta
    ProcessYT --> FetchMeta
    ProcessFB --> FetchMeta
    
    FetchMeta --> ExtractText{Has text/captions?}
    ExtractText -->|Yes| OCR[Extract text via OCR]
    ExtractText -->|No| SkipOCR[Skip text extraction]
    
    OCR --> Transcribe{Has audio?}
    SkipOCR --> Transcribe
    
    Transcribe -->|Yes| AudioText[Transcribe audio to text]
    Transcribe -->|No| SkipTranscribe[Skip audio transcription]
    
    AudioText --> ParseRecipe[Parse recipe data using AI/NLP]
    SkipTranscribe --> ParseRecipe
    
    ParseRecipe --> ExtractComponents[Extract: title, ingredients, steps]
    ExtractComponents --> PopulateForm[Populate recipe form]
    
    PopulateForm --> Review[User reviews extracted data]
    Review --> UserEdit{User makes edits?}
    
    UserEdit -->|Yes| EditForm[User edits fields]
    EditForm --> Review
    
    UserEdit -->|No| SelectCategory[User selects category]
    SelectCategory --> SaveRecipe{Save recipe?}
    
    SaveRecipe -->|Yes| StoreDB[Store recipe in database]
    SaveRecipe -->|No| Cancel[Cancel import]
    
    StoreDB --> Success[Show success message]
    Cancel --> End([End])
    Success --> End
```

## 4. Activity Diagram: Generate Shopping List

### 4.1 Overview
This activity diagram shows the process of generating a shopping list from a meal plan.

### 4.2 Mermaid Diagram

```mermaid
flowchart TD
    Start([User clicks Generate Shopping List]) --> CheckPlan{Meal plan has recipes?}
    
    CheckPlan -->|No| EmptyError[Show error: No recipes in meal plan]
    EmptyError --> End([End])
    
    CheckPlan -->|Yes| InputServings[User enters number of people/servings]
    InputServings --> Validate{Valid number?}
    
    Validate -->|No| ErrorServings[Show validation error]
    ErrorServings --> InputServings
    
    Validate -->|Yes| Initialize[Initialize empty shopping list]
    
    Initialize --> LoopStart{More recipes in plan?}
    LoopStart -->|Yes| GetRecipe[Get next recipe from meal plan]
    
    GetRecipe --> GetIngredients[Get recipe ingredients]
    GetIngredients --> ScaleIngredients[Scale ingredients based on servings]
    
    ScaleIngredients --> LoopIngredients{More ingredients?}
    LoopIngredients -->|Yes| CheckExist{Ingredient exists in list?}
    
    CheckExist -->|Yes| AddQuantity[Add quantity to existing item]
    CheckExist -->|No| AddNew[Add new item to list]
    
    AddQuantity --> NextIngredient[Next ingredient]
    AddNew --> NextIngredient
    NextIngredient --> LoopIngredients
    
    LoopIngredients -->|No| LoopStart
    
    LoopStart -->|No| GroupItems[Group items by category/aisle]
    GroupItems --> SortItems[Sort items within groups]
    
    SortItems --> AddCustom{User has custom items?}
    AddCustom -->|Yes| LoadCustom[Load user's custom items]
    LoadCustom --> MergeCustom[Merge with generated list]
    AddCustom -->|No| SkipCustom[Skip custom items]
    
    MergeCustom --> SaveList[Save shopping list to database]
    SkipCustom --> SaveList
    
    SaveList --> Display[Display shopping list to user]
    Display --> ShowOptions{User action?}
    
    ShowOptions -->|Export| ExportList[Export as PDF/Text]
    ShowOptions -->|Edit| EditList[User edits list items]
    ShowOptions -->|Shop| Shopping[Start shopping mode]
    ShowOptions -->|Done| End
    
    ExportList --> ShowOptions
    EditList --> UpdateDB[Update database]
    UpdateDB --> ShowOptions
    Shopping --> CheckOff[Check off items as purchased]
    CheckOff --> ShowOptions
```

## 5. State Diagram: Recipe Lifecycle

### 5.1 Overview
This state diagram shows the different states a recipe can be in throughout its lifecycle.

### 5.2 Mermaid Diagram

```mermaid
stateDiagram-v2
    [*] --> Draft: User starts creating recipe
    
    Draft --> InReview: User submits for validation
    Draft --> [*]: User cancels creation
    
    InReview --> Published: Validation successful
    InReview --> Draft: Validation failed / Needs edits
    
    Published --> InUse: Recipe added to meal plan
    Published --> Editing: User edits recipe
    
    InUse --> Published: Recipe removed from all meal plans
    InUse --> Editing: User edits recipe
    
    Editing --> Published: Changes saved
    Editing --> InUse: Changes saved (if still in meal plan)
    Editing --> Draft: Major changes / Needs re-validation
    
    Published --> Archived: User archives recipe
    InUse --> Archived: User archives recipe
    
    Archived --> Published: User restores recipe
    Archived --> Deleted: User deletes from archive
    
    Published --> Deleted: User deletes recipe
    Deleted --> [*]: Permanent deletion after 30 days
    Deleted --> Published: User restores within 30 days
    
    note right of Draft
        Recipe is incomplete
        Not visible in lists
    end note
    
    note right of Published
        Recipe is complete
        Visible in user's collection
        Can be added to meal plans
    end note
    
    note right of InUse
        Recipe is in at least one
        active meal plan
    end note
    
    note right of Archived
        Recipe hidden from main view
        Still accessible in archive
    end note
    
    note right of Deleted
        Soft delete - can be recovered
        Permanently deleted after 30 days
    end note
```

## 6. Component Diagram

### 6.1 Overview
This diagram shows the high-level components of the system and their interactions.

### 6.2 Mermaid Diagram

```mermaid
graph TB
    subgraph "Client Layer"
        MobileApp[Mobile Application<br/>iOS/Android]
        WebApp[Web Application<br/>Browser]
    end
    
    subgraph "API Gateway"
        Gateway[API Gateway<br/>Authentication & Routing]
    end
    
    subgraph "Application Layer"
        AuthService[Authentication Service]
        RecipeService[Recipe Service]
        CategoryService[Category Service]
        MealPlanService[Meal Planning Service]
        ShoppingService[Shopping List Service]
        VideoService[Video Import Service]
        NotificationService[Notification Service]
        ShareService[Recipe Sharing Service]
    end
    
    subgraph "Data Layer"
        UserDB[(User Database)]
        RecipeDB[(Recipe Database)]
        MediaStorage[(Media Storage<br/>Images/Videos)]
        Cache[(Cache<br/>Redis)]
    end
    
    subgraph "External Services"
        VideoAPIs[Video Platform APIs<br/>TikTok, Instagram, YouTube]
        TranscriptionAPI[Transcription Service<br/>Audio to Text]
        OCRAPI[OCR Service<br/>Image Text Extraction]
        AIAPI[AI/NLP Service<br/>Recipe Extraction]
        PushService[Push Notification<br/>FCM/APNs]
        EmailService[Email Service]
    end
    
    MobileApp --> Gateway
    WebApp --> Gateway
    
    Gateway --> AuthService
    Gateway --> RecipeService
    Gateway --> CategoryService
    Gateway --> MealPlanService
    Gateway --> ShoppingService
    Gateway --> VideoService
    Gateway --> ShareService
    
    AuthService --> UserDB
    AuthService --> Cache
    
    RecipeService --> RecipeDB
    RecipeService --> MediaStorage
    RecipeService --> Cache
    
    CategoryService --> RecipeDB
    CategoryService --> Cache
    
    MealPlanService --> RecipeDB
    MealPlanService --> Cache
    
    ShoppingService --> RecipeDB
    ShoppingService --> Cache
    ShoppingService --> NotificationService
    
    VideoService --> VideoAPIs
    VideoService --> TranscriptionAPI
    VideoService --> OCRAPI
    VideoService --> AIAPI
    VideoService --> RecipeService
    
    ShareService --> RecipeDB
    ShareService --> EmailService
    
    NotificationService --> PushService
    NotificationService --> EmailService
```

### 6.3 Component Descriptions

#### Client Layer
- **Mobile Application**: Native iOS/Android app built with chosen framework
- **Web Application**: Responsive web interface for desktop/tablet access

#### API Gateway
- Routes requests to appropriate services
- Handles authentication and authorization
- Implements rate limiting and request validation
- Provides API versioning

#### Application Layer Services
- **Authentication Service**: User registration, login, session management
- **Recipe Service**: CRUD operations for recipes, search, filtering
- **Category Service**: Category management operations
- **Meal Planning Service**: Meal plan creation and management
- **Shopping Service**: Shopping list generation and management
- **Video Import Service**: Orchestrates video import workflow
- **Notification Service**: Sends push notifications and emails
- **Recipe Sharing Service**: Handles recipe sharing and public links

#### Data Layer
- **User Database**: Stores user accounts, preferences, authentication data
- **Recipe Database**: Stores recipes, categories, meal plans, shopping lists
- **Media Storage**: Object storage for images and video thumbnails
- **Cache**: Redis cache for frequently accessed data, session storage

#### External Services
- **Video Platform APIs**: TikTok, Instagram, YouTube, Facebook APIs
- **Transcription Service**: Converts video audio to text
- **OCR Service**: Extracts text from video frames
- **AI/NLP Service**: Parses and extracts recipe data from text
- **Push Notification Service**: Firebase Cloud Messaging, Apple Push Notifications
- **Email Service**: Transactional email delivery

## 7. Deployment Diagram

### 7.1 Overview
This diagram shows a potential cloud-based deployment architecture.

### 7.2 Mermaid Diagram

```mermaid
graph TB
    subgraph "User Devices"
        iOS[iOS Device]
        Android[Android Device]
        Browser[Web Browser]
    end
    
    subgraph "CDN & Load Balancing"
        CDN[Content Delivery Network]
        LB[Load Balancer]
    end
    
    subgraph "Application Servers - Auto Scaling Group"
        API1[API Server Instance 1]
        API2[API Server Instance 2]
        API3[API Server Instance N]
    end
    
    subgraph "Background Workers - Auto Scaling"
        Worker1[Video Processing Worker 1]
        Worker2[Video Processing Worker 2]
        Queue[(Message Queue)]
    end
    
    subgraph "Data Storage"
        PrimaryDB[(Primary Database<br/>PostgreSQL/MySQL)]
        ReplicaDB[(Read Replica)]
        RedisCache[(Redis Cache)]
        S3[Object Storage<br/>S3/Cloud Storage]
    end
    
    subgraph "External APIs"
        VideoExt[Video Platform APIs]
        AIExt[AI/ML APIs]
        NotifExt[Notification Services]
    end
    
    iOS --> CDN
    Android --> CDN
    Browser --> CDN
    
    CDN --> LB
    
    LB --> API1
    LB --> API2
    LB --> API3
    
    API1 --> PrimaryDB
    API2 --> PrimaryDB
    API3 --> PrimaryDB
    
    API1 --> ReplicaDB
    API2 --> ReplicaDB
    API3 --> ReplicaDB
    
    API1 --> RedisCache
    API2 --> RedisCache
    API3 --> RedisCache
    
    API1 --> S3
    API2 --> S3
    API3 --> S3
    
    API1 --> Queue
    API2 --> Queue
    API3 --> Queue
    
    Queue --> Worker1
    Queue --> Worker2
    
    Worker1 --> VideoExt
    Worker2 --> VideoExt
    Worker1 --> AIExt
    Worker2 --> AIExt
    
    Worker1 --> S3
    Worker2 --> S3
    
    Worker1 --> PrimaryDB
    Worker2 --> PrimaryDB
    
    API1 --> NotifExt
    API2 --> NotifExt
    API3 --> NotifExt
    
    PrimaryDB -.replication.-> ReplicaDB
```

### 7.3 Deployment Notes

- **Auto-scaling**: Application servers and workers scale based on load
- **High Availability**: Multiple instances with load balancing
- **Database Replication**: Read replicas for read-heavy operations
- **Caching Strategy**: Redis for session data, frequently accessed recipes
- **CDN**: Static assets and media files served via CDN
- **Message Queue**: Asynchronous processing of video imports
- **Monitoring**: Application performance monitoring, logging, alerts

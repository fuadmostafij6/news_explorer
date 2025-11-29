# News Explorer

A Flutter news application built with Clean Architecture, featuring offline caching, pagination, and real-time search capabilities.

## 📱 Features

- **News Feed**: Browse news articles by category with infinite scroll pagination
- **Search**: Real-time search functionality with debounced queries
- **Offline Support**: Automatic caching with 1-hour expiration
- **Article Details**: View full article details with image, title, description, and share functionality
- **Smooth Animations**: Hero animations for seamless transitions

## 🏗️ Architecture

This application follows **Clean Architecture** principles, organizing code into three main layers:

### Layer Structure

```
lib/
├── core/                    # Shared utilities and infrastructure
│   ├── di/                  # Dependency injection (Riverpod providers)
│   ├── error/               # Error handling (Exceptions & Failures)
│   ├── route/               # Navigation routing
│   ├── usecase/             # Base use case interface
│   └── utils/               # Utility classes (colors, assets)
│
└── features/
    └── news/
        ├── data/            # Data Layer
        │   ├── datasources/ # Remote & Local data sources
        │   ├── models/      # Data models (extend entities)
        │   └── repository_impl/ # Repository implementations
        │
        ├── domain/          # Domain Layer (Business Logic)
        │   ├── entities/    # Business entities
        │   ├── repository/  # Repository interfaces
        │   └── usecases/    # Business use cases
        │
        └── presentation/    # Presentation Layer (UI)
            ├── pages/       # Screen widgets
            ├── providers/   # State management (Riverpod)
            └── widgets/     # Reusable UI components
```

### Architecture Principles

1. **Separation of Concerns**: Each layer has a specific responsibility
   - **Presentation**: UI and user interactions
   - **Domain**: Business logic and rules (framework-independent)
   - **Data**: Data sources and external dependencies

2. **Dependency Rule**: Dependencies point inward
   - Presentation depends on Domain
   - Domain depends on nothing
   - Data depends on Domain

3. **Dependency Injection**: Using Riverpod for managing dependencies

## 📊 Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        Presentation Layer                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │  NewsPage    │  │ SearchPage   │  │  NewsDetailPage      │  │
│  │  (UI Widget) │  │  (UI Widget) │  │  (UI Widget)         │  │
│  └──────┬───────┘  └──────┬───────┘  └──────────────────────┘  │
│         │                 │                                      │
│         └─────────┬───────┘                                      │
│                   │                                              │
│         ┌─────────▼─────────┐                                    │
│         │  NewsNotifier     │                                    │
│         │  (Riverpod State) │                                    │
│         └─────────┬─────────┘                                    │
└───────────────────┼─────────────────────────────────────────────┘
                    │
                    │ Calls
                    │
┌───────────────────▼─────────────────────────────────────────────┐
│                         Domain Layer                             │
│  ┌──────────────────┐  ┌──────────────────┐                    │
│  │ GetNewsByCategory│  │  SearchNews      │                    │
│  │    UseCase       │  │    UseCase       │                    │
│  └────────┬─────────┘  └────────┬─────────┘                    │
│           │                     │                                │
│           └──────────┬──────────┘                                │
│                      │                                            │
│           ┌──────────▼──────────┐                                │
│           │  NewsRepository     │                                │
│           │    (Interface)      │                                │
│           └──────────┬───────────┘                                │
└──────────────────────┼───────────────────────────────────────────┘
                       │
                       │ Implemented by
                       │
┌──────────────────────▼───────────────────────────────────────────┐
│                          Data Layer                               │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │         NewsRepositoryImpl                                │   │
│  │  ┌──────────────────┐         ┌──────────────────┐      │   │
│  │  │ RemoteDataSource │         │ LocalDataSource  │      │   │
│  │  │   (API Calls)    │         │   (Hive Cache)   │      │   │
│  │  └────────┬─────────┘         └────────┬─────────┘      │   │
│  └───────────┼───────────────────────────┼──────────────────┘   │
│              │                           │                       │
│  ┌───────────▼───────────┐   ┌──────────▼───────────┐          │
│  │  NewsData.io API      │   │   Hive Database      │          │
│  │  (External Service)   │   │   (Local Storage)     │          │
│  └───────────────────────┘   └──────────────────────┘          │
└─────────────────────────────────────────────────────────────────┘
```

### Data Flow Steps

1. **User Action**: User interacts with UI (scrolls, searches, taps)
2. **State Update**: `NewsNotifier` updates state and triggers use case
3. **Use Case Execution**: Business logic validates and processes request
4. **Repository Call**: Repository coordinates between remote and local sources
5. **Data Fetching**: 
   - **Online**: Fetches from API → Caches to Hive → Returns data
   - **Offline**: Retrieves from Hive cache → Returns cached data
6. **State Update**: Results flow back through layers to update UI

## 💾 Offline Caching Logic

### Caching Strategy

The app implements a **multi-layered caching system** using Hive for local storage:

#### 1. **Page-Based Caching**

Each API response page is cached separately with a unique page identifier:

```dart
// Cache structure in Hive
{
  'news_cache_pages': [
    {
      'id': 'page_0',
      'items': [/* article data */]
    },
    {
      'id': 'page_1',
      'items': [/* article data */]
    },
    // ... more pages
  ],
  'news_cache_timestamp': 1234567890
}
```

#### 2. **Cache Expiration**

- **Expiration Duration**: 1 hour (configurable via `_cacheDuration`)
- **Validation**: Checks timestamp on every cache read
- **Behavior**: Expired cache throws `CacheException`, triggering fallback

#### 3. **Online Flow**

```
User Request
    ↓
Check Connectivity
    ↓
Fetch from API
    ↓
Cache to Hive (with pageId)
    ↓
Return Data to UI
```

**Key Points:**
- First page (`page_0`) resets cache (`resetCache: true`)
- Subsequent pages append to existing cache
- Each page maintains its identifier for offline pagination

#### 4. **Offline Flow**

```
User Request
    ↓
Check Connectivity (Offline)
    ↓
Load All Cached Pages
    ↓
Flatten into Single List
    ↓
Paginate Locally (10 items per "page")
    ↓
Return Paginated Results
```

**Offline Pagination:**
- All cached articles are loaded into memory
- Divided into chunks of 10 items per "page"
- Uses fake page identifiers: `offline_page_1`, `offline_page_2`, etc.
- Maintains same pagination UX as online mode

#### 5. **Cache Update Strategy**

```dart
// When resetCache = true (first page)
1. Clear all existing pages
2. Store new page_0
3. Update timestamp

// When resetCache = false (subsequent pages)
1. Load existing pages
2. Update or append new page
3. Update timestamp
```

#### 6. **Search Offline Behavior**

When offline and searching:
1. Load all cached articles
2. Filter locally by query (case-insensitive title matching)
3. Return filtered results
4. No pagination support for offline search

### Cache Implementation Details

**Storage Keys:**
- `news_cache_pages`: Array of page objects
- `news_cache_timestamp`: Last update timestamp (milliseconds)

**Cache Methods:**
- `cacheNewsPage()`: Stores/updates a page with identifier
- `getCachedPages()`: Retrieves all pages (validates expiration)
- `getCachedNews()`: Returns flattened list of all cached articles

**Error Handling:**
- `CacheException`: Thrown when cache is missing or expired
- Repository catches exception and falls back to empty results or cached data

### Benefits

1. **Seamless Offline Experience**: Users can browse cached news without internet
2. **Efficient Storage**: Only caches what's been viewed
3. **Pagination Support**: Maintains pagination UX even offline
4. **Automatic Expiration**: Ensures data freshness
5. **Memory Efficient**: Loads pages on-demand, not all at once

## 🛠️ Technology Stack

- **Framework**: Flutter 3.8+
- **State Management**: Flutter Riverpod 3.0
- **Local Storage**: Hive 2.2
- **Networking**: Dio 5.9
- **Architecture**: Clean Architecture
- **API**: NewsData.io

## 📦 Dependencies

### Core Dependencies
- `flutter_riverpod`: State management
- `dio`: HTTP client
- `hive` & `hive_flutter`: Local database
- `connectivity_plus`: Network status checking
- `cached_network_image`: Image caching
- `share_plus`: Share functionality
- `lottie`: Animations
- `phosphor_flutter`: Icons

## 🚀 Getting Started

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd news_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 📝 Project Structure

```
lib/
├── core/
│   ├── di/app_providers.dart      # Dependency injection setup
│   ├── error/                      # Error handling
│   ├── route/app_route.dart        # Navigation routes
│   └── usecase/usecase.dart        # Base use case
│
└── features/news/
    ├── data/
    │   ├── datasources/
    │   │   ├── news_remote_data_source.dart
    │   │   └── news_local_data_source.dart
    │   ├── models/news_model.dart
    │   └── repository_impl/news_repository_impl.dart
    │
    ├── domain/
    │   ├── entities/news_entity.dart
    │   ├── repository/news_repository.dart
    │   └── usecases/
    │       ├── get_news_by_category.dart
    │       └── search_news.dart
    │
    └── presentation/
        ├── pages/
        │   ├── news_page.dart
        │   ├── search_page.dart
        │   └── news_detail_page.dart
        ├── providers/news_provider.dart
        └── widgets/news_item.dart
```

## 🔄 State Management Flow

```
NewsNotifier (Riverpod)
    ├── NewsState
    │   ├── articles: List<NewsEntity>
    │   ├── searchResults: List<NewsEntity>
    │   ├── isLoading: bool
    │   ├── isSearchLoading: bool
    │   ├── nextPage: String?
    │   ├── searchNextPage: String?
    │   └── isOffline: bool
    │
    └── Methods
        ├── loadInitial()
        ├── loadMore()
        ├── refresh()
        ├── onQueryChanged()
        └── clearSearch()
```

## 🎯 Key Features Implementation

### Pagination
- **Online**: Uses API `nextPage` token for server-side pagination
- **Offline**: Simulates pagination with 10-item chunks from cache

### Search
- **Debouncing**: 350ms delay to reduce API calls
- **Separate State**: Search results stored independently from main feed
- **Offline Fallback**: Local filtering when offline

### Error Handling
- **Network Errors**: Falls back to cached data
- **Cache Errors**: Shows appropriate error messages
- **User Feedback**: Loading states and error messages

## 📄 License

This project is licensed under the MIT License.

# Inked - Mood-Based Book Discovery App

A Flutter mobile application that helps users discover books based on their mood.

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── theme/
│   ├── app_colors.dart               # Color palette (dark, aesthetic)
│   └── app_theme.dart                # Theme configuration
├── screens/
│   ├── splash_screen.dart            # Splash/Loading screen
│   ├── mood_selection_screen.dart    # Mood selection interface
│   └── book_discovery_screen.dart    # Book swiping interface
├── models/
│   ├── book.dart                     # Book data model
│   ├── quote.dart                    # Quote data model
│   └── user_preference.dart          # User preferences model
├── services/
│   ├── book_service.dart             # Book API service
│   └── database_service.dart         # Database operations
├── widgets/
│   ├── swipe_card.dart               # Swipeable book card
│   └── mood_button.dart              # Mood selection button
└── utils/
    └── constants.dart                # App constants & configurations
```

## Features

- **Mood-Based Discovery**: Select your current mood to get personalized book recommendations
- **Anonymous Quotes**: View quotes from books before revealing the book details
- **Swipe Interface**: Intuitive swipe-right (like) and swipe-left (dismiss) gestures
- **Dark Aesthetic Theme**: Premium dark UI with vibrant accent colors
- **MongoDB Integration**: Backend data persistence for books, quotes, and user preferences

## Color Palette

- **Primary Dark**: `#0D0221` - Deep Purple-Black
- **Primary Accent**: `#6A0572` - Rich Purple
- **Secondary Accent**: `#AB63FA` - Vibrant Purple
- **Accent Gold**: `#D4AF37` - For ratings and highlights
- **Accent Pink**: `#FF006E` - For actions and favorites
- **Accent Cyan**: `#00F5FF` - For secondary highlights

## Getting Started

### Prerequisites
- Flutter 3.0.0+
- Dart 3.0.0+
- MongoDB instance

### Installation

1. Install dependencies:
```bash
flutter pub get
```

2. Configure your backend URL in:
   - `lib/services/book_service.dart`
   - `lib/services/database_service.dart`

3. Run the app:
```bash
flutter run
```

## Dependencies

- **dio**: HTTP client for API requests
- **flutter_card_swiper**: Card swiping functionality
- **hive & hive_flutter**: Local data storage
- **provider**: State management
- **flutter_animate**: Animation utilities
- **intl**: Internationalization support

## Architecture

### Models
- `Book`: Represents a book with metadata from MongoDB
- `Quote`: Represents anonymous quotes for mood-based discovery
- `UserPreference`: Stores user's favorites and interaction history

### Services
- `BookService`: Handles book-related API calls (search, filter by mood, etc.)
- `DatabaseService`: Manages user data, preferences, and analytics

### Screens
1. **SplashScreen**: Initial loading screen with animated branding
2. **MoodSelectionScreen**: Grid of 8 moods with emoji icons
3. **BookDiscoveryScreen**: Card swiping interface for book discovery

### Widgets
- `SwipeCard`: Displays quote first, then reveals book on tap
- `MoodButton`: Interactive mood selection with visual feedback

## Theme System

The app uses Material Design 3 with a custom dark theme:
- Consistent color scheme across all components
- Custom text styles with proper hierarchy
- Themed buttons, inputs, and cards
- Smooth transitions and animations

## Next Steps

1. Set up MongoDB backend for book data
2. Create API endpoints for:
   - GET /books/mood/:mood
   - GET /books/:id
   - POST /users/preferences
   - POST /analytics/mood-selection
3. Implement authentication system
4. Add local caching with Hive
5. Configure Firebase for push notifications
6. Add onboarding flow

## File Conventions

- Screens: `*_screen.dart`
- Models: `*_model.dart` or just model name
- Services: `*_service.dart`
- Widgets: `*_widget.dart` or just widget name
- Utils: `*_helper.dart` or specific filename

---

**App Name**: Inked  
**Current Version**: 1.0.0  
**Tech Stack**: Flutter, MongoDB, Dio

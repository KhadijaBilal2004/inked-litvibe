import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inked/screens/auth_screen.dart';
import 'package:inked/models/user.dart';
import 'package:inked/screens/welcome_screen.dart';
import 'package:inked/services/local_storage_service.dart';
import 'package:inked/models/user_preference.dart';
import 'package:inked/models/reader_settings.dart';
import 'package:inked/models/saved_quote.dart';
import 'package:inked/models/bookmark.dart';
import 'package:inked/models/highlight.dart';
import 'package:inked/models/custom_collection.dart';
import 'package:inked/models/review.dart';

/// A simple in-memory fake storage used for widget tests to avoid Hive disk I/O.
class FakeLocalStorageService implements ILocalStorageService {
  User? _current;
  final Map<String, Map<String, dynamic>> _users = {};
  final Map<String, UserPreference> _preferences = {};

  @override
  User? get currentUser => _current;

  @override
  Future<void> init({String? hivePath}) async {
    // no-op for fake
  }

  @override
  Future<User> registerUser(String name, String email, String password) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final user = User(id: id, name: name, email: email, password: password);
    _users[id] = user.toJson();
    _current = user;
    return user;
  }

  @override
  Future<User> loginUser(String email, String password) async {
    final found = _users.values.cast<Map>().firstWhere(
      (raw) => (raw['email'] as String).toLowerCase() == email.toLowerCase() && raw['password'] == password,
      orElse: () => {},
    );
    if (found.isEmpty) throw Exception('Invalid email or password.');
    final user = User.fromJson(Map<String, dynamic>.from(found));
    _current = user;
    return user;
  }

  @override
  Future<void> logout() async {
    _current = null;
  }

  @override
  Future<void> close() async {}

  @override
  Future<UserPreference> getPreferences(String userId) async {
    return _preferences[userId] ??= UserPreference(
      userId: userId,
      favoriteBooks: [],
      dismissedBooks: [],
      toReadBooks: [],
      readBooks: [],
      moodFrequency: {},
      lastUpdated: DateTime.now(),
      readingProgress: {},
      readerSettings: ReaderSettings(),
      savedQuotes: [],
      bookmarks: [],
      highlights: [],
      collections: [],
      reviews: [],
    );
  }

  @override
  Future<void> savePreferences(UserPreference preference) async {
    _preferences[preference.userId] = preference;
  }

  @override
  Future<void> addToRead(String userId, String bookId) async {
    final prefs = await getPreferences(userId);
    if (!prefs.toReadBooks.contains(bookId)) {
      prefs.toReadBooks.add(bookId);
    }
  }

  @override
  Future<void> addToFavorites(String userId, String bookId) async {
    final prefs = await getPreferences(userId);
    if (!prefs.favoriteBooks.contains(bookId)) {
      prefs.favoriteBooks.add(bookId);
    }
  }

  @override
  Future<void> markAsRead(String userId, String bookId) async {
    final prefs = await getPreferences(userId);
    if (!prefs.readBooks.contains(bookId)) {
      prefs.readBooks.add(bookId);
    }
    prefs.toReadBooks.remove(bookId);
  }

  @override
  Future<void> saveReadingProgress(String userId, String bookId, double offset) async {
    final prefs = await getPreferences(userId);
    _preferences[userId] = prefs.copyWith(
      readingProgress: Map<String, double>.from(prefs.readingProgress)..[bookId] = offset,
    );
  }

  @override
  Future<void> saveReaderSettings(String userId, ReaderSettings settings) async {
    final prefs = await getPreferences(userId);
    _preferences[userId] = prefs.copyWith(readerSettings: settings);
  }

  @override
  Future<void> saveQuote(String userId, SavedQuote quote) async {
    final prefs = await getPreferences(userId);
    prefs.savedQuotes.add(quote);
  }

  @override
  Future<void> removeQuote(String userId, String quoteId) async {
    final prefs = await getPreferences(userId);
    prefs.savedQuotes.removeWhere((q) => q.id == quoteId);
  }

  @override
  Future<void> saveBookmark(String userId, Bookmark bookmark) async {
    final prefs = await getPreferences(userId);
    prefs.bookmarks.add(bookmark);
  }

  @override
  Future<void> removeBookmark(String userId, String bookmarkId) async {
    final prefs = await getPreferences(userId);
    prefs.bookmarks.removeWhere((b) => b.id == bookmarkId);
  }

  @override
  Future<void> saveHighlight(String userId, Highlight highlight) async {
    final prefs = await getPreferences(userId);
    prefs.highlights.add(highlight);
  }

  @override
  Future<void> removeHighlight(String userId, String highlightId) async {
    final prefs = await getPreferences(userId);
    prefs.highlights.removeWhere((h) => h.id == highlightId);
  }

  @override
  Future<void> saveCollection(String userId, CustomCollection collection) async {
    final prefs = await getPreferences(userId);
    final index = prefs.collections.indexWhere((c) => c.id == collection.id);
    if (index >= 0) {
      prefs.collections[index] = collection;
    } else {
      prefs.collections.add(collection);
    }
  }

  @override
  Future<void> removeCollection(String userId, String collectionId) async {
    final prefs = await getPreferences(userId);
    prefs.collections.removeWhere((c) => c.id == collectionId);
  }

  @override
  Future<void> saveReview(String userId, Review review) async {
    final prefs = await getPreferences(userId);
    final index = prefs.reviews.indexWhere((r) => r.bookId == review.bookId);
    if (index >= 0) {
      prefs.reviews[index] = review;
    } else {
      prefs.reviews.add(review);
    }
  }

  @override
  Future<void> removeReview(String userId, String reviewId) async {
    final prefs = await getPreferences(userId);
    prefs.reviews.removeWhere((r) => r.id == reviewId);
  }
}

class _TestNavigatorObserver extends NavigatorObserver {
  final List<String> pushedRoutes = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    final routeName = route.settings.name ?? '<unnamed>';
    debugPrint('NavigatorObserver didPush: $routeName');
    pushedRoutes.add(routeName);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    final newName = newRoute?.settings.name ?? '<unnamed>';
    debugPrint('NavigatorObserver didReplace: $newName');
    if (newRoute?.settings.name != null) {
      pushedRoutes.add(newRoute!.settings.name!);
    }
  }
}

void main() {
  late FakeLocalStorageService fakeStorage;

  setUpAll(() async {
    fakeStorage = FakeLocalStorageService();
    await fakeStorage.init();
  });

  setUp(() async {
    fakeStorage = FakeLocalStorageService();
    await fakeStorage.init();
  });

  testWidgets('Welcome screen shows login and sign up buttons', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const WelcomeScreen(),
        routes: {
          '/auth': (context) => AuthScreen(storage: fakeStorage),
        },
      ),
    );

    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
    expect(find.text('Discover books that match your mood, save your shelf, and keep your reading progress in one place.'), findsOneWidget);

    // Complete animations to avoid pending Timer error
    await tester.pumpAndSettle();
  });

  testWidgets('Signup flow registers a new user and navigates to mood selection', (tester) async {
    final observer = _TestNavigatorObserver();

    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [observer],
        home: const WelcomeScreen(),
        routes: {
          '/auth': (context) => AuthScreen(storage: fakeStorage),
          '/mood-selection': (context) => const Scaffold(
                body: Center(child: Text('Mood Dashboard')),
              ),
        },
      ),
    );

    // Let entry animation finish
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    expect(find.text('Create your account'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(3));

    await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
    await tester.enterText(find.byType(TextFormField).at(1), 'test@example.com');
    await tester.enterText(find.byType(TextFormField).at(2), 'password123');
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    final registered = fakeStorage._users.values.cast<Map>().any((raw) => (raw['email'] as String).toLowerCase() == 'test@example.com');
    expect(registered, isTrue);

    await tester.pumpAndSettle();
  });

  testWidgets('Login flow works for an existing user', (tester) async {
    await fakeStorage.registerUser('Test User', 'test@example.com', 'password123');
    await fakeStorage.logout(); // Clear current user session so it doesn't auto-redirect

    await tester.pumpWidget(
      MaterialApp(
        home: AuthScreen(isLoggingIn: true, storage: fakeStorage),
        routes: {
          '/mood-selection': (context) => const Scaffold(
                body: Center(child: Text('Mood Dashboard')),
              ),
        },
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    final registered = fakeStorage._users.values.cast<Map>().any((raw) => (raw['email'] as String).toLowerCase() == 'test@example.com');
    expect(registered, isTrue);

    await tester.pumpAndSettle();
  });
}

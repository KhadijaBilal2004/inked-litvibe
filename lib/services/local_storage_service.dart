import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';
import '../models/user_preference.dart';
import '../models/reader_settings.dart';
import '../models/saved_quote.dart';
import '../models/bookmark.dart';
import '../models/highlight.dart';
import '../models/custom_collection.dart';
import '../models/review.dart';

/// Minimal interface used by widgets/tests to interact with storage.
abstract class ILocalStorageService {
  User? get currentUser;
  Future<User> registerUser(String name, String email, String password);
  Future<User> loginUser(String email, String password);
  Future<void> logout();
  Future<void> close();
}

class LocalStorageService implements ILocalStorageService {
  LocalStorageService._privateConstructor();
  static final LocalStorageService instance = LocalStorageService._privateConstructor();

  late Box<dynamic> _usersBox;
  late Box<dynamic> _sessionBox;
  late Box<dynamic> _preferencesBox;
  User? _currentUser;

  @override
  User? get currentUser => _currentUser;

  static Future<void> init({String? hivePath}) async {
    if (hivePath != null) {
      Hive.init(hivePath);
    } else {
      await Hive.initFlutter();
    }

    final service = LocalStorageService.instance;
    service._currentUser = null;
    
    // Open boxes
    debugPrint('LocalStorageService.init: opening boxes at $hivePath');
    service._usersBox = await Hive.openBox('users');
    service._sessionBox = await Hive.openBox('session');
    service._preferencesBox = await Hive.openBox('preferences');

    final userId = service._sessionBox.get('currentUserId');
    debugPrint('LocalStorageService.init: currentUserId=$userId');
    if (userId != null) {
      service._currentUser = service._loadUserById(userId as String);
      debugPrint('LocalStorageService.init: loaded currentUser=${service._currentUser?.email}');
    }
  }

  User? _loadUserById(String userId) {
    final raw = _usersBox.get(userId);
    if (raw == null) return null;
    return User.fromJson(Map<String, dynamic>.from(raw as Map));
  }

  @override
  Future<User> registerUser(String name, String email, String password) async {
    debugPrint('LocalStorageService.registerUser: name=$name email=$email');
    final existingUser = _usersBox.values.cast<Map>().firstWhere(
          (raw) => (raw['email'] as String).toLowerCase() == email.toLowerCase(),
          orElse: () => {},
        );

    if (existingUser.isNotEmpty) {
      debugPrint('LocalStorageService.registerUser: user already exists');
      throw Exception('A user with that email already exists.');
    }

    final userId = DateTime.now().millisecondsSinceEpoch.toString();
    final user = User(
      id: userId,
      name: name.trim(),
      email: email.trim().toLowerCase(),
      password: password,
    );

    await _usersBox.put(userId, user.toJson());
    await _sessionBox.put('currentUserId', userId);
    // Ensure data is flushed to disk to avoid race conditions in tests.
    try {
      await _usersBox.flush();
    } catch (_) {}
    try {
      await _sessionBox.flush();
    } catch (_) {}
    debugPrint('LocalStorageService.registerUser: sessionBox currentUserId=${_sessionBox.get('currentUserId')}');
    _currentUser = user;
    await savePreferences(UserPreference(
      userId: userId,
      favoriteBooks: [],
      dismissedBooks: [],
      moodFrequency: {},
      toReadBooks: [],
      readBooks: [],
      lastUpdated: DateTime.now(),
      readingProgress: {},
      readerSettings: ReaderSettings(),
      savedQuotes: [],
      bookmarks: [],
      highlights: [],
      collections: [],
      reviews: [],
    ));
    debugPrint('LocalStorageService.registerUser: registered $email');
    return user;
  }

  @override
  Future<User> loginUser(String email, String password) async {
    debugPrint('LocalStorageService.loginUser: email=$email');
    final rawUser = _usersBox.values.cast<Map>().firstWhere(
          (raw) =>
              (raw['email'] as String).toLowerCase() == email.toLowerCase() &&
              raw['password'] == password,
          orElse: () => {},
        );

    if (rawUser.isEmpty) {
      debugPrint('LocalStorageService.loginUser: invalid credentials');
      throw Exception('Invalid email or password.');
    }

    final user = User.fromJson(Map<String, dynamic>.from(rawUser));
    _currentUser = user;
    await _sessionBox.put('currentUserId', user.id);
    try {
      await _sessionBox.flush();
    } catch (_) {}
    debugPrint('LocalStorageService.loginUser: logged in ${user.email}');
    return user;
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
    await _sessionBox.delete('currentUserId');
  }

  /// Close opened Hive boxes and clear in-memory state.
  @override
  Future<void> close() async {
    _currentUser = null;
    try {
      if (_usersBox.isOpen) await _usersBox.close();
    } catch (_) {}
    try {
      if (_sessionBox.isOpen) await _sessionBox.close();
    } catch (_) {}
    try {
      if (_preferencesBox.isOpen) await _preferencesBox.close();
    } catch (_) {}
  }

  Future<UserPreference> getPreferences(String userId) async {
    final raw = _preferencesBox.get(userId);
    if (raw == null) {
      final defaultPreference = UserPreference(
        userId: userId,
        favoriteBooks: [],
        dismissedBooks: [],
        moodFrequency: {},
        toReadBooks: [],
        readBooks: [],
        lastUpdated: DateTime.now(),
        readingProgress: {},
        readerSettings: ReaderSettings(),
        savedQuotes: [],
        bookmarks: [],
        highlights: [],
        collections: [],
        reviews: [],
      );
      await savePreferences(defaultPreference);
      return defaultPreference;
    }
    return UserPreference.fromJson(Map<String, dynamic>.from(raw as Map));
  }

  Future<void> savePreferences(UserPreference preference) async {
    final updatedPreference = preference.copyWith(lastUpdated: DateTime.now());
    await _preferencesBox.put(preference.userId, updatedPreference.toJson());
  }

  Future<void> addToRead(String userId, String bookId) async {
    final preference = await getPreferences(userId);
    if (!preference.toReadBooks.contains(bookId)) {
      preference.toReadBooks.add(bookId);
      await savePreferences(preference);
    }
  }

  Future<void> addToFavorites(String userId, String bookId) async {
    final preference = await getPreferences(userId);
    if (!preference.favoriteBooks.contains(bookId)) {
      preference.favoriteBooks.add(bookId);
      await savePreferences(preference);
    }
  }

  Future<void> markAsRead(String userId, String bookId) async {
    final preference = await getPreferences(userId);
    if (!preference.readBooks.contains(bookId)) {
      preference.readBooks.add(bookId);
    }
    preference.toReadBooks.remove(bookId);
    await savePreferences(preference);
  }

  Future<void> saveReadingProgress(String userId, String bookId, double offset) async {
    final preference = await getPreferences(userId);
    final newProgress = Map<String, double>.from(preference.readingProgress);
    newProgress[bookId] = offset;
    await savePreferences(preference.copyWith(readingProgress: newProgress));
  }

  Future<void> saveReaderSettings(String userId, ReaderSettings settings) async {
    final preference = await getPreferences(userId);
    await savePreferences(preference.copyWith(readerSettings: settings));
  }

  Future<void> saveQuote(String userId, SavedQuote quote) async {
    final preference = await getPreferences(userId);
    final quotes = List<SavedQuote>.from(preference.savedQuotes);
    quotes.add(quote);
    await savePreferences(preference.copyWith(savedQuotes: quotes));
  }

  Future<void> removeQuote(String userId, String quoteId) async {
    final preference = await getPreferences(userId);
    final quotes = List<SavedQuote>.from(preference.savedQuotes);
    quotes.removeWhere((q) => q.id == quoteId);
    await savePreferences(preference.copyWith(savedQuotes: quotes));
  }

  Future<void> saveBookmark(String userId, Bookmark bookmark) async {
    final preference = await getPreferences(userId);
    final bookmarks = List<Bookmark>.from(preference.bookmarks);
    bookmarks.add(bookmark);
    await savePreferences(preference.copyWith(bookmarks: bookmarks));
  }

  Future<void> removeBookmark(String userId, String bookmarkId) async {
    final preference = await getPreferences(userId);
    final bookmarks = List<Bookmark>.from(preference.bookmarks);
    bookmarks.removeWhere((b) => b.id == bookmarkId);
    await savePreferences(preference.copyWith(bookmarks: bookmarks));
  }

  Future<void> saveHighlight(String userId, Highlight highlight) async {
    final preference = await getPreferences(userId);
    final highlights = List<Highlight>.from(preference.highlights);
    highlights.add(highlight);
    await savePreferences(preference.copyWith(highlights: highlights));
  }

  Future<void> removeHighlight(String userId, String highlightId) async {
    final preference = await getPreferences(userId);
    final highlights = List<Highlight>.from(preference.highlights);
    highlights.removeWhere((h) => h.id == highlightId);
    await savePreferences(preference.copyWith(highlights: highlights));
  }

  Future<void> saveCollection(String userId, CustomCollection collection) async {
    final preference = await getPreferences(userId);
    final collections = List<CustomCollection>.from(preference.collections);
    final index = collections.indexWhere((c) => c.id == collection.id);
    if (index >= 0) {
      collections[index] = collection;
    } else {
      collections.add(collection);
    }
    await savePreferences(preference.copyWith(collections: collections));
  }

  Future<void> removeCollection(String userId, String collectionId) async {
    final preference = await getPreferences(userId);
    final collections = List<CustomCollection>.from(preference.collections);
    collections.removeWhere((c) => c.id == collectionId);
    await savePreferences(preference.copyWith(collections: collections));
  }

  Future<void> saveReview(String userId, Review review) async {
    final preference = await getPreferences(userId);
    final reviews = List<Review>.from(preference.reviews);
    final index = reviews.indexWhere((r) => r.bookId == review.bookId);
    if (index >= 0) {
      reviews[index] = review;
    } else {
      reviews.add(review);
    }
    await savePreferences(preference.copyWith(reviews: reviews));
  }

  Future<void> removeReview(String userId, String reviewId) async {
    final preference = await getPreferences(userId);
    final reviews = List<Review>.from(preference.reviews);
    reviews.removeWhere((r) => r.id == reviewId);
    await savePreferences(preference.copyWith(reviews: reviews));
  }
}

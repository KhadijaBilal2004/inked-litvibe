import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';
import '../models/user_preference.dart';

class LocalStorageService {
  LocalStorageService._privateConstructor();
  static final LocalStorageService instance = LocalStorageService._privateConstructor();

  late Box<dynamic> _usersBox;
  late Box<dynamic> _sessionBox;
  late Box<dynamic> _preferencesBox;
  User? _currentUser;

  User? get currentUser => _currentUser;

  static Future<void> init() async {
    await Hive.initFlutter();
    final service = LocalStorageService.instance;
    
    // Open boxes
    service._usersBox = await Hive.openBox('users');
    service._sessionBox = await Hive.openBox('session');
    service._preferencesBox = await Hive.openBox('preferences');

    final userId = service._sessionBox.get('currentUserId');
    if (userId != null) {
      service._currentUser = service._loadUserById(userId as String);
    }
  }

  User? _loadUserById(String userId) {
    final raw = _usersBox.get(userId);
    if (raw == null) return null;
    return User.fromJson(Map<String, dynamic>.from(raw as Map));
  }

  Future<User> registerUser(String name, String email, String password) async {
    final existingUser = _usersBox.values.cast<Map>().firstWhere(
          (raw) => (raw['email'] as String).toLowerCase() == email.toLowerCase(),
          orElse: () => {},
        );

    if (existingUser.isNotEmpty) {
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
    _currentUser = user;
    await savePreferences(UserPreference(
      userId: userId,
      favoriteBooks: [],
      dismissedBooks: [],
      moodFrequency: {},
      toReadBooks: [],
      readBooks: [],
      lastUpdated: DateTime.now(),
    ));

    return user;
  }

  Future<User> loginUser(String email, String password) async {
    final rawUser = _usersBox.values.cast<Map>().firstWhere(
          (raw) =>
              (raw['email'] as String).toLowerCase() == email.toLowerCase() &&
              raw['password'] == password,
          orElse: () => {},
        );

    if (rawUser.isEmpty) {
      throw Exception('Invalid email or password.');
    }

    final user = User.fromJson(Map<String, dynamic>.from(rawUser as Map));
    _currentUser = user;
    await _sessionBox.put('currentUserId', user.id);
    return user;
  }

  Future<void> logout() async {
    _currentUser = null;
    await _sessionBox.delete('currentUserId');
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
}

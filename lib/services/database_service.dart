import 'package:dio/dio.dart';
import '../models/user_preference.dart';
import '../models/book.dart';

class DatabaseService {
  final Dio _dio = Dio();
  final String _baseUrl = 'http://your-api-url.com/api'; // Replace with your backend URL

  // Save user preference
  Future<void> saveUserPreference(UserPreference preference) async {
    try {
      await _dio.post(
        '$_baseUrl/users/preferences',
        data: preference.toJson(),
      );
    } catch (e) {
      throw Exception('Error saving preferences: $e');
    }
  }

  // Get user preferences
  Future<UserPreference> getUserPreference(String userId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/users/$userId/preferences',
      );

      if (response.statusCode == 200) {
        return UserPreference.fromJson(response.data);
      }
      throw Exception('Failed to load user preferences');
    } catch (e) {
      throw Exception('Error fetching preferences: $e');
    }
  }

  // Add book to favorites
  Future<void> addToFavorites(String userId, String bookId) async {
    try {
      await _dio.post(
        '$_baseUrl/users/$userId/favorites',
        data: {'bookId': bookId},
      );
    } catch (e) {
      throw Exception('Error adding to favorites: $e');
    }
  }

  // Remove book from favorites
  Future<void> removeFromFavorites(String userId, String bookId) async {
    try {
      await _dio.delete(
        '$_baseUrl/users/$userId/favorites/$bookId',
      );
    } catch (e) {
      throw Exception('Error removing from favorites: $e');
    }
  }

  // Get user's favorite books
  Future<List<Book>> getFavoriteBooks(String userId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/users/$userId/favorites',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['books'] ?? [];
        return data.map((json) => Book.fromJson(json)).toList();
      }
      throw Exception('Failed to load favorites');
    } catch (e) {
      throw Exception('Error fetching favorites: $e');
    }
  }

  // Log mood selection (for analytics)
  Future<void> logMoodSelection(String userId, String mood) async {
    try {
      await _dio.post(
        '$_baseUrl/analytics/mood-selection',
        data: {
          'userId': userId,
          'mood': mood,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      throw Exception('Error logging mood selection: $e');
    }
  }
}

import 'package:dio/dio.dart';
import '../models/book.dart';

class BookService {
  final Dio _dio = Dio();
  final String _baseUrl = 'http://your-api-url.com/api'; // Replace with your backend URL

  // Get books by mood
  Future<List<Book>> getBooksByMood(String mood) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/books/mood/$mood',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['books'] ?? [];
        return data.map((json) => Book.fromJson(json)).toList();
      }
      throw Exception('Failed to load books');
    } catch (e) {
      throw Exception('Error fetching books: $e');
    }
  }

  // Get a single book by ID
  Future<Book> getBookById(String bookId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/books/$bookId',
      );

      if (response.statusCode == 200) {
        return Book.fromJson(response.data);
      }
      throw Exception('Failed to load book');
    } catch (e) {
      throw Exception('Error fetching book: $e');
    }
  }

  // Search books
  Future<List<Book>> searchBooks(String query) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/books/search',
        queryParameters: {'q': query},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['books'] ?? [];
        return data.map((json) => Book.fromJson(json)).toList();
      }
      throw Exception('Failed to search books');
    } catch (e) {
      throw Exception('Error searching books: $e');
    }
  }

  // Get random books (for initial discovery)
  Future<List<Book>> getRandomBooks({int limit = 10}) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/books/random',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['books'] ?? [];
        return data.map((json) => Book.fromJson(json)).toList();
      }
      throw Exception('Failed to load random books');
    } catch (e) {
      throw Exception('Error fetching random books: $e');
    }
  }
}

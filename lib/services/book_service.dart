import '../models/book.dart';
import 'sqlite_service.dart';

class BookService {
  Future<List<Book>> getBooksByMood(String mood) async {
    return await SqliteService.getBooksByMood(mood);
  }

  Future<Book?> getBookById(String bookId) async {
    return await SqliteService.getBookById(bookId);
  }

  Future<List<Book>> getBooksByIds(List<String> bookIds) async {
    return await SqliteService.getBooksByIds(bookIds);
  }

  Future<List<Book>> searchBooks(String query) async {
    final db = await SqliteService.database;
    final normalizedQuery = '%${query.toLowerCase()}%';
    
    final maps = await db.query(
      'books',
      where: 'LOWER(title) LIKE ? OR LOWER(author) LIKE ?',
      whereArgs: [normalizedQuery, normalizedQuery],
      limit: 20,
    );
    
    return maps.map((m) => Book.fromMap(m)).toList();
  }

  Future<List<Book>> getRandomBooks({int limit = 10}) async {
    final db = await SqliteService.database;
    final maps = await db.query(
      'books',
      orderBy: 'RANDOM()',
      limit: limit,
    );
    
    return maps.map((m) => Book.fromMap(m)).toList();
  }
}

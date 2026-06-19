import 'dart:io' show File, Directory;
import 'dart:typed_data' show ByteData;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import '../models/book.dart';

class SqliteService {
  static Database? _db;

  static Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError('SQLite is not supported on web.');
    }
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  static Future<Database> initDb() async {
    if (kIsWeb) {
      throw UnsupportedError('SQLite is not supported on web.');
    }
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "app_books_v10.db");

    final File dbFile = File(path);
    
    // Only copy if the database doesn't exist or is empty/corrupt (less than 10MB)
    if (!dbFile.existsSync() || dbFile.lengthSync() < 10 * 1024 * 1024) {
      if (dbFile.existsSync()) {
        try {
          await dbFile.delete();
        } catch (e) {
          debugPrint('Error deleting corrupt database: $e');
        }
      }

      // Load database from asset and copy using forward slashes as required by rootBundle
      ByteData data = await rootBundle.load("assets/db/app_books.db");
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Save copied asset to documents
      await dbFile.writeAsBytes(bytes);
    }

    // Clean up older database versions to free up space
    try {
      final List<String> oldVersions = ['app_books_v9.db', 'app_books_v8.db', 'app_books_v7.db', 'app_books_v6.db', 'app_books.db'];
      for (final oldDb in oldVersions) {
        final oldPath = join(documentsDirectory.path, oldDb);
        final oldFile = File(oldPath);
        if (oldFile.existsSync()) {
          await oldFile.delete();
        }
      }
    } catch (e) {
      debugPrint('Error cleaning old databases: $e');
    }

    // Open the database
    return await openDatabase(path, version: 1);
  }

  static Future<List<Book>> getBooksByMood(String mood) async {
    if (kIsWeb) {
      final m = mood.toLowerCase();
      final colors = ['afca1f', 'e07a5f', '3d5a80', '98c1d9', 'ee6c4d'];
      return List.generate(5, (i) {
        return Book(
          id: '${m}_$i',
          title: 'Speculative ${mood[0].toUpperCase()}${mood.substring(1)} Read ${i + 1}',
          author: 'Author ${i + 1}',
          description: 'This is a beautifully written speculative work that fits your current mood perfectly.',
          coverImageUrl: 'https://placehold.co/400x600/${colors[i % colors.length]}/ffffff.png?text=${mood[0].toUpperCase()}${mood.substring(1)}+$i',
          genres: ['Vibe', 'Reflective'],
          rating: 4.0 + (i * 0.2),
          pages: 150 + (i * 45),
          publishedYear: '2023',
          mood: m,
          quotes: ['A beautiful quote from book $i', 'Another inspiring line.'],
          language: 'English',
          fullText: 'Chapter 1\n\nThis is the beginning of a wonderful journey on the web platform. The reader screen can render this text and let you bookmark or highlight portions of it just like the native app.',
        );
      });
    }

    final db = await database;
    
    // Convert the UI mood to capitalized DB mood (e.g. 'cheerful' -> 'Cheerful')
    final dbMood = mood.isEmpty ? '' : '${mood[0].toUpperCase()}${mood.substring(1)}';

    final List<Map<String, dynamic>> maps = await db.query(
      'books',
      where: 'mood = ?',
      whereArgs: [dbMood],
    );

    return List.generate(maps.length, (i) {
      return Book.fromMap(maps[i]);
    });
  }

  static Future<Book?> getBookById(String id) async {
    if (kIsWeb) {
      final parts = id.split('_');
      final mood = parts.first;
      final idx = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
      return Book(
        id: id,
        title: 'Speculative ${mood[0].toUpperCase()}${mood.substring(1)} Read ${idx + 1}',
        author: 'Author ${idx + 1}',
        description: 'This is a beautifully written speculative work that fits your current mood perfectly.',
        coverImageUrl: 'https://placehold.co/400x600/5b4636/ffffff.png?text=${mood[0].toUpperCase()}${mood.substring(1)}+$idx',
        genres: ['Vibe', 'Reflective'],
        rating: 4.0 + (idx * 0.2),
        pages: 150 + (idx * 45),
        publishedYear: '2023',
        mood: mood,
        quotes: ['A beautiful quote from book $idx', 'Another inspiring line.'],
        language: 'English',
        fullText: 'Chapter 1\n\nThis is the beginning of a wonderful journey on the web platform. The reader screen can render this text and let you bookmark or highlight portions of it just like the native app.',
      );
    }

    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'books',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Book.fromMap(maps.first);
    }
    return null;
  }
}

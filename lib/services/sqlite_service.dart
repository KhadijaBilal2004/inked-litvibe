import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import '../models/book.dart';

class SqliteService {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  static Future<Database> initDb() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "app_books_v4.db");

    // Only copy if the database doesn't exist
    if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound) {
      // Load database from asset and copy using forward slashes as required by rootBundle
      ByteData data = await rootBundle.load("assets/db/app_books.db");
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Save copied asset to documents
      await File(path).writeAsBytes(bytes);
    }

    // Open the database
    return await openDatabase(path, version: 1);
  }

  static Future<List<Book>> getBooksByMood(String mood) async {
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

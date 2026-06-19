import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;

void main() async {
  sqfliteFfiInit();
  var databaseFactory = databaseFactoryFfi;
  
  String tempDir = Platform.environment['TEMP'] ?? '';
  String dbPath = tempDir.isNotEmpty && File(p.join(tempDir, 'app_books.db')).existsSync()
      ? p.join(tempDir, 'app_books.db')
      : p.join(Directory.current.path, 'assets', 'db', 'app_books.db');
  var file = File(dbPath);
  if (!file.existsSync()) {
    print('DB does not exist at $dbPath');
    return;
  }
  
  print('Original file size: ${(file.lengthSync() / (1024 * 1024)).toStringAsFixed(2)} MB');
  
  var db = await databaseFactory.openDatabase(dbPath);
  
  // Get all unique moods
  var moodsResult = await db.rawQuery('SELECT DISTINCT mood FROM books');
  List<String> moods = moodsResult.map((m) => m['mood'] as String).toList();
  
  print('Processing ${moods.length} moods...');
  int totalDeleted = 0;
  
  for (var mood in moods) {
    // Get books for this mood ordered by rating descending
    var books = await db.query(
      'books',
      columns: ['id'],
      where: 'mood = ?',
      whereArgs: [mood],
      orderBy: 'rating DESC',
    );
    
    if (books.length > 30) {
      // Keep first 30, delete the rest
      var idsToKeep = books.take(30).map((b) => b['id'].toString()).toList();
      
      // Construct delete query for ids NOT in the top 30
      String placeholders = List.filled(idsToKeep.length, '?').join(', ');
      var deleted = await db.delete(
        'books',
        where: 'mood = ? AND id NOT IN ($placeholders)',
        whereArgs: [mood, ...idsToKeep],
      );
      
      totalDeleted += deleted;
      print('Mood "$mood": Kept 30 books, deleted $deleted books.');
    } else {
      print('Mood "$mood": Kept all ${books.length} books.');
    }
  }
  
  print('Total books deleted: $totalDeleted');
  
  print('Running VACUUM to reclaim space...');
  await db.execute('VACUUM');
  print('VACUUM complete.');
  
  var countResult = await db.rawQuery('SELECT count(*) as count FROM books');
  print('Total books remaining: ${countResult.first['count']}');
  
  await db.close();
  
  print('Optimized database size: ${(file.lengthSync() / (1024 * 1024)).toStringAsFixed(2)} MB');
}

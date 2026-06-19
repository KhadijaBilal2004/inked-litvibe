import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;

void main() async {
  sqfliteFfiInit();
  var databaseFactory = databaseFactoryFfi;
  
  String dbPath = p.join(Directory.current.path, 'assets', 'db', 'app_books.db');
  var db = await databaseFactory.openDatabase(dbPath);
  
  var results = await db.rawQuery('SELECT mood, count(*) as count FROM books GROUP BY mood');
  for (var row in results) {
    print('Mood: ${row['mood']}, Count: ${row['count']}');
  }
  
  await db.close();
}

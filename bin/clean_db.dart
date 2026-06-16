import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;

void main() async {
  sqfliteFfiInit();
  var databaseFactory = databaseFactoryFfi;
  
  print('Opening database...');
  String dbPath = p.join(Directory.current.path, 'assets', 'db', 'app_books.db');
  print('Path: $dbPath');
  var db = await databaseFactory.openDatabase(dbPath);
  
  // Clean up non-english books
  print('Executing language cleanup query...');
  int langCount = await db.delete('books',
      where: "language IS NOT NULL AND language != 'en' AND language != 'English'");
  
  // Clean up books with no text or text too short to generate a quote
  print('Executing text cleanup query...');
  int textCount = await db.delete('books',
      where: "full_text IS NULL OR length(full_text) < 1000");

  print('Deleted $langCount non-English books.');
  print('Deleted $textCount books with insufficient text.');
  await db.close();
  print('Database cleanup complete.');
}

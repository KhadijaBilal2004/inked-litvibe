import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;

void main() async {
  sqfliteFfiInit();
  var databaseFactory = databaseFactoryFfi;
  
  String dbPath = p.join(Directory.current.path, 'assets', 'db', 'app_books.db');
  var file = File(dbPath);
  if (!file.existsSync()) {
    print('DB does not exist at $dbPath');
    return;
  }
  
  print('Initial file size: ${(file.lengthSync() / (1024 * 1024)).toStringAsFixed(2)} MB');
  
  var db = await databaseFactory.openDatabase(dbPath);
  
  var countResult = await db.rawQuery('SELECT count(*) as count FROM books');
  print('Total books: ${countResult.first['count']}');
  
  print('Running VACUUM...');
  await db.execute('VACUUM');
  print('VACUUM complete.');
  
  await db.close();
  
  print('New file size: ${(file.lengthSync() / (1024 * 1024)).toStringAsFixed(2)} MB');
}

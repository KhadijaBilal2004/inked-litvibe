import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;

void main() async {
  sqfliteFfiInit();
  var databaseFactory = databaseFactoryFfi;
  
  String dbPath = p.join(Directory.current.path, 'assets', 'db', 'app_books.db');
  var db = await databaseFactory.openDatabase(dbPath);
  
  var result = await db.rawQuery('SELECT language, COUNT(*) as c FROM books GROUP BY language');
  for (var row in result) {
    print('${row['language']} : ${row['c']}');
  }
  
  await db.close();
}

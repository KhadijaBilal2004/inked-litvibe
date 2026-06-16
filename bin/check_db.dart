import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;

void main() async {
  sqfliteFfiInit();
  var databaseFactory = databaseFactoryFfi;
  
  // This mimics how SqliteService gets the path (though path_provider is not easy to use in a raw dart script)
  // On Windows, getApplicationDocumentsDirectory() returns `C:\Users\User\Documents`.
  String docsPath = 'C:\\Users\\User\\Documents';
  String path = p.join(docsPath, 'app_books_v7.db');
  
  if (!File(path).existsSync()) {
    print('DB does not exist at $path');
    return;
  }
  
  var db = await databaseFactory.openDatabase(path);
  
  var results = await db.query('books', limit: 5);
  for (var row in results) {
    String title = row['title'] as String;
    String fullText = (row['full_text'] as String?) ?? '';
    print('Title: $title, Text Length: ${fullText.length}');
  }
  
  await db.close();
}

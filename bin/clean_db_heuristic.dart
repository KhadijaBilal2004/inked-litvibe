import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;

void main() async {
  sqfliteFfiInit();
  var databaseFactory = databaseFactoryFfi;
  
  String dbPath = p.join(Directory.current.path, 'assets', 'db', 'app_books.db');
  var db = await databaseFactory.openDatabase(dbPath);
  
  print('Running heuristic language cleanup...');
  var books = await db.query('books', columns: ['id', 'full_text']);
  
  int deletedCount = 0;
  
  // Common foreign stopwords or characters that strongly indicate non-English text
  // German: der, die, das, und, ist, nicht
  // French: le, la, les, et, est, pas
  // Spanish: el, la, los, las, y, es, no
  final foreignPatterns = [
    RegExp(r'\b(der|die|das|und|ist|nicht|mit|einem|eine|einer)\b', caseSensitive: false), // German
    RegExp(r'\b(el|la|los|las|en|es|un|una)\b', caseSensitive: false), // Spanish
    RegExp(r'\b(le|la|les|et|est|un|une)\b', caseSensitive: false), // French
    RegExp(r'[äöüßñáéíóúç]', caseSensitive: false), // Foreign characters
  ];

  for (var book in books) {
    String text = book['full_text']?.toString() ?? '';
    if (text.isEmpty) continue;
    
    // Check first 1000 characters
    String sample = text.substring(0, text.length > 1000 ? 1000 : text.length);
    
    int foreignScore = 0;
    for (var pattern in foreignPatterns) {
      foreignScore += pattern.allMatches(sample).length;
    }
    
    // If we find a high concentration of foreign words/characters, delete it
    if (foreignScore > 20) {
      await db.delete('books', where: 'id = ?', whereArgs: [book['id']]);
      deletedCount++;
    }
  }
  
  print('Heuristic cleanup deleted $deletedCount foreign books masquerading as English.');
  
  await db.close();
}

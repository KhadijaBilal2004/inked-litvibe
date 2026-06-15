import '../models/book.dart';

class QuoteService {
  // A mapping of specific book titles to "selling quotes" from the internet.
  // This can be expanded as needed.
  static final Map<String, String> _sellingQuotes = {
    'Pride and Prejudice': '"It is a truth universally acknowledged, that a single man in possession of a good fortune, must be in want of a wife." - The quintessential romance that defined a genre.',
    'Frankenstein': '"Beware; for I am fearless, and therefore powerful." - A chilling exploration of creation and consequence.',
    'The Great Gatsby': '"So we beat on, boats against the current, borne back ceaselessly into the past." - The tragic, glittering illusion of the American Dream.',
    'Moby Dick': '"Call me Ishmael." - Dive into the ultimate tale of obsession and the deep sea.',
    '1984': '"Big Brother is watching you." - A terrifyingly prophetic vision of a dystopian future.',
    'Jane Eyre': '"I am no bird; and no net ensnares me." - A powerful story of independence and fiery passion.',
    'Alice in Wonderland': '"We\'re all mad here." - Take a surreal tumble down the rabbit hole.',
    'Dracula': '"Listen to them, the children of the night. What music they make!" - The classic horror that birthed a legend.',
    'The Picture of Dorian Gray': '"The only way to get rid of a temptation is to yield to it." - A dark, mesmerizing look at vanity and corruption.',
    'A Tale of Two Cities': '"It was the best of times, it was the worst of times..." - An epic story of love and sacrifice amidst revolution.',
  };

  /// Returns a specific selling quote if available.
  static String? getSellingQuote(String title) {
    // Normalize the title slightly for matching
    final normalizedTitle = title.trim();
    for (var key in _sellingQuotes.keys) {
      if (normalizedTitle.toLowerCase().contains(key.toLowerCase())) {
        return _sellingQuotes[key];
      }
    }
    return null;
  }

  /// Generates a quote for a book, using a selling quote if available,
  /// or falling back to text extraction.
  static String generateQuoteForBook(Book book) {
    // 1. Try to get a specific selling quote
    final sellingQuote = getSellingQuote(book.title);
    if (sellingQuote != null) {
      return sellingQuote;
    }

    // 2. Try pre-existing quotes array
    if (book.quotes.isNotEmpty) {
      return book.quotes[DateTime.now().millisecondsSinceEpoch % book.quotes.length];
    } 
    
    // 3. Fallback to extracting from full text
    if (book.fullText != null && book.fullText!.length > 500) {
      final start = (book.fullText!.length ~/ 2) + (DateTime.now().millisecondsSinceEpoch % 5000);
      if (start < book.fullText!.length - 300) {
        final text = book.fullText!.substring(start, start + 300);
        final firstPeriod = text.indexOf('.');
        final lastPeriod = text.lastIndexOf('.');
        if (firstPeriod != -1 && lastPeriod != -1 && firstPeriod < lastPeriod) {
          return '"${text.substring(firstPeriod + 1, lastPeriod + 1).trim()}"';
        }
      }
    }

    // 4. Ultimate fallback
    return 'A captivating story awaits you...\nTap to reveal the book!';
  }
}

import '../models/book.dart';

class BookService {
  static final List<Book> _mockBooks = [
    Book(
      id: 'b1',
      title: 'Sunlit Pathways',
      author: 'Ava Wilder',
      description: 'A tender story that warms the heart during bright mornings.',
      coverImageUrl: 'https://picsum.photos/seed/book1/400/600',
      genres: ['Contemporary', 'Feel-good'],
      rating: 4.6,
      pages: 312,
      publishedYear: '2022',
      mood: 'happy',
      quotes: ['Every sunrise is a new chapter to write with joy.'],
      mongodbId: 'b1',
    ),
    Book(
      id: 'b2',
      title: 'The Quiet Harbor',
      author: 'Mila Hart',
      description: 'A calm, reflective novel about healing and stillness.',
      coverImageUrl: 'https://picsum.photos/seed/book2/400/600',
      genres: ['Drama', 'Literary'],
      rating: 4.3,
      pages: 280,
      publishedYear: '2021',
      mood: 'peaceful',
      quotes: ['Silence can hold more truth than a thousand words.'],
      mongodbId: 'b2',
    ),
    Book(
      id: 'b3',
      title: 'Velvet Shadows',
      author: 'Noah Vale',
      description: 'A mysterious thriller that keeps you guessing until the last page.',
      coverImageUrl: 'https://picsum.photos/seed/book3/400/600',
      genres: ['Mystery', 'Thriller'],
      rating: 4.7,
      pages: 348,
      publishedYear: '2023',
      mood: 'mysterious',
      quotes: ['Not everything hidden is lost — some secrets only reveal themselves in the dark.'],
      mongodbId: 'b3',
    ),
    Book(
      id: 'b4',
      title: 'Wings of Wonder',
      author: 'Elena Storm',
      description: 'An inspiring journey through dreams, ambition, and courage.',
      coverImageUrl: 'https://picsum.photos/seed/book4/400/600',
      genres: ['Inspirational', 'Adventure'],
      rating: 4.9,
      pages: 360,
      publishedYear: '2024',
      mood: 'inspiring',
      quotes: ['Believe in every step and the path will follow.'],
      mongodbId: 'b4',
    ),
    Book(
      id: 'b5',
      title: 'Autumn Letters',
      author: 'Siena Cole',
      description: 'A nostalgic romance with the faded gold of small-town memories.',
      coverImageUrl: 'https://picsum.photos/seed/book5/400/600',
      genres: ['Romance', 'Historical'],
      rating: 4.4,
      pages: 296,
      publishedYear: '2020',
      mood: 'nostalgic',
      quotes: ['In every memory there is a scent of a time we thought we could keep forever.'],
      mongodbId: 'b5',
    ),
    Book(
      id: 'b6',
      title: 'Pulse of the City',
      author: 'Jasper King',
      description: 'A fast-paced story full of anxiety, risk, and the thrill of surviving the rush.',
      coverImageUrl: 'https://picsum.photos/seed/book6/400/600',
      genres: ['Suspense', 'Urban'],
      rating: 4.2,
      pages: 320,
      publishedYear: '2023',
      mood: 'anxious',
      quotes: ['The heartbeat of the city echoed the pace of every choice I made.'],
      mongodbId: 'b6',
    ),
    Book(
      id: 'b7',
      title: 'Midnight Notes',
      author: 'Aria Lane',
      description: 'A lush story of love and poetic longing set beneath neon skies.',
      coverImageUrl: 'https://picsum.photos/seed/book7/400/600',
      genres: ['Romance', 'Contemporary'],
      rating: 4.5,
      pages: 334,
      publishedYear: '2022',
      mood: 'romantic',
      quotes: ['The quietest moments can hold the loudest love.'],
      mongodbId: 'b7',
    ),
    Book(
      id: 'b8',
      title: 'Echoes of Thought',
      author: 'Liam Grey',
      description: 'A thoughtful exploration of memory, identity, and second chances.',
      coverImageUrl: 'https://picsum.photos/seed/book8/400/600',
      genres: ['Philosophical', 'Literary'],
      rating: 4.1,
      pages: 288,
      publishedYear: '2021',
      mood: 'thoughtful',
      quotes: ['Ideas are the quiet companions that keep us company in the dark.'],
      mongodbId: 'b8',
    ),
    Book(
      id: 'b9',
      title: 'Stormbreak',
      author: 'Riley Shaw',
      description: 'A daring, adventurous escape into uncharted wilds and self-discovery.',
      coverImageUrl: 'https://picsum.photos/seed/book9/400/600',
      genres: ['Adventure', 'Action'],
      rating: 4.8,
      pages: 402,
      publishedYear: '2023',
      mood: 'adventurous',
      quotes: ['The world is wider than our fear and brighter than our doubt.'],
      mongodbId: 'b9',
    ),
    Book(
      id: 'b10',
      title: 'Rainy Reverie',
      author: 'Cora Finch',
      description: 'A melancholic tale of longing, change, and the beauty of quiet endings.',
      coverImageUrl: 'https://picsum.photos/seed/book10/400/600',
      genres: ['Drama', 'Melancholy'],
      rating: 4.0,
      pages: 310,
      publishedYear: '2019',
      mood: 'melancholic',
      quotes: ['Even the rain carries songs for those who listen.'],
      mongodbId: 'b10',
    ),
    Book(
      id: 'b11',
      title: 'Nightlight',
      author: 'Zara Frost',
      description: 'A suspenseful mystery that lurks in corners and keeps you turning pages.',
      coverImageUrl: 'https://picsum.photos/seed/book11/400/600',
      genres: ['Mystery', 'Psychological'],
      rating: 4.6,
      pages: 358,
      publishedYear: '2024',
      mood: 'mysterious',
      quotes: ['The unknown is only frightening until we begin to understand it.'],
      mongodbId: 'b11',
    ),
  ];

  Future<List<Book>> getBooksByMood(String mood) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _mockBooks
        .where((book) => book.mood.toLowerCase() == mood.toLowerCase())
        .toList();
  }

  Future<Book> getBookById(String bookId) async {
    final book = _mockBooks.firstWhere(
      (book) => book.id == bookId,
      orElse: () => throw Exception('Book not found'),
    );
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return book;
  }

  Future<List<Book>> searchBooks(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _mockBooks.where((book) {
      final normalizedQuery = query.toLowerCase();
      return book.title.toLowerCase().contains(normalizedQuery) ||
          book.author.toLowerCase().contains(normalizedQuery) ||
          book.description.toLowerCase().contains(normalizedQuery);
    }).toList();
  }

  Future<List<Book>> getRandomBooks({int limit = 10}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final shuffled = List<Book>.from(_mockBooks)..shuffle();
    return shuffled.take(limit).toList();
  }
}

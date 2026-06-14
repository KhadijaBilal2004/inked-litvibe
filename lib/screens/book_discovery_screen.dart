import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../models/book.dart';
import '../services/book_service.dart';
import '../services/local_storage_service.dart';
import '../theme/app_colors.dart';
import '../utils/constants.dart';
import '../widgets/swipe_card.dart';

class BookDiscoveryScreen extends StatefulWidget {
  final String mood;

  const BookDiscoveryScreen({
    super.key,
    required this.mood,
  });

  @override
  State<BookDiscoveryScreen> createState() => _BookDiscoveryScreenState();
}

class _BookDiscoveryScreenState extends State<BookDiscoveryScreen> {
  late BookService _bookService;
  late CardSwiperController _cardSwiperController;
  List<Book> books = [];
  bool isLoading = true;
  bool showQuote = false;
  String? currentQuote;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _bookService = BookService();
    _cardSwiperController = CardSwiperController();
    _loadBooks();
  }

  @override
  void dispose() {
    _cardSwiperController.dispose();
    super.dispose();
  }

  Future<void> _loadBooks() async {
    try {
      final loadedBooks = await _bookService.getBooksByMood(widget.mood);
      setState(() {
        books = loadedBooks;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading books: $e')),
      );
    }
  }

  void _handleSwipe(Book book, CardSwiperDirection direction) {
    final user = LocalStorageService.instance.currentUser;
    if (direction == CardSwiperDirection.right && user != null) {
      LocalStorageService.instance.addToRead(user.id, book.id).catchError((error) {
        debugPrint('Could not save to-read book: $error');
      });
      LocalStorageService.instance.addToFavorites(user.id, book.id).catchError((error) {
        debugPrint('Could not save favorite book: $error');
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added "${book.title}" to your To Read list.')),
      );
    }
  }

  bool _onCardSwipe(int previousIndex, int? currentIndex, CardSwiperDirection direction) {
    if (previousIndex >= 0 && previousIndex < books.length) {
      final book = books[previousIndex];
      if (direction == CardSwiperDirection.right) {
        _handleSwipe(book, direction);
      }
    }

    setState(() {
      this.currentIndex = currentIndex ?? this.currentIndex;
      showQuote = false;
      currentQuote = null;
    });
    return true;
  }

  void _revealBook() {
    if (books.isNotEmpty && currentIndex < books.length) {
      final book = books[currentIndex];
      final quotes = book.quotes;

      setState(() {
        currentQuote = quotes.isNotEmpty
            ? quotes[DateTime.now().millisecondsSinceEpoch % quotes.length]
            : 'A great book awaits you...';
        showQuote = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Discover $widget.mood reads'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.secondaryAccent,
                  ),
                ),
              )
            : books.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.library_books,
                          size: 64,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(height: AppConstants.paddingLarge),
                        Text(
                          'No books found for this mood',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    child: Column(
                      children: [
                        Expanded(
                          child: CardSwiper(
                            controller: _cardSwiperController,
                            cardsCount: books.length,
                            onSwipe: _onCardSwipe,
                            cardBuilder: (context, index, horizonalThresholdPercentage, verticalThresholdPercentage) {
                              return SwipeCard(
                                book: books[index],
                                showQuote: showQuote && index == currentIndex,
                                currentQuote: currentQuote,
                                onRevealBook: _revealBook,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: AppConstants.paddingLarge),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            FloatingActionButton(
                              onPressed: () {
                                _cardSwiperController.swipe(CardSwiperDirection.left);
                              },
                              backgroundColor: AppColors.error,
                              child: const Icon(Icons.close),
                            ),
                            FloatingActionButton(
                              onPressed: () {
                                _cardSwiperController.swipe(CardSwiperDirection.right);
                              },
                              backgroundColor: AppColors.accentPink,
                              child: const Icon(Icons.favorite),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppConstants.paddingMedium),
                        Text(
                          '${currentIndex + 1} / ${books.length}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}

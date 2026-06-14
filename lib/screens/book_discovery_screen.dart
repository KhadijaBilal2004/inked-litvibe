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
  final ILocalStorageService? storage;

  const BookDiscoveryScreen({
    Key? key,
    required this.mood,
    this.storage,
  }) : super(key: key);

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
    final storage = widget.storage ?? LocalStorageService.instance as ILocalStorageService;
    final user = (storage as dynamic).currentUser as dynamic; // access currentUser if available
    if (direction == CardSwiperDirection.right && user != null) {
      try {
        (storage as dynamic).addToRead(user.id, book.id);
      } catch (e) {
        debugPrint('Could not save to-read book: $e');
      }
      try {
        (storage as dynamic).addToFavorites(user.id, book.id);
      } catch (e) {
        debugPrint('Could not save favorite book: $e');
      }
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
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: Text('Discover $widget.mood reads'),
        elevation: 0,
        backgroundColor: AppColors.bgLight,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? Center(
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
                        Icon(
                          Icons.library_books,
                          size: 64,
                          color: AppColors.textMuted,
                        ),
                        SizedBox(height: AppConstants.paddingLarge),
                        Text(
                          'No books found for this mood',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.all(AppConstants.paddingMedium),
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
                        SizedBox(height: AppConstants.paddingLarge),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            FloatingActionButton(
                              onPressed: () {
                                _cardSwiperController.swipe(CardSwiperDirection.left);
                              },
                              backgroundColor: AppColors.accentRed,
                              child: const Icon(Icons.close),
                            ),
                            FloatingActionButton(
                              onPressed: () {
                                _cardSwiperController.swipe(CardSwiperDirection.right);
                              },
                              backgroundColor: AppColors.accentGold,
                              child: const Icon(Icons.favorite),
                            ),
                          ],
                        ),
                        SizedBox(height: AppConstants.paddingMedium),
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

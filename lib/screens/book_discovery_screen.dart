import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../models/book.dart';
import '../services/book_service.dart';
import '../services/local_storage_service.dart';
import '../theme/app_colors.dart';
import '../utils/constants.dart';
import '../widgets/swipe_card.dart';
import '../services/quote_service.dart';

class BookDiscoveryScreen extends StatefulWidget {
  final String mood;
  final ILocalStorageService? storage;

  const BookDiscoveryScreen({
    super.key,
    required this.mood,
    this.storage,
  });

  @override
  State<BookDiscoveryScreen> createState() => _BookDiscoveryScreenState();
}

class _BookDiscoveryScreenState extends State<BookDiscoveryScreen> {
  late BookService _bookService;
  late CardSwiperController _cardSwiperController;
  List<Book> books = [];
  bool isLoading = true;
  bool isRevealed = false;
  bool _allSwiped = false;
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
      if (!mounted) return;
      setState(() {
        books = loadedBooks;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load books for this mood')),
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
      isRevealed = false;
    });
    return true;
  }

  void _onEnd() {
    setState(() => _allSwiped = true);
  }

  void _revealBook() {
    if (books.isNotEmpty && currentIndex < books.length) {
      setState(() {
        isRevealed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: Text('Discover ${widget.mood} reads'),
        elevation: 0,
        backgroundColor: AppColors.bgLight,
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
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                : _allSwiped
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_outline,
                                size: 64, color: AppColors.secondaryAccent),
                            const SizedBox(height: 16),
                            Text(
                              'You\'ve seen all the books!',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Head to your profile to see your saved reads.',
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () =>
                                  Navigator.of(context).pushReplacementNamed('/profile'),
                              icon: const Icon(Icons.person),
                              label: const Text('View Profile'),
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
                            onEnd: _onEnd,
                            cardBuilder: (context, index, horizonalThresholdPercentage, verticalThresholdPercentage) {
                              return SwipeCard(
                                book: books[index],
                                showQuote: !isRevealed || index != currentIndex,
                                currentQuote: QuoteService.generateQuoteForBook(books[index]),
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
                              heroTag: null,
                              onPressed: () {
                                _cardSwiperController.swipe(CardSwiperDirection.left);
                              },
                              backgroundColor: AppColors.accentRed,
                              child: const Icon(Icons.close),
                            ),
                            FloatingActionButton(
                              heroTag: null,
                              onPressed: () {
                                _cardSwiperController.swipe(CardSwiperDirection.right);
                              },
                              backgroundColor: AppColors.accentGold,
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

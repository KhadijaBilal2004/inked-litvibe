import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../models/book.dart';
import '../services/book_service.dart';
import '../services/local_storage_service.dart';
import '../theme/app_colors.dart';
import '../utils/constants.dart';
import '../widgets/swipe_card.dart';
import '../services/quote_service.dart';
import '../widgets/global_background.dart';
import '../widgets/bouncing_button.dart';

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
  ILocalStorageService get _storage => widget.storage ?? LocalStorageService.instance;
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
      
      final user = _storage.currentUser;
      final Set<String> libraryBookIds = {};
      
      if (user != null) {
        final prefs = await _storage.getPreferences(user.id);
        libraryBookIds.addAll(prefs.toReadBooks);
        libraryBookIds.addAll(prefs.favoriteBooks);
        libraryBookIds.addAll(prefs.readBooks);
        for (var col in prefs.collections) {
          libraryBookIds.addAll(col.bookIds);
        }
      }

      final filteredBooks = loadedBooks.where((b) {
        final lang = b.language?.toLowerCase() ?? '';
        final isEnglish = lang.isEmpty || lang == 'en' || lang == 'eng' || lang == 'english';
        final isNotInLibrary = !libraryBookIds.contains(b.id);
        return isEnglish && isNotInLibrary;
      }).toList();

      filteredBooks.shuffle();

      if (!mounted) return;
      setState(() {
        books = filteredBooks;
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
    final user = _storage.currentUser;
    if (direction == CardSwiperDirection.right && user != null) {
      try {
        _storage.addToRead(user.id, book.id);
      } catch (e) {
        debugPrint('Could not save to-read book: $e');
      }
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
        isRevealed = !isRevealed;
      });
    }
  }

  Future<void> _showAddToShelfDialog(Book book) async {
    final user = _storage.currentUser;
    if (user == null) return;
    
    final prefs = await _storage.getPreferences(user.id);
    final collections = prefs.collections;

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.bgCard,
          title: const Text('Add to Custom Shelf'),
          content: collections.isEmpty
              ? const Text('You have no custom shelves. Create one in your Profile!')
              : SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: collections.length,
                    itemBuilder: (context, index) {
                      final col = collections[index];
                      return ListTile(
                        title: Text(col.name),
                        onTap: () async {
                          final nav = Navigator.of(context);
                          final messenger = ScaffoldMessenger.of(context);
                          if (!col.bookIds.contains(book.id)) {
                            col.bookIds.add(book.id);
                            await _storage.saveCollection(user.id, col);
                          }
                          nav.pop();
                          messenger.showSnackBar(SnackBar(content: Text('Added to ${col.name}!')));
                        },
                      );
                    },
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: Text('Discover ${widget.mood} reads', style: const TextStyle(color: AppColors.textPrimary)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GlobalBackground(
        child: SafeArea(
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
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 400,
                                maxHeight: 600,
                              ),
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
                                      onLongPress: () => _showAddToShelfDialog(books[index]),
                                    );
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppConstants.paddingLarge),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            BouncingButton(
                              onPressed: () {
                                _cardSwiperController.swipe(CardSwiperDirection.left);
                              },
                              child: FloatingActionButton(
                                heroTag: null,
                                onPressed: null,
                                backgroundColor: AppColors.bgCard,
                                elevation: 0,
                                shape: CircleBorder(side: BorderSide(color: AppColors.textMuted.withValues(alpha: 0.3))),
                                child: const Icon(Icons.close, color: AppColors.textSecondary, size: 32),
                              ),
                            ),
                            BouncingButton(
                              onPressed: () {
                                _cardSwiperController.swipe(CardSwiperDirection.right);
                              },
                              child: FloatingActionButton(
                                heroTag: null,
                                onPressed: null,
                                backgroundColor: AppColors.bgCard,
                                elevation: 0,
                                shape: CircleBorder(side: BorderSide(color: AppColors.primaryAccent.withValues(alpha: 0.5))),
                                child: const Icon(Icons.favorite, color: AppColors.primaryAccent, size: 32),
                              ),
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
          ),
        );
  }
}

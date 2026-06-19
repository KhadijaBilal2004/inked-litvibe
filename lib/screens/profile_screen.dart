import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/book_service.dart';
import '../services/local_storage_service.dart';
import '../theme/app_colors.dart';
import '../utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'reader_screen.dart';
import 'quote_gallery_screen.dart';
import 'bookmarks_screen.dart';
import '../widgets/global_background.dart';
import '../widgets/bouncing_button.dart';
import '../widgets/glass_container.dart';
import '../models/custom_collection.dart';
import '../models/review.dart';

class ProfileScreen extends StatefulWidget {
  final ILocalStorageService? storage;

  const ProfileScreen({super.key, this.storage});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ILocalStorageService get _storage => widget.storage ?? LocalStorageService.instance;
  final BookService _bookService = BookService();
  bool _isLoading = true;
  List<Book> _toReadBooks = [];
  List<Book> _readBooks = [];
  List<Book> _favoriteBooks = [];
  List<CustomCollection> _collections = [];
  List<Review> _reviews = [];
  int _totalBooksRead = 0;
  int _estimatedPagesRead = 0;
  String _favoriteGenre = 'Unknown';
  final _toReadKey = GlobalKey();
  final _readKey = GlobalKey();
  final _favKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadShelf();
  }

  Future<void> _loadShelf() async {
    final user = _storage.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/auth');
      });
      return;
    }

    final preference =
        await _storage.getPreferences(user.id);
    final toRead = await _bookService.getBooksByIds(preference.toReadBooks);
    final read = await _bookService.getBooksByIds(preference.readBooks);
    final favorites = await _bookService.getBooksByIds(preference.favoriteBooks);

    if (!mounted) return;

    setState(() {
      _toReadBooks = toRead;
      _readBooks = read;
      _favoriteBooks = favorites;
      _collections = preference.collections;
      _reviews = preference.reviews;
      _totalBooksRead = _readBooks.length;
      _estimatedPagesRead = _readBooks.fold(0, (sum, book) => sum + book.pages);
      
      final moods = _readBooks.map((b) => b.mood).where((m) => m.isNotEmpty).toList();
      if (moods.isNotEmpty) {
        final Map<String, int> counts = {};
        for (var m in moods) {
          counts[m] = (counts[m] ?? 0) + 1;
        }
        var popular = counts.entries.reduce((a, b) => a.value > b.value ? a : b);
        _favoriteGenre = popular.key.toUpperCase();
      } else {
        _favoriteGenre = 'N/A';
      }

      _isLoading = false;
    });
  }

  void _scrollTo(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(context,
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    }
  }

  Widget _buildSection(String title, List<Book> books) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        if (books.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            ),
            child: Text(
              'No books added yet.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          )
        else
          SizedBox(
            height: 220,
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: books.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final book = books[index];
                final hasImage = book.coverImageUrl.isNotEmpty;
                
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    GestureDetector(
                      child: BouncingButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ReaderScreen(book: book, storage: _storage),
                            ),
                          ).then((_) => _loadShelf());
                        },
                        child: Container(
                          width: 120,
                          margin: const EdgeInsets.only(bottom: 8, right: 8), // Shadow space and Stack spacing
                          decoration: BoxDecoration(
                            color: AppColors.bgCard,
                            borderRadius:
                                BorderRadius.circular(AppConstants.radiusLarge),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(18)),
                                child: Hero(
                                  tag: 'book_cover_${book.id}_$title',
                                  child: hasImage 
                                      ? CachedNetworkImage(
                                          imageUrl: book.coverImageUrl,
                                          height: 100,
                                          width: 120,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Container(
                                            height: 100,
                                            width: 120,
                                            color: AppColors.bgCardDarker,
                                            child: const Center(
                                              child: CircularProgressIndicator(
                                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondaryAccent),
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) => Container(
                                            height: 100,
                                            width: 120,
                                            color: AppColors.bgCardDarker,
                                            child: const Icon(Icons.book,
                                                color: AppColors.textMuted, size: 32),
                                          ),
                                        )
                                      : Container(
                                        height: 100,
                                        width: 120,
                                        color: AppColors.bgCardDarker,
                                        padding: const EdgeInsets.all(8),
                                        child: Center(
                                          child: Text(
                                            book.title,
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: AppColors.textPrimary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        ),
                                      ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      book.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.titleSmall,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      book.author,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (title != 'All Added Books')
                      Positioned(
                        top: -4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () async {
                            final user = _storage.currentUser;
                            if (user == null) return;
                            final prefs = await _storage.getPreferences(user.id);
                            if (title == 'To Read') {
                              prefs.toReadBooks.remove(book.id);
                            } else if (title == 'Favorites') {
                              prefs.favoriteBooks.remove(book.id);
                            } else if (title == 'Read') {
                              prefs.readBooks.remove(book.id);
                            }
                            await _storage.savePreferences(prefs);
                            await _loadShelf();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('Removed "${book.title}" from $title.'),
                              ));
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ).animate(delay: Duration(milliseconds: 50 * index)).fade(duration: 300.ms).slideX(begin: 0.2, end: 0);
              },
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _storage.currentUser;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.bgLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pushReplacementNamed('/mood-selection');
            }
          },
        ),
        title: const Text('My Profile', style: TextStyle(color: AppColors.textPrimary)),
        actions: [
          const SizedBox(width: 16),
        ],
      ),
      body: GlobalBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GlassContainer(
                            padding: const EdgeInsets.all(18),
                            child: Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primaryAccent.withValues(alpha: 0.4),
                                        blurRadius: 15,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 36,
                                    backgroundColor: AppColors.primaryAccent,
                                    child: Text(
                                      (user?.name.isNotEmpty ?? false)
                                          ? user!.name[0].toUpperCase()
                                          : 'R',
                                      style: const TextStyle(
                                          color: AppColors.primaryLight,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user?.name ?? 'Reader',
                                        style: Theme.of(context)
                                            .textTheme.displaySmall,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        user?.email ?? 'No email',
                                        style:
                                            Theme.of(context).textTheme.bodySmall,
                                      ),
                                      const SizedBox(height: 12),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          _smallStat(
                                              '${_toReadBooks.length}', 'TBR'),
                                          _smallStat('${_favoriteBooks.length}',
                                              'Favorites'),
                                          _smallStat(
                                              '${_readBooks.length}', 'Read'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Reading Stats Dashboard
                          Text('Reading Stats', style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _buildStatCard('Total Books', '$_totalBooksRead', Icons.library_books)),
                              const SizedBox(width: 12),
                              Expanded(child: _buildStatCard('Pages Read', '$_estimatedPagesRead', Icons.auto_stories)),
                              const SizedBox(width: 12),
                              Expanded(child: _buildStatCard('Top Vibe', _favoriteGenre, Icons.mood)),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Navigation buttons to sections
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _scrollTo(_toReadKey),
                                  icon: const Icon(Icons.bookmark_border),
                                  label: const Text('My TBR', style: TextStyle(fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    shape: const StadiumBorder(),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _scrollTo(_favKey),
                                  icon: const Icon(Icons.favorite_border),
                                  label: const Text('Favorites', style: TextStyle(fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    shape: const StadiumBorder(),
                                    backgroundColor: AppColors.accentGold,
                                    foregroundColor: AppColors.primaryLight,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final btnWidth = (constraints.maxWidth - 16) / 3;
                              return Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                alignment: WrapAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: btnWidth,
                                    child: ElevatedButton.icon(
                                      onPressed: () => _scrollTo(_readKey),
                                      icon: const Icon(Icons.book),
                                      label: const FittedBox(child: Text('Read', style: TextStyle(fontWeight: FontWeight.bold))),
                                      style: ElevatedButton.styleFrom(
                                        elevation: 0,
                                        shape: const StadiumBorder(),
                                        backgroundColor: AppColors.primaryAccent,
                                        foregroundColor: AppColors.primaryLight,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: btnWidth,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) => const QuoteGalleryScreen()),
                                        );
                                      },
                                      icon: const Icon(Icons.format_quote_rounded),
                                      label: const FittedBox(child: Text('Quotes', style: TextStyle(fontWeight: FontWeight.bold))),
                                      style: ElevatedButton.styleFrom(
                                        elevation: 0,
                                        shape: const StadiumBorder(),
                                        backgroundColor: AppColors.secondaryAccent,
                                        foregroundColor: AppColors.primaryLight,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: btnWidth,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) => const BookmarksScreen()),
                                        );
                                      },
                                      icon: const Icon(Icons.bookmark_rounded),
                                      label: const FittedBox(child: Text('Bookmarks', style: TextStyle(fontWeight: FontWeight.bold))),
                                      style: ElevatedButton.styleFrom(
                                        elevation: 0,
                                        shape: const StadiumBorder(),
                                        backgroundColor: AppColors.accentGold,
                                        foregroundColor: AppColors.primaryLight,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 20),

                          // Explanatory line
                          Text(
                            'Your shelf — any book you add in Discovery will appear below in the appropriate section.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 18),

                          // Sections with keys for scroll targeting
                          Container(
                              key: _toReadKey,
                              child: _buildSection('To Read', _toReadBooks)),
                          const SizedBox(height: 24),
                          Container(
                              key: _readKey,
                              child: _buildSection('Read', _readBooks)),
                          const SizedBox(height: 24),
                          Container(
                              key: _favKey,
                              child: _buildSection('Favorites', _favoriteBooks)),
                          const SizedBox(height: 24),
                          _buildSection('All Added Books', _combinedShelf()),
                          const SizedBox(height: 32),
                          
                          // My Shelves Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('My Custom Shelves', style: Theme.of(context).textTheme.headlineSmall),
                              IconButton(
                                icon: const Icon(Icons.add_circle, color: AppColors.primaryAccent),
                                onPressed: _showCreateShelfDialog,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (_collections.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: AppColors.bgCard,
                                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                              ),
                              child: Text('No custom shelves yet.', style: Theme.of(context).textTheme.bodyMedium),
                            )
                          else
                            Column(
                              children: _collections.map((col) => ListTile(
                                title: Text(col.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('${col.bookIds.length} books'),
                                leading: const Icon(Icons.shelves, color: AppColors.primaryAccent),
                                tileColor: AppColors.bgCard,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                onTap: () => _showShelfDetailsDialog(col),
                              )).toList(),
                            ),
                            
                          const SizedBox(height: 32),
                          // My Reviews Section
                          Text('My Reviews', style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(height: 12),
                          if (_reviews.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: AppColors.bgCard,
                                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                              ),
                              child: Text('You haven\'t reviewed any books yet.', style: Theme.of(context).textTheme.bodyMedium),
                            )
                          else
                            Column(
                              children: _reviews.map((rev) => Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.bgCard,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(child: Text(rev.bookTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                                        Row(children: List.generate(5, (i) => Icon(Icons.star, size: 16, color: i < rev.rating ? AppColors.accentGold : Colors.grey))),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(rev.text, style: const TextStyle(height: 1.5)),
                                  ],
                                ),
                              )).toList(),
                            ),
                            
                          const SizedBox(height: 48),
                          // Logout Option
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                await _storage.logout();
                                if (!context.mounted) return;
                                Navigator.of(context).pushReplacementNamed('/auth');
                              },
                              icon: const Icon(Icons.logout),
                              label: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error.withValues(alpha: 0.1),
                                foregroundColor: AppColors.error,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Book> _combinedShelf() {
    final combined = <Book>[];
    final ids = <String>{};
    for (final b in _toReadBooks) {
      if (ids.add(b.id)) combined.add(b);
    }
    for (final b in _favoriteBooks) {
      if (ids.add(b.id)) combined.add(b);
    }
    for (final b in _readBooks) {
      if (ids.add(b.id)) combined.add(b);
    }
    return combined;
  }

  Widget _smallStat(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bgCardLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryAccent, size: 28),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  void _showCreateShelfDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.bgCard,
          title: const Text('Create New Custom Shelf'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter shelf name (e.g. Classics, Sci-Fi)',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = controller.text.trim();
                final user = _storage.currentUser;
                if (name.isNotEmpty && user != null) {
                  final newCol = CustomCollection(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: name,
                    bookIds: [],
                  );
                  await _storage.saveCollection(user.id, newCol);
                  await _loadShelf();
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Shelf "$name" created!')),
                    );
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showShelfDetailsDialog(CustomCollection collection) async {
    final user = _storage.currentUser;
    if (user == null) return;

    // Load books in the collection
    final books = await Future.wait(
      collection.bookIds.map((id) => _bookService.getBookById(id)),
    );
    final shelfBooks = books.whereType<Book>().toList();

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.bgCard,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(collection.name)),
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.error),
                    tooltip: 'Delete Shelf',
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Shelf'),
                          content: Text('Are you sure you want to delete the shelf "${collection.name}"?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true && mounted) {
                        await _storage.removeCollection(user.id, collection.id);
                        await _loadShelf();
                        if (mounted) {
                          Navigator.pop(context); // close details dialog
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Shelf "${collection.name}" deleted.')),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
              content: shelfBooks.isEmpty
                  ? const SizedBox(
                      height: 100,
                      child: Center(child: Text('No books on this shelf yet.')),
                    )
                  : SizedBox(
                      width: double.maxFinite,
                      height: 300,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: shelfBooks.length,
                        itemBuilder: (context, index) {
                          final book = shelfBooks[index];
                          return ListTile(
                            title: Text(book.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                            subtitle: Text(book.author, maxLines: 1, overflow: TextOverflow.ellipsis),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.menu_book, color: AppColors.primaryAccent),
                                  tooltip: 'Read Book',
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) => ReaderScreen(book: book, storage: _storage)),
                                    ).then((_) => _loadShelf());
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, color: AppColors.error),
                                  tooltip: 'Remove from Shelf',
                                  onPressed: () async {
                                    collection.bookIds.remove(book.id);
                                    await _storage.saveCollection(user.id, collection);
                                    await _loadShelf();
                                    final updatedBooks = await Future.wait(
                                      collection.bookIds.map((id) => _bookService.getBookById(id)),
                                    );
                                    setDialogState(() {
                                      shelfBooks.clear();
                                      shelfBooks.addAll(updatedBooks.whereType<Book>());
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          }
        );
      }
    );
  }

}

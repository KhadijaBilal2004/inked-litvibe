import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/book_service.dart';
import '../services/local_storage_service.dart';
import '../theme/app_colors.dart';
import '../utils/constants.dart';

class ProfileScreen extends StatefulWidget {
  final ILocalStorageService? storage;

  const ProfileScreen({Key? key, this.storage}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final BookService _bookService = BookService();
  bool _isLoading = true;
  List<Book> _toReadBooks = [];
  List<Book> _readBooks = [];
  List<Book> _favoriteBooks = [];
  final _toReadKey = GlobalKey();
  final _readKey = GlobalKey();
  final _favKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadShelf();
  }

  Future<void> _loadShelf() async {
    final user = LocalStorageService.instance.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/auth');
      });
      return;
    }

    final preference =
        await LocalStorageService.instance.getPreferences(user.id);
    final toRead = await Future.wait(
        preference.toReadBooks.map((id) => _bookService.getBookById(id)));
    final read = await Future.wait(
        preference.readBooks.map((id) => _bookService.getBookById(id)));
    final favorites = await Future.wait(
        preference.favoriteBooks.map((id) => _bookService.getBookById(id)));

    setState(() {
      _toReadBooks = toRead.whereType<Book>().toList();
      _readBooks = read.whereType<Book>().toList();
      _favoriteBooks = favorites.whereType<Book>().toList();
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
            height: 170,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: books.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final book = books[index];
                return Container(
                  width: 120,
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusLarge),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(18)),
                        child: Image.network(
                          book.coverImageUrl,
                          height: 100,
                          width: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            height: 100,
                            width: 120,
                            color: AppColors.bgCardDarker,
                            child: Icon(Icons.book,
                                color: AppColors.textMuted, size: 32),
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
                );
              },
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = LocalStorageService.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.bgLight,
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await LocalStorageService.instance.logout();
              Navigator.of(context).pushReplacementNamed('/auth');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppConstants.paddingLarge),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile header — paperback card style
                    Card(
                      color: AppColors.bgCardLight,
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 36,
                              backgroundColor: AppColors.primaryAccent,
                              child: Text(
                                (user?.name.isNotEmpty ?? false)
                                    ? user!.name[0].toUpperCase()
                                    : 'R',
                                style: TextStyle(
                                    color: AppColors.primaryLight,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700),
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
                                        .textTheme
                                        .displaySmall,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    user?.email ?? 'No email',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      _smallStat(
                                          '${_toReadBooks.length}', 'TBR'),
                                      const SizedBox(width: 12),
                                      _smallStat('${_favoriteBooks.length}',
                                          'Favorites'),
                                      const SizedBox(width: 12),
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
                    ),
                    const SizedBox(height: 18),

                    // Navigation buttons to sections
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _scrollTo(_toReadKey),
                            icon: const Icon(Icons.bookmark_border),
                            label: const Text('My TBR'),
                            style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _scrollTo(_favKey),
                            icon: const Icon(Icons.favorite_border),
                            label: const Text('Favorites'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentGold,
                              foregroundColor: AppColors.primaryLight,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _scrollTo(_readKey),
                            icon: const Icon(Icons.book),
                            label: const Text('Read'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryAccent,
                              foregroundColor: AppColors.primaryLight,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
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
                  ],
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
        children: [
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

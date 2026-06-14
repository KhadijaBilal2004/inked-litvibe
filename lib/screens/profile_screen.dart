import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/book_service.dart';
import '../services/local_storage_service.dart';
import '../theme/app_colors.dart';
import '../utils/constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final BookService _bookService = BookService();
  bool _isLoading = true;
  List<Book> _toReadBooks = [];
  List<Book> _readBooks = [];
  List<Book> _favoriteBooks = [];

  @override
  void initState() {
    super.initState();
    _loadShelf();
  }

  Future<void> _loadShelf() async {
    final user = LocalStorageService.instance.currentUser;
    if (user == null) {
      Navigator.of(context).pushReplacementNamed('/auth');
      return;
    }

    final preference = await LocalStorageService.instance.getPreferences(user.id);
    final toRead = await Future.wait(preference.toReadBooks.map((id) => _bookService.getBookById(id)));
    final read = await Future.wait(preference.readBooks.map((id) => _bookService.getBookById(id)));
    final favorites = await Future.wait(preference.favoriteBooks.map((id) => _bookService.getBookById(id)));

    setState(() {
      _toReadBooks = toRead.whereType<Book>().toList();
      _readBooks = read.whereType<Book>().toList();
      _favoriteBooks = favorites.whereType<Book>().toList();
      _isLoading = false;
    });
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
                    borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                        child: Image.network(
                          book.coverImageUrl,
                          height: 100,
                          width: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 100,
                            width: 120,
                            color: AppColors.bgCardDarker,
                            child: const Icon(Icons.book, color: AppColors.textMuted, size: 32),
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
      appBar: AppBar(
        title: const Text('Profile & Shelf'),
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
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${user?.name ?? 'Reader'}',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Here is your reading shelf. Swipe right in discovery to add books to To Read.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    _buildSection('To Read', _toReadBooks),
                    const SizedBox(height: 24),
                    _buildSection('Read', _readBooks),
                    const SizedBox(height: 24),
                    _buildSection('Favorites', _favoriteBooks),
                  ],
                ),
        ),
      ),
    );
  }
}

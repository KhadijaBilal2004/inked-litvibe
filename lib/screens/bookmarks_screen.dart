import 'package:flutter/material.dart';
import '../models/bookmark.dart';
import '../services/local_storage_service.dart';
import '../services/book_service.dart';
import '../theme/app_colors.dart';
import '../utils/constants.dart';
import 'reader_screen.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final BookService _bookService = BookService();
  List<Bookmark> _bookmarks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final user = LocalStorageService.instance.currentUser;
    if (user != null) {
      final prefs = await LocalStorageService.instance.getPreferences(user.id);
      setState(() {
        _bookmarks = prefs.bookmarks;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteBookmark(String id) async {
    final user = LocalStorageService.instance.currentUser;
    if (user != null) {
      await LocalStorageService.instance.removeBookmark(user.id, id);
      _loadBookmarks();
    }
  }
  
  Future<void> _openBookmark(Bookmark bookmark) async {
    final book = await _bookService.getBookById(bookmark.bookId);
    if (book != null && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ReaderScreen(book: book),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.bgLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('My Bookmarks', style: TextStyle(color: AppColors.textPrimary)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookmarks.isEmpty
              ? const Center(
                  child: Text(
                    'No bookmarks yet.\nTap the bookmark icon in the reader to save a page!',
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  itemCount: _bookmarks.length,
                  itemBuilder: (context, index) {
                    final bookmark = _bookmarks[index];
                    return GestureDetector(
                      onTap: () => _openBookmark(bookmark),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryAccent.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.bookmark_rounded, color: AppColors.primaryAccent),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      bookmark.bookTitle,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '"${bookmark.textSnippet}"',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppColors.textMuted,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                                onPressed: () => _deleteBookmark(bookmark.id),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

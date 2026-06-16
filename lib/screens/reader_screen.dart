import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/reader_settings.dart';
import '../services/local_storage_service.dart';
import '../models/saved_quote.dart';
import '../models/bookmark.dart';
import 'package:uuid/uuid.dart';
import '../services/book_service.dart';
import 'dart:ui';

import '../theme/app_colors.dart';
import '../utils/constants.dart';

class ReaderScreen extends StatefulWidget {
  final Book book;

  const ReaderScreen({super.key, required this.book});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  late ScrollController _scrollController;
  late PageController _pageController;
  ReaderSettings _settings = ReaderSettings();
  bool _isLoading = true;
  List<String> _pages = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _pageController = PageController();
    _loadInitialData();
    _scrollController.addListener(_saveProgress);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  List<String> _chunkText(String text, double fontSize) {
    if (text.isEmpty) return ['No text available.'];
    // Very rough estimation: 800 chars fits at size 18.0
    int approxCharsPerPage = ((18.0 / fontSize) * 800).toInt(); 
    List<String> pages = [];
    int start = 0;
    while (start < text.length) {
      int end = start + approxCharsPerPage;
      if (end >= text.length) {
        pages.add(text.substring(start).trim());
        break;
      }
      int lastSpace = text.lastIndexOf(RegExp(r'\s'), end);
      if (lastSpace <= start) {
         lastSpace = end; 
      }
      pages.add(text.substring(start, lastSpace).trim());
      start = lastSpace + 1;
    }
    return pages;
  }

  Future<void> _loadInitialData() async {
    final user = LocalStorageService.instance.currentUser;
    if (user != null) {
      final prefs = await LocalStorageService.instance.getPreferences(user.id);
      final offset = prefs.readingProgress[widget.book.id] ?? 0.0;
      
      String fullText = widget.book.fullText ?? '';
      debugPrint('ReaderScreen: Initial fullText length=${fullText.length}');
      if (fullText.isEmpty) {
        final dbBook = await BookService().getBookById(widget.book.id);
        debugPrint('ReaderScreen: Fetched dbBook=${dbBook?.title}, dbBook.fullText length=${dbBook?.fullText?.length}');
        if (dbBook != null && dbBook.fullText != null) {
          fullText = dbBook.fullText!;
        }
      }
      
      if (mounted) {
        setState(() {
          _settings = prefs.readerSettings;
          _pages = _chunkText(fullText, _settings.fontSize);
          debugPrint('ReaderScreen: _pages length=${_pages.length}');
          _isLoading = false;
        });
      }
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_settings.readingMode == 'vertical' && _scrollController.hasClients) {
          final maxExt = _scrollController.position.maxScrollExtent;
          _scrollController.jumpTo(offset > maxExt ? maxExt : offset);
        } else if (_settings.readingMode == 'paged' && _pageController.hasClients) {
          int initialPage = offset.toInt();
          if (initialPage >= _pages.length) initialPage = _pages.length - 1;
          _pageController.jumpToPage(initialPage);
        }
      });
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _saveProgress() {
    final user = LocalStorageService.instance.currentUser;
    if (user != null) {
      double offset = 0;
      if (_settings.readingMode == 'vertical' && _scrollController.hasClients) {
        offset = _scrollController.offset;
      } else if (_settings.readingMode == 'paged' && _pageController.hasClients) {
        offset = _pageController.page ?? 0;
      }
      LocalStorageService.instance.saveReadingProgress(
        user.id,
        widget.book.id,
        offset,
      );
    }
  }

  Color get _bgColor {
    switch (_settings.themeMode) {
      case 'dark':
        return Colors.grey[900]!;
      case 'sepia':
        return const Color(0xFFF4ECD8);
      case 'light':
      default:
        return AppColors.bgLight;
    }
  }

  Color get _textColor {
    switch (_settings.themeMode) {
      case 'dark':
        return Colors.grey[300]!;
      case 'sepia':
        return const Color(0xFF5B4636);
      case 'light':
      default:
        return AppColors.textPrimary.withValues(alpha: 0.85);
    }
  }

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCardLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: AppColors.textMuted.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Text('Reader Settings', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: AppConstants.paddingLarge),
                  
                  // Font Size
                  Text('Font Size: ${_settings.fontSize.toInt()}', style: Theme.of(context).textTheme.titleMedium),
                  Slider(
                    value: _settings.fontSize,
                    min: 12.0,
                    max: 32.0,
                    activeColor: AppColors.primaryAccent,
                    onChanged: (val) {
                      setModalState(() {
                        _settings = _settings.copyWith(fontSize: val);
                      });
                      setState(() {});
                    },
                    onChangeEnd: (_) => _persistSettings(),
                  ),
                  
                  // Font Family
                  Text('Font', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Row(
                    children: ['Georgia', 'Arial', 'Courier'].map((font) {
                      final isSel = _settings.fontFamily == font;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(font, style: TextStyle(fontFamily: font)),
                          selected: isSel,
                          selectedColor: AppColors.primaryAccent.withValues(alpha: 0.3),
                          onSelected: (sel) {
                            if (sel) {
                              setModalState(() {
                                _settings = _settings.copyWith(fontFamily: font);
                              });
                              setState(() {});
                              _persistSettings();
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppConstants.paddingLarge),

                  // Theme
                  Text('Theme', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Row(
                    children: [
                      _buildThemeBtn(setModalState, 'light', 'Light', Colors.white, Colors.black),
                      const SizedBox(width: 8),
                      _buildThemeBtn(setModalState, 'sepia', 'Sepia', const Color(0xFFF4ECD8), const Color(0xFF5B4636)),
                      const SizedBox(width: 8),
                      _buildThemeBtn(setModalState, 'dark', 'Dark', Colors.grey[900]!, Colors.white),
                    ],
                  ),
                  const SizedBox(height: AppConstants.paddingLarge),

                  // Reading Mode
                  Text('Reading Mode', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: _settings.readingMode == 'paged' ? AppColors.primaryAccent.withValues(alpha: 0.1) : null,
                            side: BorderSide(color: _settings.readingMode == 'paged' ? AppColors.primaryAccent : Colors.grey),
                          ),
                          onPressed: () {
                            setModalState(() {
                              _settings = _settings.copyWith(readingMode: 'paged');
                            });
                            setState(() {});
                            _persistSettings();
                          },
                          child: const Text('Paged (Flip)'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: _settings.readingMode == 'vertical' ? AppColors.primaryAccent.withValues(alpha: 0.1) : null,
                            side: BorderSide(color: _settings.readingMode == 'vertical' ? AppColors.primaryAccent : Colors.grey),
                          ),
                          onPressed: () {
                            setModalState(() {
                              _settings = _settings.copyWith(readingMode: 'vertical');
                            });
                            setState(() {});
                            _persistSettings();
                          },
                          child: const Text('Vertical (Scroll)'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        );
      }
    );
  }

  Widget _buildThemeBtn(StateSetter setModalState, String mode, String label, Color bg, Color fg) {
    final isSel = _settings.themeMode == mode;
    return GestureDetector(
      onTap: () {
        setModalState(() {
          _settings = _settings.copyWith(themeMode: mode);
        });
        setState(() {});
        _persistSettings();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          border: isSel ? Border.all(color: AppColors.primaryAccent, width: 2) : Border.all(color: Colors.transparent, width: 2),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _persistSettings() {
    final user = LocalStorageService.instance.currentUser;
    if (user != null) {
      LocalStorageService.instance.saveReaderSettings(user.id, _settings);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.bgLight,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: Text(widget.book.title, style: TextStyle(color: _textColor, fontSize: 16)),
        backgroundColor: _bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: _textColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_add_outlined),
            tooltip: 'Bookmark Page',
            onPressed: () async {
              final user = LocalStorageService.instance.currentUser;
              if (user != null) {
                String snippet = '';
                if (_settings.readingMode == 'paged' && _pages.isNotEmpty) {
                  snippet = _pages[_pageController.page?.toInt() ?? 0];
                } else if (widget.book.fullText != null) {
                  snippet = widget.book.fullText!;
                }
                if (snippet.length > 50) snippet = '${snippet.substring(0, 50)}...';

                await LocalStorageService.instance.saveBookmark(
                  user.id,
                  Bookmark(
                    id: const Uuid().v4(),
                    bookId: widget.book.id,
                    bookTitle: widget.book.title,
                    textSnippet: snippet.isEmpty ? 'Page Bookmark' : snippet,
                    offset: _settings.readingMode == 'paged' ? (_pageController.page ?? 0) : _scrollController.offset,
                    timestamp: DateTime.now(),
                  )
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Page bookmarked!')));
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: SafeArea(
        child: _settings.readingMode == 'paged' ? _buildPagedView() : _buildVerticalView(),
      ),
    );
  }

  Widget _buildContextMenu(BuildContext context, EditableTextState editableTextState, String pageText) {
    final List<ContextMenuButtonItem> buttonItems = editableTextState.contextMenuButtonItems;
    
    // Add custom Save Quote button
    buttonItems.add(ContextMenuButtonItem(
      label: 'Save Quote',
      onPressed: () async {
        final selection = editableTextState.textEditingValue.selection;
        if (!selection.isValid || selection.isCollapsed) return;
        final selectedText = selection.textInside(editableTextState.textEditingValue.text);
        
        final user = LocalStorageService.instance.currentUser;
        if (user != null) {
          await LocalStorageService.instance.saveQuote(
            user.id,
            SavedQuote(
              id: const Uuid().v4(),
              bookId: widget.book.id,
              bookTitle: widget.book.title,
              author: widget.book.author,
              text: selectedText,
              timestamp: DateTime.now(),
            )
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quote saved to Gallery!')));
          }
        }
        ContextMenuController.removeAny();
      },
    ));

    // Add custom Save Bookmark button
    buttonItems.add(ContextMenuButtonItem(
      label: 'Bookmark',
      onPressed: () async {
        final selection = editableTextState.textEditingValue.selection;
        if (!selection.isValid || selection.isCollapsed) return;
        final selectedText = selection.textInside(editableTextState.textEditingValue.text);
        
        final user = LocalStorageService.instance.currentUser;
        if (user != null) {
          await LocalStorageService.instance.saveBookmark(
            user.id,
            Bookmark(
              id: const Uuid().v4(),
              bookId: widget.book.id,
              bookTitle: widget.book.title,
              textSnippet: selectedText.length > 50 ? '${selectedText.substring(0, 50)}...' : selectedText,
              offset: _settings.readingMode == 'paged' ? (_pageController.page ?? 0) : _scrollController.offset,
              timestamp: DateTime.now(),
            )
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bookmark saved!')));
          }
        }
        ContextMenuController.removeAny();
      },
    ));

    return AdaptiveTextSelectionToolbar.buttonItems(
      anchors: editableTextState.contextMenuAnchors,
      buttonItems: buttonItems,
    );
  }

  Widget _buildPagedView() {
    if (_pages.isEmpty) return const Center(child: Text('No text available.'));
    
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
        },
      ),
      child: PageView.builder(
      controller: _pageController,
      onPageChanged: (_) => _saveProgress(),
      itemCount: _pages.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingXLarge,
            vertical: AppConstants.paddingLarge,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (index == 0) ...[
                Text(
                  widget.book.title,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: _textColor,
                        fontFamily: _settings.fontFamily,
                      ),
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                Text(
                  'by ${widget.book.author}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: _textColor.withValues(alpha: 0.7),
                        fontStyle: FontStyle.italic,
                        fontFamily: _settings.fontFamily,
                      ),
                ),
                const SizedBox(height: AppConstants.paddingXLarge),
              ],
              Expanded(
                child: SelectableText(
                  _pages[index],
                  contextMenuBuilder: (context, editableTextState) => _buildContextMenu(context, editableTextState, _pages[index]),
                  style: TextStyle(
                    height: 1.8,
                    fontSize: _settings.fontSize,
                    fontFamily: _settings.fontFamily,
                    color: _textColor,
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '${index + 1} / ${_pages.length}',
                    style: TextStyle(color: _textColor.withValues(alpha: 0.5), fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ));
  }

  Widget _buildVerticalView() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingXLarge,
        vertical: AppConstants.paddingLarge,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.book.title,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: _textColor,
                  fontFamily: _settings.fontFamily,
                ),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            'by ${widget.book.author}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: _textColor.withValues(alpha: 0.7),
                  fontStyle: FontStyle.italic,
                  fontFamily: _settings.fontFamily,
                ),
          ),
          const SizedBox(height: AppConstants.paddingXLarge),
          SelectableText(
            widget.book.fullText ?? 'No text available for this book.',
            contextMenuBuilder: (context, editableTextState) => _buildContextMenu(context, editableTextState, widget.book.fullText ?? ''),
            style: TextStyle(
              height: 1.8,
              fontSize: _settings.fontSize,
              fontFamily: _settings.fontFamily,
              color: _textColor,
            ),
          ),
          const SizedBox(height: AppConstants.paddingXLarge * 2),
        ],
      ),
    );
  }
}

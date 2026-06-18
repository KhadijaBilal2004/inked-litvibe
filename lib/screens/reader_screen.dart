import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/reader_settings.dart';
import '../services/local_storage_service.dart';
import '../models/saved_quote.dart';
import '../models/bookmark.dart';
import '../models/chapter.dart';
import 'package:uuid/uuid.dart';
import '../services/book_service.dart';
import 'dart:ui';
import 'dart:async';

import '../theme/app_colors.dart';
import '../utils/constants.dart';
import '../widgets/glass_container.dart';
import '../models/highlight.dart';
import '../models/review.dart';

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
  bool _isFavorite = false;
  List<String> _pages = [];
  List<Chapter> _chapters = [];
  List<Highlight> _highlights = [];
  String _fullText = '';

  Timer? _saveTimer;

  String _normalizeText(String text) {
    if (text.isEmpty) return text;
    // Normalize newlines
    text = text.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    // Split by double/multiple newlines to identify paragraph breaks
    final paragraphs = text.split(RegExp(r'\n\s*\n+'));
    final processedParagraphs = paragraphs.map((p) {
      // Replace single newlines within a paragraph with a single space, and collapse spaces
      return p.replaceAll(RegExp(r'\n+'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    }).toList();
    // Rejoin paragraphs with double newlines
    return processedParagraphs.join('\n\n');
  }

  void _onScrollOrPageChanged() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 500), _saveProgress);
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _pageController = PageController();
    _loadInitialData();
    _scrollController.addListener(_onScrollOrPageChanged);
    _pageController.addListener(_onScrollOrPageChanged);
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _saveProgress();
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
          _isFavorite = prefs.favoriteBooks.contains(widget.book.id);
          _settings = prefs.readerSettings;
          _highlights = prefs.highlights.where((h) => h.bookId == widget.book.id).toList();
          _fullText = _normalizeText(fullText);
          _pages = _chunkText(_fullText, _settings.fontSize);
          _parseChapters(_fullText);
          debugPrint('ReaderScreen: _pages length=${_pages.length}, chapters=${_chapters.length}');
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

  void _parseChapters(String text) {
    _chapters.clear();
    final regex = RegExp(r'\b(CHAPTER|BOOK|PART)\s+[A-Za-z0-9IVXLC]+[^\n]*\n', caseSensitive: false);
    final matches = regex.allMatches(text);
    for (var match in matches) {
      final title = match.group(0)?.trim() ?? 'Chapter';
      if (title.length < 50) {
        _chapters.add(Chapter(
          id: const Uuid().v4(),
          title: title,
          offset: match.start,
        ));
      }
    }
  }

  void _jumpToChapter(Chapter chapter) {
    if (_fullText.isEmpty) return;
    Navigator.of(context).pop(); // close drawer
    final ratio = chapter.offset / _fullText.length;
    if (_settings.readingMode == 'vertical' && _scrollController.hasClients) {
      final maxExt = _scrollController.position.maxScrollExtent;
      _scrollController.animateTo(maxExt * ratio, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else if (_settings.readingMode == 'paged' && _pageController.hasClients) {
      final pageIndex = (ratio * _pages.length).toInt();
      _pageController.animateToPage(pageIndex, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  Future<void> _saveProgress() async {
    final user = LocalStorageService.instance.currentUser;
    if (user != null) {
      double offset = 0;
      double progress = 0;
      if (_settings.readingMode == 'vertical' && _scrollController.hasClients) {
        offset = _scrollController.offset;
        if (_scrollController.position.hasContentDimensions) {
          final maxExt = _scrollController.position.maxScrollExtent;
          progress = maxExt > 0 ? (_scrollController.offset / maxExt) * 100 : 0;
        }
      } else if (_settings.readingMode == 'paged' && _pages.isNotEmpty && _pageController.hasClients) {
        offset = _pageController.page ?? 0;
        final maxPage = _pages.length - 1;
        progress = maxPage > 0 ? ((_pageController.page ?? 0) / maxPage) * 100 : 0;
      }

      if (progress >= 99.0) {
        await LocalStorageService.instance.markAsRead(user.id, widget.book.id);
      }

      await LocalStorageService.instance.saveReadingProgress(
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
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return GlassContainer(
              margin: const EdgeInsets.all(8.0),
              borderRadius: 24,
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: SingleChildScrollView(
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
                      _onFontSizeChanged(val);
                    },
                  ),

                  // Line Spacing
                  Text('Line Spacing: ${_settings.lineSpacing.toStringAsFixed(1)}', style: Theme.of(context).textTheme.titleMedium),
                  Slider(
                    value: _settings.lineSpacing,
                    min: 1.0,
                    max: 3.0,
                    activeColor: AppColors.primaryAccent,
                    onChanged: (val) {
                      setModalState(() {
                        _settings = _settings.copyWith(lineSpacing: val);
                      });
                      _onLineSpacingChanged(val);
                    },
                  ),

                  // Margin
                  Text('Margin: ${_settings.margin.toInt()}', style: Theme.of(context).textTheme.titleMedium),
                  Slider(
                    value: _settings.margin,
                    min: 0.0,
                    max: 48.0,
                    activeColor: AppColors.primaryAccent,
                    onChanged: (val) {
                      setModalState(() {
                        _settings = _settings.copyWith(margin: val);
                      });
                      _onMarginChanged(val);
                    },
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
                              _onFontFamilyChanged(font);
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
                            _onReadingModeChanged('paged');
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
                            _onReadingModeChanged('vertical');
                          },
                          child: const Text('Vertical (Scroll)'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
        _onThemeModeChanged(mode);
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

  void _onReadingModeChanged(String newMode) {
    if (_settings.readingMode == newMode) return;

    double ratio = 0.0;
    if (_settings.readingMode == 'paged' && _pages.isNotEmpty) {
      final currentPage = _pageController.hasClients ? (_pageController.page ?? 0) : 0.0;
      ratio = (_pages.length > 1) ? currentPage / (_pages.length - 1) : 0.0;
    } else if (_settings.readingMode == 'vertical' && _scrollController.hasClients) {
      if (_scrollController.position.hasContentDimensions) {
        final maxExt = _scrollController.position.maxScrollExtent;
        ratio = maxExt > 0 ? _scrollController.offset / maxExt : 0.0;
      }
    }

    setState(() {
      _settings = _settings.copyWith(readingMode: newMode);
      _pages = _chunkText(_fullText, _settings.fontSize);
    });
    _persistSettings();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (newMode == 'paged' && _pageController.hasClients && _pages.isNotEmpty) {
        int newPage = (ratio * (_pages.length - 1)).round();
        if (newPage >= _pages.length) newPage = _pages.length - 1;
        if (newPage < 0) newPage = 0;
        _pageController.jumpToPage(newPage);
      } else if (newMode == 'vertical' && _scrollController.hasClients) {
        final maxExt = _scrollController.position.maxScrollExtent;
        _scrollController.jumpTo(ratio * maxExt);
      }
      _saveProgress();
    });
  }

  void _onFontSizeChanged(double newSize) {
    double ratio = 0.0;
    if (_settings.readingMode == 'paged' && _pages.isNotEmpty) {
      final currentPage = _pageController.hasClients ? (_pageController.page ?? 0) : 0.0;
      ratio = (_pages.length > 1) ? currentPage / (_pages.length - 1) : 0.0;
    }

    setState(() {
      _settings = _settings.copyWith(fontSize: newSize);
      _pages = _chunkText(_fullText, newSize);
    });

    if (_settings.readingMode == 'paged' && _pages.isNotEmpty) {
      int newPage = (ratio * (_pages.length - 1)).round();
      if (newPage >= _pages.length) newPage = _pages.length - 1;
      if (newPage < 0) newPage = 0;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(newPage);
      }
    }
    _persistSettings();
    _saveProgress();
  }

  void _onLineSpacingChanged(double newSpacing) {
    setState(() {
      _settings = _settings.copyWith(lineSpacing: newSpacing);
    });
    _persistSettings();
    _saveProgress();
  }

  void _onMarginChanged(double newMargin) {
    setState(() {
      _settings = _settings.copyWith(margin: newMargin);
    });
    _persistSettings();
    _saveProgress();
  }

  void _onFontFamilyChanged(String newFont) {
    setState(() {
      _settings = _settings.copyWith(fontFamily: newFont);
    });
    _persistSettings();
    _saveProgress();
  }

  void _onThemeModeChanged(String newTheme) {
    setState(() {
      _settings = _settings.copyWith(themeMode: newTheme);
    });
    _persistSettings();
    _saveProgress();
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
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border, color: _isFavorite ? AppColors.accentGold : null),
            tooltip: _isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
            onPressed: () async {
              final user = LocalStorageService.instance.currentUser;
              if (user != null) {
                final prefs = await LocalStorageService.instance.getPreferences(user.id);
                setState(() {
                  if (_isFavorite) {
                    prefs.favoriteBooks.remove(widget.book.id);
                  } else {
                    prefs.favoriteBooks.add(widget.book.id);
                  }
                  _isFavorite = !_isFavorite;
                });
                await LocalStorageService.instance.savePreferences(prefs);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(_isFavorite ? 'Added to Favorites!' : 'Removed from Favorites!'),
                  ));
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_add_outlined),
            tooltip: 'Bookmark Page',
            onPressed: () async {
              final user = LocalStorageService.instance.currentUser;
              if (user != null) {
                String snippet = '';
                if (_settings.readingMode == 'paged' && _pages.isNotEmpty) {
                  snippet = _pages[_pageController.page?.toInt() ?? 0];
                } else if (_fullText.isNotEmpty) {
                  snippet = _fullText;
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
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.format_list_bulleted_rounded),
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        backgroundColor: AppColors.bgCardLight,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Table of Contents', style: Theme.of(context).textTheme.headlineSmall),
              ),
              const Divider(),
              Expanded(
                child: _chapters.isEmpty
                    ? const Center(child: Text('No chapters found.'))
                    : ListView.builder(
                        itemCount: _chapters.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(_chapters[index].title),
                            onTap: () => _jumpToChapter(_chapters[index]),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: _settings.readingMode == 'paged' ? _buildPagedView() : _buildVerticalView(),
      ),
      bottomNavigationBar: _buildReadingProgressFooter(),
    );
  }

  Widget _buildReadingProgressFooter() {
    final Listenable? controller = _settings.readingMode == 'paged' ? _pageController : _scrollController;
    
    return AnimatedBuilder(
      animation: controller ?? const AlwaysStoppedAnimation(0),
      builder: (context, _) {
        double progress = 0;
        if (_settings.readingMode == 'paged' && _pages.isNotEmpty && _pageController.hasClients) {
          try {
            final maxPage = _pages.length - 1;
            progress = maxPage > 0 ? ((_pageController.page ?? 0) / maxPage) * 100 : 0;
          } catch (_) {
            progress = 0;
          }
        } else if (_settings.readingMode == 'vertical' && _scrollController.hasClients) {
          try {
            if (_scrollController.position.hasContentDimensions) {
              final maxExt = _scrollController.position.maxScrollExtent;
              progress = maxExt > 0 ? (_scrollController.offset / maxExt) * 100 : 0;
            }
          } catch (_) {
            progress = 0;
          }
        }
        return Container(
          color: _bgColor,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Text(
            '${progress.clamp(0, 100).toStringAsFixed(1)}% Read',
            textAlign: TextAlign.center,
            style: TextStyle(color: _textColor.withValues(alpha: 0.6), fontSize: 12),
          ),
        );
      }
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

    buttonItems.add(ContextMenuButtonItem(
      label: 'Highlight',
      onPressed: () async {
        final selection = editableTextState.textEditingValue.selection;
        if (!selection.isValid || selection.isCollapsed) return;
        final selectedText = selection.textInside(editableTextState.textEditingValue.text);
        
        final user = LocalStorageService.instance.currentUser;
        if (user != null) {
          final newHighlight = Highlight(
            id: const Uuid().v4(),
            bookId: widget.book.id,
            bookTitle: widget.book.title,
            textSnippet: selectedText,
            colorHex: '#FFF9A6', // default soft yellow
            timestamp: DateTime.now(),
          );
          await LocalStorageService.instance.saveHighlight(user.id, newHighlight);
          if (mounted) {
            setState(() {
              _highlights.add(newHighlight);
            });
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Text highlighted!')));
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
      onPageChanged: (_) => _onScrollOrPageChanged(),
      itemCount: _pages.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: _settings.margin,
            vertical: _settings.margin,
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
                child: SelectableText.rich(
                  _buildHighlightedText(_pages[index]),
                  contextMenuBuilder: (context, editableTextState) => _buildContextMenu(context, editableTextState, _pages[index]),
                  style: TextStyle(
                    height: _settings.lineSpacing,
                    fontSize: _settings.fontSize,
                    fontFamily: _settings.fontFamily,
                    color: _textColor,
                  ),
                ),
              ),
              if (index == _pages.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () => _showReviewPrompt(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryAccent,
                        foregroundColor: AppColors.primaryLight,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Rate & Review Book'),
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
      padding: EdgeInsets.symmetric(
        horizontal: _settings.margin,
        vertical: _settings.margin,
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
          SelectableText.rich(
            _buildHighlightedText(_fullText.isEmpty ? 'No text available for this book.' : _fullText),
            contextMenuBuilder: (context, editableTextState) => _buildContextMenu(context, editableTextState, _fullText),
            style: TextStyle(
              height: _settings.lineSpacing,
              fontSize: _settings.fontSize,
              fontFamily: _settings.fontFamily,
              color: _textColor,
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton(
              onPressed: () => _showReviewPrompt(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryAccent,
                foregroundColor: AppColors.primaryLight,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Rate & Review Book'),
            ),
          ),
          SizedBox(height: _settings.margin * 2),
        ],
      ),
    );
  }

  void _showReviewPrompt() {
    double _rating = 0;
    final _reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.bgCard,
              title: const Text('Rate this Book'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      return IconButton(
                        icon: Icon(
                          Icons.star,
                          color: i < _rating ? AppColors.accentGold : Colors.grey,
                          size: 32,
                        ),
                        onPressed: () {
                          setDialogState(() => _rating = (i + 1).toDouble());
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _reviewController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Write your review...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final user = LocalStorageService.instance.currentUser;
                    if (user != null) {
                      final review = Review(
                        id: const Uuid().v4(),
                        bookId: widget.book.id,
                        bookTitle: widget.book.title,
                        rating: _rating,
                        text: _reviewController.text,
                        timestamp: DateTime.now(),
                      );
                      await LocalStorageService.instance.saveReview(user.id, review);
                      if (mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review saved!')));
                      }
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          }
        );
      }
    );
  }

  TextSpan _buildHighlightedText(String text) {
    if (_highlights.isEmpty) return TextSpan(text: text);
    
    List<TextSpan> spans = [];
    int currentIndex = 0;
    
    // Sort highlights by length descending to match longest first (naive approach)
    final sortedHighlights = List<Highlight>.from(_highlights)..sort((a, b) => b.textSnippet.length.compareTo(a.textSnippet.length));

    // Find all occurrences of all highlights
    // For MVP, we will just search for the exact snippet
    List<Map<String, dynamic>> matches = [];
    for (var h in sortedHighlights) {
      if (h.textSnippet.isEmpty) continue;
      int idx = text.indexOf(h.textSnippet);
      while (idx != -1) {
        matches.add({'start': idx, 'end': idx + h.textSnippet.length, 'color': h.colorHex});
        idx = text.indexOf(h.textSnippet, idx + 1);
      }
    }
    
    matches.sort((a, b) => (a['start'] as int).compareTo(b['start'] as int));
    
    // Filter overlapping
    List<Map<String, dynamic>> nonOverlapping = [];
    int lastEnd = -1;
    for (var m in matches) {
      if (m['start'] >= lastEnd) {
        nonOverlapping.add(m);
        lastEnd = m['end'];
      }
    }
    
    for (var m in nonOverlapping) {
      if (m['start'] > currentIndex) {
        spans.add(TextSpan(text: text.substring(currentIndex, m['start'] as int)));
      }
      Color highlightColor = Color(int.parse((m['color'] as String).replaceFirst('#', '0xFF')));
      spans.add(TextSpan(
        text: text.substring(m['start'] as int, m['end'] as int),
        style: TextStyle(backgroundColor: highlightColor.withValues(alpha: 0.5)),
      ));
      currentIndex = m['end'] as int;
    }
    
    if (currentIndex < text.length) {
      spans.add(TextSpan(text: text.substring(currentIndex)));
    }
    
    return TextSpan(children: spans);
  }
}

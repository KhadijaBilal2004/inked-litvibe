import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/reader_settings.dart';
import '../services/local_storage_service.dart';
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
  ReaderSettings _settings = ReaderSettings();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _loadInitialData();
    _scrollController.addListener(_saveProgress);
  }

  Future<void> _loadInitialData() async {
    final user = LocalStorageService.instance.currentUser;
    if (user != null) {
      final prefs = await LocalStorageService.instance.getPreferences(user.id);
      final offset = prefs.readingProgress[widget.book.id] ?? 0.0;
      
      if (mounted) {
        setState(() {
          _settings = prefs.readerSettings;
          _isLoading = false;
        });
      }
      
      // Jump to saved offset after layout
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          final maxExt = _scrollController.position.maxScrollExtent;
          _scrollController.jumpTo(offset > maxExt ? maxExt : offset);
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
    if (user != null && _scrollController.hasClients) {
      LocalStorageService.instance.saveReadingProgress(
        user.id,
        widget.book.id,
        _scrollController.offset,
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: isSel ? AppColors.primaryAccent : Colors.grey.withValues(alpha: 0.3), width: 2),
          borderRadius: BorderRadius.circular(8),
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
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
              Text(
                widget.book.fullText ?? 'No text available for this book.',
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
        ),
      ),
    );
  }
}

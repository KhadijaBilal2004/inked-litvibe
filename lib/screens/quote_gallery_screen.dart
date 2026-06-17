import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import '../models/saved_quote.dart';
import '../services/local_storage_service.dart';
import '../theme/app_colors.dart';
import '../utils/constants.dart';
import '../widgets/global_background.dart';
import '../widgets/bouncing_button.dart';

class QuoteGalleryScreen extends StatefulWidget {
  const QuoteGalleryScreen({super.key});

  @override
  State<QuoteGalleryScreen> createState() => _QuoteGalleryScreenState();
}

class _QuoteGalleryScreenState extends State<QuoteGalleryScreen> {
  List<SavedQuote> _quotes = [];
  bool _isLoading = true;
  final Map<String, GlobalKey> _quoteKeys = {};

  @override
  void initState() {
    super.initState();
    _loadQuotes();
  }

  Future<void> _loadQuotes() async {
    final user = LocalStorageService.instance.currentUser;
    if (user != null) {
      final prefs = await LocalStorageService.instance.getPreferences(user.id);
      setState(() {
        _quotes = prefs.savedQuotes;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteQuote(String quoteId) async {
    final user = LocalStorageService.instance.currentUser;
    if (user != null) {
      await LocalStorageService.instance.removeQuote(user.id, quoteId);
      _loadQuotes();
    }
  }

  Future<void> _downloadQuote(SavedQuote quote) async {
    try {
      final key = _quoteKeys[quote.id];
      if (key == null || key.currentContext == null) return;
      
      RenderRepaintBoundary boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      
      Directory? downloadsDir = await getDownloadsDirectory();
      if (downloadsDir == null) {
        downloadsDir = await getApplicationDocumentsDirectory();
      }
      
      final safeTitle = quote.bookTitle.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final path = '${downloadsDir.path}/quote_${safeTitle}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(path);
      await file.writeAsBytes(pngBytes);
      
      if (Platform.isWindows) {
        Process.run('explorer.exe', ['/select,', path]);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Quote saved to Downloads folder!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save quote: $e')));
      }
    }
  }

  List<Color> _getGradientColors(String id) {
    int hash = id.hashCode.abs();
    final palettes = [
      [const Color(0xFFD4C1A9), const Color(0xFFF1E5D1)], // Sand
      [const Color(0xFFA3B18A), const Color(0xFFDAD7CD)], // Sage
      [const Color(0xFFCB997E), const Color(0xFFFFB4A2)], // Terracotta
      [const Color(0xFFB0A8B9), const Color(0xFFE5D9F2)], // Lavender ash
      [const Color(0xFF8D99AE), const Color(0xFFEDF2F4)], // Slate
      [const Color(0xFFD4A373), const Color(0xFFFAEDCB)], // Caramel
    ];
    return palettes[hash % palettes.length];
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
        title: const Text('Quote Gallery', style: TextStyle(color: AppColors.textPrimary)),
      ),
      body: GlobalBackground(
        child: SafeArea(
          child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _quotes.isEmpty
              ? const Center(
                  child: Text(
                    'No quotes saved yet.\nHighlight text in a book to save quotes!',
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  itemCount: _quotes.length,
                  itemBuilder: (context, index) {
                    final quote = _quotes[index];
                    _quoteKeys[quote.id] ??= GlobalKey();
                    final colors = _getGradientColors(quote.id);
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        RepaintBoundary(
                          key: _quoteKeys[quote.id],
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 8.0),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: colors,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.format_quote_rounded, size: 54, color: Colors.black.withValues(alpha: 0.3)),
                                  Text(
                                    quote.text,
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontFamily: 'Georgia',
                                      fontStyle: FontStyle.italic,
                                      color: Colors.black.withValues(alpha: 0.8),
                                      height: 1.6,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '- ${quote.bookTitle}',
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black.withValues(alpha: 0.8),
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                        Text(
                                          quote.author,
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Colors.black.withValues(alpha: 0.6),
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Action Buttons (Outside of the RepaintBoundary so they don't appear in the saved image)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppConstants.paddingXLarge),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              BouncingButton(
                                onPressed: () => _downloadQuote(quote),
                                child: TextButton.icon(
                                  icon: const Icon(Icons.download_rounded, color: AppColors.primaryAccent),
                                  label: const Text('Download', style: TextStyle(color: AppColors.primaryAccent)),
                                  onPressed: null,
                                ),
                              ),
                              BouncingButton(
                                onPressed: () => _deleteQuote(quote.id),
                                child: TextButton.icon(
                                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                                  label: const Text('Remove', style: TextStyle(color: AppColors.error)),
                                  onPressed: null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ),
    );
  }
}

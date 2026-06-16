import 'dart:math';
import 'package:flutter/material.dart';
import '../models/book.dart';
import '../theme/app_colors.dart';
import '../utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SwipeCard extends StatelessWidget {
  final Book book;
  final bool showQuote;
  final String? currentQuote;
  final VoidCallback onRevealBook;

  const SwipeCard({
    super.key,
    required this.book,
    required this.showQuote,
    this.currentQuote,
    required this.onRevealBook,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRevealBook,
      child: Card(
        color: AppColors.bgCard,
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.bgCard,
                AppColors.bgCardLight,
              ],
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            transitionBuilder: (Widget child, Animation<double> animation) {
              final rotateAnim = Tween(begin: pi, end: 0.0).animate(animation);
              return AnimatedBuilder(
                animation: rotateAnim,
                child: child,
                builder: (context, widget) {
                  final isUnder = (ValueKey(showQuote) != widget?.key);
                  var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.003;
                  tilt *= isUnder ? -1.0 : 1.0;
                  final value = isUnder ? min(rotateAnim.value, pi / 2) : rotateAnim.value;
                  return Transform(
                    transform: Matrix4.rotationY(value)..setEntry(3, 0, tilt),
                    alignment: Alignment.center,
                    child: widget,
                  );
                },
              );
            },
            layoutBuilder: (widget, list) => Stack(children: [widget!, ...list]),
            child: showQuote 
                ? _buildQuoteView(context, key: const ValueKey(true)) 
                : _buildBookView(context, key: const ValueKey(false)),
          ),
        ),
      ),
    );
  }

  Widget _buildQuoteView(BuildContext context, {Key? key}) {
    return Container(
      key: key,
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.format_quote,
            size: 48,
            color: AppColors.secondaryAccent,
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Text(
                  currentQuote ?? 'Loading quote...',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        height: 1.6,
                      ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.paddingXLarge),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
              vertical: AppConstants.paddingSmall,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              border: Border.all(color: AppColors.secondaryAccent),
            ),
            child: Text(
              'Tap to reveal the book',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.secondaryAccent,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookView(BuildContext context, {Key? key}) {
    final hasImage = book.coverImageUrl.isNotEmpty;
    
    return Stack(
      key: key,
      children: [
        // Background Image or Placeholder
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
            child: hasImage 
                ? CachedNetworkImage(
                    imageUrl: book.coverImageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.bgCardLight,
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondaryAccent),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.bgCardLight,
                      child: const Center(
                        child: Icon(Icons.broken_image, color: AppColors.textMuted, size: 48),
                      ),
                    ),
                  )
                : Container(
                    color: AppColors.bgCardLight,
                    padding: const EdgeInsets.all(AppConstants.paddingLarge),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              book.title,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppConstants.paddingMedium),
                            Text(
                              book.author,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppColors.textSecondary,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ),
        // Overlay Gradient
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                AppColors.bgCard.withValues(alpha: 0.95),
              ],
            ),
          ),
        ),
        // Content
        Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                book.title,
                style: Theme.of(context).textTheme.displaySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppConstants.paddingSmall),
              Text(
                'by ${book.author}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              Row(
                children: [
                  const Icon(Icons.star, color: AppColors.accentGold, size: 20),
                  const SizedBox(width: AppConstants.paddingSmall),
                  Text(
                    book.rating.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingMedium,
                      vertical: AppConstants.paddingSmall,
                    ),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusMedium),
                      color: AppColors.secondaryAccent.withValues(alpha: 0.2),
                    ),
                    child: Text(
                      book.mood.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.secondaryAccent,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

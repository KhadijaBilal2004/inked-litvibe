import 'package:flutter/material.dart';
import '../models/book.dart';
import '../theme/app_colors.dart';
import '../utils/constants.dart';

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
      onTap: showQuote ? onRevealBook : null,
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
          child: showQuote
              ? _buildQuoteView(context)
              : _buildBookView(context),
        ),
      ),
    );
  }

  Widget _buildQuoteView(BuildContext context) {
    return Container(
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
          Text(
            currentQuote ?? 'Loading quote...',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 18,
              fontStyle: FontStyle.italic,
              height: 1.6,
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
              'Tap to reveal the book →',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.secondaryAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookView(BuildContext context) {
    return Stack(
      children: [
        // Background Image
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
            image: DecorationImage(
              image: NetworkImage(book.coverImageUrl),
              fit: BoxFit.cover,
              onError: (exception, stackTrace) {},
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
                AppColors.bgCard.withValues(alpha: 0.9),
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
                      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
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

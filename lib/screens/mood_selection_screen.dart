import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';
import '../theme/app_colors.dart';
import '../utils/constants.dart';
import '../widgets/mood_button.dart';
import '../widgets/global_background.dart';

class MoodSelectionScreen extends StatefulWidget {
  final ILocalStorageService? storage;

  const MoodSelectionScreen({super.key, this.storage});

  @override
  State<MoodSelectionScreen> createState() => _MoodSelectionScreenState();
}

class _MoodSelectionScreenState extends State<MoodSelectionScreen> {
  String? selectedMood;
  bool _isNavigating = false;

  @override
  Widget build(BuildContext context) {
    final storage =
        widget.storage ?? LocalStorageService.instance as ILocalStorageService;
    final user = (storage as dynamic).currentUser;
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Icon(Icons.history_edu_rounded, color: AppColors.textPrimary, size: 28),
        ),
        centerTitle: true,
        title: Text(
          'Mood Dashboard', 
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.person_outline_rounded, color: AppColors.textPrimary, size: 28),
              onPressed: () => Navigator.of(context).pushNamed('/profile'),
            ),
          ),
        ],
      ),
      body: GlobalBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.paddingLarge,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                    child: Text(
                      'Welcome back, ${user?.name ?? 'Reader'}',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                    child: Text(
                      'How are you feeling today?',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 18,
                          ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingXLarge),
                  ...List.generate(AppConstants.moods.length, (index) {
                    final mood = AppConstants.moods[index];
                    final description = AppConstants.moodDescriptions[mood] ?? '';

                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppConstants.paddingMedium,
                        left: AppConstants.paddingLarge,
                        right: AppConstants.paddingLarge,
                      ),
                      child: MoodButton(
                        mood: mood,
                        label: description,
                        isSelected: selectedMood == mood,
                        onTap: () {
                          if (_isNavigating) return;
                          setState(() {
                            selectedMood = mood;
                            _isNavigating = true;
                          });
                          Future.delayed(const Duration(milliseconds: 150), () {
                            if (!mounted) {
                              _isNavigating = false;
                              return;
                            }
                            Navigator.of(context).pushNamed(
                              '/discovery',
                              arguments: mood,
                            ).then((_) {
                              if (mounted) {
                                setState(() {
                                  _isNavigating = false;
                                  selectedMood = null;
                                });
                              }
                            });
                          });
                        },
                      ),
                    );
                  }),
                  const SizedBox(height: AppConstants.paddingXLarge), // Bottom padding
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

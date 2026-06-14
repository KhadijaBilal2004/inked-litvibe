import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';
import '../theme/app_colors.dart';
import '../utils/constants.dart';
import '../widgets/mood_button.dart';

class MoodSelectionScreen extends StatefulWidget {
  final ILocalStorageService? storage;

  const MoodSelectionScreen({super.key, this.storage});

  @override
  State<MoodSelectionScreen> createState() => _MoodSelectionScreenState();
}

class _MoodSelectionScreenState extends State<MoodSelectionScreen> {
  String? selectedMood;

  @override
  Widget build(BuildContext context) {
    final storage =
        widget.storage ?? LocalStorageService.instance as ILocalStorageService;
    final user = (storage as dynamic).currentUser;
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.bgLight,
        title: const Text('Mood Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.of(context).pushNamed('/profile'),
          ),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back, ${user?.name ?? 'Reader'}',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a mood and let Inked find your next meaningful read.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: AppConstants.paddingXLarge),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppConstants.paddingMedium,
                    mainAxisSpacing: AppConstants.paddingMedium,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: AppConstants.moods.length,
                  itemBuilder: (context, index) {
                    final mood = AppConstants.moods[index];
                    final description =
                        AppConstants.moodDescriptions[mood] ?? '';

                    return MoodButton(
                      mood: mood,
                      label: description,
                      isSelected: selectedMood == mood,
                      onTap: () {
                        setState(() {
                          selectedMood = mood;
                        });
                        Future.delayed(AppConstants.shortDuration, () {
                          if (!mounted) return;
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (!mounted) return;
                            Navigator.of(context).pushNamed(
                              '/discovery',
                              arguments: mood,
                            );
                          });
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

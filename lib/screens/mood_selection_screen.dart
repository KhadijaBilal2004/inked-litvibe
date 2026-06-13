import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';
import '../theme/app_colors.dart';
import '../utils/constants.dart';
import '../widgets/mood_button.dart';

class MoodSelectionScreen extends StatefulWidget {
  const MoodSelectionScreen({Key? key}) : super(key: key);

  @override
  State<MoodSelectionScreen> createState() => _MoodSelectionScreenState();
}

class _MoodSelectionScreenState extends State<MoodSelectionScreen> {
  String? selectedMood;

  @override
  Widget build(BuildContext context) {
    final user = LocalStorageService.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text('Mood Dashboard'),
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
          padding: EdgeInsets.all(AppConstants.paddingLarge),
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
              SizedBox(height: AppConstants.paddingXLarge),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppConstants.paddingMedium,
                    mainAxisSpacing: AppConstants.paddingMedium,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: AppConstants.moods.length,
                  itemBuilder: (context, index) {
                    final mood = AppConstants.moods[index];
                    final description = AppConstants.moodDescriptions[mood] ?? '';

                    return MoodButton(
                      mood: mood,
                      label: description,
                      isSelected: selectedMood == mood,
                      onTap: () {
                        setState(() {
                          selectedMood = mood;
                        });
                        Future.delayed(AppConstants.shortDuration, () {
                          Navigator.of(context).pushNamed(
                            '/discovery',
                            arguments: mood,
                          );
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

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/constants.dart';
import 'mood_button.dart';

class MoodSelectionScreen extends StatefulWidget {
  const MoodSelectionScreen({Key? key}) : super(key: key);

  @override
  State<MoodSelectionScreen> createState() => _MoodSelectionScreenState();
}

class _MoodSelectionScreenState extends State<MoodSelectionScreen> {
  String? selectedMood;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('How are you feeling?'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select a mood to discover your next great read',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: AppConstants.paddingXLarge),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppConstants.paddingMedium,
                    mainAxisSpacing: AppConstants.paddingMedium,
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
                        // Navigate to book discovery screen
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

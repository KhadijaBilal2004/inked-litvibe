import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/mood_selection_screen.dart';
import 'screens/book_discovery_screen.dart';
import 'utils/constants.dart';

void main() {
  runApp(const InkedApp());
}

class InkedApp extends StatelessWidget {
  const InkedApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/mood-selection': (context) => const MoodSelectionScreen(),
        '/discovery': (context) {
          final mood = ModalRoute.of(context)?.settings.arguments as String?;
          return BookDiscoveryScreen(mood: mood ?? 'happy');
        },
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/discovery') {
          final mood = settings.arguments as String? ?? 'happy';
          return MaterialPageRoute(
            builder: (context) => BookDiscoveryScreen(mood: mood),
          );
        }
        return null;
      },
    );
  }
}

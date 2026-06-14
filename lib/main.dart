import 'package:flutter/material.dart';
import 'screens/auth_screen.dart';
import 'screens/book_discovery_screen.dart';
import 'screens/mood_selection_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/splash_screen.dart';
import 'services/local_storage_service.dart';
import 'theme/app_theme.dart';
import 'utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.init();
  runApp(const InkedApp());
}

class InkedApp extends StatelessWidget {
  const InkedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/auth': (context) => const AuthScreen(),
        '/mood-selection': (context) => const MoodSelectionScreen(),
        '/profile': (context) => const ProfileScreen(),
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

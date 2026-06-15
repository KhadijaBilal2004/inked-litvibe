import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'screens/auth_screen.dart';
import 'screens/book_discovery_screen.dart';
import 'screens/mood_selection_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'services/local_storage_service.dart';
import 'theme/app_theme.dart';
import 'utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  await LocalStorageService.init();
  runApp(const InkedApp());
}

class InkedApp extends StatelessWidget {
  const InkedApp({super.key});

  @override
  Widget build(BuildContext context) {
    final initialRoute = LocalStorageService.instance.currentUser != null
        ? '/profile'
        : '/welcome';

    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/splash': (context) => const SplashScreen(),
        '/auth': (context) => AuthScreen(storage: LocalStorageService.instance),
        '/mood-selection': (context) => MoodSelectionScreen(storage: LocalStorageService.instance),
        '/profile': (context) => ProfileScreen(storage: LocalStorageService.instance),
        '/discovery': (context) {
          final mood = ModalRoute.of(context)?.settings.arguments as String?;
          return BookDiscoveryScreen(mood: mood ?? 'happy', storage: LocalStorageService.instance);
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

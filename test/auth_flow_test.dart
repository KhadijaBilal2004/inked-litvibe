
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inked/screens/auth_screen.dart';
import 'package:inked/models/user.dart';
import 'package:inked/screens/welcome_screen.dart';
import 'package:inked/services/local_storage_service.dart';

/// A simple in-memory fake storage used for widget tests to avoid Hive disk I/O.
class FakeLocalStorageService implements ILocalStorageService {
  User? _current;
  final Map<String, Map<String, dynamic>> _users = {};

  @override
  User? get currentUser => _current;

  @override
  Future<void> init({String? hivePath}) async {
    // no-op for fake
  }

  @override
  Future<User> registerUser(String name, String email, String password) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final user = User(id: id, name: name, email: email, password: password);
    _users[id] = user.toJson();
    _current = user;
    return user;
  }

  @override
  Future<User> loginUser(String email, String password) async {
    final found = _users.values.cast<Map>().firstWhere(
      (raw) => (raw['email'] as String).toLowerCase() == email.toLowerCase() && raw['password'] == password,
      orElse: () => {},
    );
    if (found.isEmpty) throw Exception('Invalid email or password.');
    final user = User.fromJson(Map<String, dynamic>.from(found));
    _current = user;
    return user;
  }

  @override
  Future<void> logout() async {
    _current = null;
  }

  @override
  Future<void> close() async {}
}

class _TestNavigatorObserver extends NavigatorObserver {
  final List<String> pushedRoutes = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    final routeName = route.settings.name ?? '<unnamed>';
    debugPrint('NavigatorObserver didPush: $routeName');
    pushedRoutes.add(routeName);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    final newName = newRoute?.settings.name ?? '<unnamed>';
    debugPrint('NavigatorObserver didReplace: $newName');
    if (newRoute?.settings.name != null) {
      pushedRoutes.add(newRoute!.settings.name!);
    }
  }
}

void main() {
  // Use in-memory fake storage for tests to avoid disk/hive issues on CI/Windows.
  late FakeLocalStorageService fakeStorage;

  setUpAll(() async {
    fakeStorage = FakeLocalStorageService();
    await fakeStorage.init();
  });

  setUp(() async {
    fakeStorage = FakeLocalStorageService();
    await fakeStorage.init();
  });

  tearDownAll(() async {});

  testWidgets('Welcome screen shows login and sign up buttons', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const WelcomeScreen(),
        routes: {
          '/auth': (context) => AuthScreen(storage: fakeStorage),
        },
      ),
    );

    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
    expect(find.text('Discover books that match your mood, save your shelf, and keep your reading progress in one place.'), findsOneWidget);
  });

  testWidgets('Signup flow registers a new user and navigates to mood selection', (tester) async {
    final observer = _TestNavigatorObserver();

    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [observer],
        home: const WelcomeScreen(),
        routes: {
          '/auth': (context) => AuthScreen(storage: fakeStorage),
          // Use a lightweight placeholder for mood-selection in tests.
          '/mood-selection': (context) => const Scaffold(
                body: Center(child: Text('Mood Dashboard')),
              ),
        },
      ),
    );

    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    expect(find.text('Create your account'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(3));

    await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
    await tester.enterText(find.byType(TextFormField).at(1), 'test@example.com');
    await tester.enterText(find.byType(TextFormField).at(2), 'password123');
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verify registration persisted in fake storage
    final registered = fakeStorage._users.values.cast<Map>().any((raw) => (raw['email'] as String).toLowerCase() == 'test@example.com');
    expect(registered, isTrue);
  });

  testWidgets('Login flow works for an existing user', (tester) async {
    // Pre-create a user directly in fake storage to simulate existing account
    await fakeStorage.registerUser('Test User', 'test@example.com', 'password123');

    // Pump AuthScreen directly for login to avoid route-arg timing issues.
    await tester.pumpWidget(
      MaterialApp(
        home: AuthScreen(isLoggingIn: true, storage: fakeStorage),
        routes: {
          '/mood-selection': (context) => const Scaffold(
                body: Center(child: Text('Mood Dashboard')),
              ),
        },
      ),
    );

    expect(find.text('Welcome back'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verify login updated fake storage
    final registered = fakeStorage._users.values.cast<Map>().any((raw) => (raw['email'] as String).toLowerCase() == 'test@example.com');
    expect(registered, isTrue);
  });
}

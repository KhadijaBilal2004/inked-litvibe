import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:inked/main.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    
    // Mock path_provider MethodChannel to avoid MissingPluginException in widget test
    const MethodChannel('plugins.flutter.io/path_provider')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      return '.';
    });
    
    await Hive.initFlutter();
  });

  testWidgets('App smoke test – InkedApp renders without crashing',
      (WidgetTester tester) async {
    await tester.pumpWidget(const InkedApp());
    await tester.pump(); // let the first frame settle
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Advance the virtual clock past the 3-second splash transition timer
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:inked/main.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Hive.initFlutter();
  });

  testWidgets('App smoke test – InkedApp renders without crashing',
      (WidgetTester tester) async {
    await tester.pumpWidget(const InkedApp());
    await tester.pump(); // let the first frame settle
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

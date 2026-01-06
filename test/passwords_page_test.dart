import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/features/vault/passwords_page.dart';
import 'package:password_manager/providers/theme_provider.dart';
import 'package:password_manager/theme_service.dart';
import 'package:password_manager/theme_model.dart';
import 'package:password_manager/core/dbinit.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:mocktail/mocktail.dart';

class MockThemeService extends Mock implements ThemeService {}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  Future<void> populateDb() async {
    final db = await InitDB().dB;
    await db.delete('demo'); // Clear first
    await db.insert('demo', {
      'Website': 'test.com',
      'Username': 'user',
      'Email': 'email@test.com',
      'Password': 'pass',
      'category': 'Work',
    });
  }

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider(themeService: ThemeService())),
      ],
      child: MaterialApp(
        theme: ThemeData(extensions: [ThemeModel.bentoDefault.toBentoTheme()]),
        home: const PasswordsPage(),
      ),
    );
  }

  testWidgets('PasswordsPage renders list on mobile width', (WidgetTester tester) async {
    await populateDb();
    
    // Set small screen size
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle(); // Wait for DB load

    // Verify List View
    expect(find.byType(ListView), findsOneWidget);
    expect(find.text('test.com'), findsOneWidget);
    expect(find.text('user'), findsOneWidget);
    
    // Verify NOT GridView
    expect(find.byType(GridView), findsNothing);
  });
}

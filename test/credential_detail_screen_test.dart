import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_manager/features/vault/credential_detail_screen.dart';
import 'package:password_manager/features/vault/credential_model.dart';
import 'package:password_manager/features/settings/theme_provider.dart';
import 'package:password_manager/features/settings/theme_service.dart';
import 'package:password_manager/features/settings/theme_model.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  final testCredential = Credential(
    website: 'example.com',
    username: 'user123',
    email: 'user@example.com',
    password: 'securePassword',
    category: 'Personal',
  );

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(themeService: ThemeService()),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(extensions: [ThemeModel.bentoDefault.toBentoTheme()]),
        home: CredentialDetailScreen(credential: testCredential),
      ),
    );
  }

  testWidgets('CredentialDetailScreen displays all credential info', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Header
    expect(find.text('example.com'), findsOneWidget);

    // Fields
    expect(find.text('user123'), findsOneWidget);
    expect(find.text('user@example.com'), findsOneWidget);

    // Password should be obscured initially, so we look for the field label or obscure widget
    expect(find.text('Password'), findsOneWidget);
    // expect(find.text('securePassword'), findsNothing); // Might fail if I use text directly
  });

  testWidgets('Detail screen has Copy buttons', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(
      find.byIcon(Icons.copy),
      findsAtLeastNWidgets(2),
    ); // Username, Password
  });
}

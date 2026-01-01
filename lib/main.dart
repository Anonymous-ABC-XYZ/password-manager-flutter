import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:password_manager/home_screen.dart';
import 'package:password_manager/passwords_page.dart';
import 'package:password_manager/settings_screen.dart';
import 'package:password_manager/auth_wrapper.dart';
import 'package:password_manager/providers/auth_provider.dart';
import 'package:password_manager/providers/theme_provider.dart';
import 'package:password_manager/theme_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqlite3/open.dart';
import 'dart:io';
import 'dart:ffi'; // Required for DynamicLibrary
import 'bento_constants.dart';
import 'sidebar_navigation.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  if (Platform.isLinux) {
    open.overrideFor(
      OperatingSystem.linux,
      () => DynamicLibrary.open('libsqlcipher.so'),
    );
  } else if (Platform.isWindows) {
    open.overrideFor(
      OperatingSystem.windows,
      () => DynamicLibrary.open('sqlcipher.dll'),
    );
  } else if (Platform.isMacOS) {
    open.overrideFor(
      OperatingSystem.macOS,
      () => DynamicLibrary.open('libsqlcipher.dylib'),
    );
  }

  final themeService = ThemeService();
  final themeProvider = ThemeProvider(themeService: themeService);
  await themeProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider.value(value: themeProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void toggleTheme() {
    setState(() {
      if (_themeMode == ThemeMode.dark) {
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = ThemeMode.dark;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final bentoTheme = themeProvider.currentTheme.toBentoTheme();

        return MaterialApp(
          title: 'Password Manager',
          debugShowCheckedModeBanner: false,
          home: AuthWrapper(
            toggleTheme: toggleTheme,
            isDark: _themeMode == ThemeMode.dark,
          ),
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: bentoTheme.primary,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            extensions: [bentoTheme],
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: bentoTheme.primary,
              brightness: Brightness.dark,
              surface: bentoTheme.backgroundDark,
            ),
            useMaterial3: true,
            scaffoldBackgroundColor: bentoTheme.backgroundDark,
            extensions: [bentoTheme],
          ),
          themeMode: _themeMode,
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDark;

  const MyHomePage({
    super.key,
    required this.toggleTheme,
    required this.isDark,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = HomeScreen(); // "Vault" -> Add Entry / Home
      case 1:
        page = PasswordsPage(); // "Credentials" -> List
      case 2:
        page = SettingsScreen();
      default:
        // Handle placeholders or unimplemented pages
        page = const Center(child: Text("Coming Soon", style: TextStyle(color: Colors.white)));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth > 800;

        if (isDesktop) {
          return Scaffold(
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SidebarNavigation(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                  onThemeToggle: widget.toggleTheme,
                ),
                Expanded(
                  child: Container(
                    color: BentoColors.of(context).backgroundDark,
                    child: page,
                  ),
                ),
              ],
            ),
          );
        } else {
          return Scaffold(
            backgroundColor: BentoColors.of(context).backgroundDark,
            body: page,
            bottomNavigationBar: NavigationBar(
              onDestinationSelected: (int index) {
                setState(() {
                  selectedIndex = index;
                });
              },
              selectedIndex: selectedIndex > 2 ? 0 : selectedIndex, // Handling placeholders safely
              destinations: const <Widget>[
                NavigationDestination(
                  selectedIcon: Icon(Icons.lock),
                  icon: Icon(Icons.lock_outline),
                  label: 'Vault',
                ),
                NavigationDestination(
                  selectedIcon: Icon(Icons.list_alt),
                  icon: Icon(Icons.list),
                  label: 'Credentials',
                ),
                NavigationDestination(
                  selectedIcon: Icon(Icons.settings),
                  icon: Icon(Icons.settings_outlined),
                  label: 'Settings',
                ),
              ],
            ),
             floatingActionButton: FloatingActionButton(
               onPressed: widget.toggleTheme,
               child: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode),
             ),
          );
        }
      },
    );
  }
}

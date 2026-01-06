import 'dart:io';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:password_manager/features/vault/home_screen.dart';
import 'package:password_manager/features/vault/passwords_page.dart';
import 'package:password_manager/settings_screen.dart';
import 'package:password_manager/features/auth/auth_wrapper.dart';
import 'package:password_manager/features/auth/auth_provider.dart';
import 'package:password_manager/providers/theme_provider.dart';
import 'package:password_manager/theme_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqlite3/open.dart';
import 'package:password_manager/core/utils/bento_constants.dart';
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
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var bento = BentoColors.of(context);
    
    final List<Widget> pages = [
      HomeScreen(),
      PasswordsPage(),
      SettingsScreen(),
    ];

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
                      _pageController.jumpToPage(value);
                    });
                  },
                  onThemeToggle: widget.toggleTheme,
                ),
                Expanded(
                  child: Container(
                    color: bento.backgroundDark,
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: pages,
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          return Scaffold(
            backgroundColor: bento.backgroundDark,
            extendBody: true,
            body: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: pages,
            ),
            floatingActionButton: Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    bento.primary,
                    bento.primaryDark,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: bento.primary.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: () {
                  setState(() {
                    selectedIndex = 0;
                    _pageController.jumpToPage(0);
                  });
                },
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: const Icon(Icons.add, color: Colors.white, size: 32),
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: BottomAppBar(
              shape: const CircularNotchedRectangle(),
              notchMargin: 8.0,
              color: bento.surfaceDark.withOpacity(0.7),
              child: SizedBox(
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: Icon(
                        selectedIndex == 0 ? Icons.shield : Icons.shield_outlined,
                        color: selectedIndex == 0 ? bento.primary : bento.textMuted,
                        size: 28,
                      ),
                      onPressed: () {
                        setState(() {
                          selectedIndex = 0;
                          _pageController.jumpToPage(0);
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        selectedIndex == 1 ? Icons.key : Icons.key_outlined,
                        color: selectedIndex == 1 ? bento.primary : bento.textMuted,
                        size: 28,
                      ),
                      onPressed: () {
                        setState(() {
                          selectedIndex = 1;
                          _pageController.jumpToPage(1);
                        });
                      },
                    ),
                    const SizedBox(width: 48), // Gap for the FAB
                    IconButton(
                      icon: Icon(
                        selectedIndex == 2 ? Icons.settings : Icons.settings_outlined,
                        color: selectedIndex == 2 ? bento.primary : bento.textMuted,
                        size: 28,
                      ),
                      onPressed: () {
                        setState(() {
                          selectedIndex = 2;
                          _pageController.jumpToPage(2);
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
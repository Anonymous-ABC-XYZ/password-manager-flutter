import 'package:flutter/material.dart';
import '../theme_model.dart';
import '../theme_service.dart';

class ThemeProvider with ChangeNotifier {
  final ThemeService _themeService;
  ThemeModel _currentTheme = ThemeModel.bentoDefault;
  List<ThemeModel> _availableThemes = [
    ThemeModel.bentoDefault,
    ThemeModel.catppuccinMocha,
  ];

  ThemeProvider({required ThemeService themeService}) : _themeService = themeService;

  ThemeModel get currentTheme => _currentTheme;
  List<ThemeModel> get availableThemes => _availableThemes;

  Future<void> init() async {
    final selectedName = await _themeService.getSelectedThemeName();
    final customThemes = await _themeService.getCustomThemes();
    
    _availableThemes = [
      ThemeModel.bentoDefault,
      ThemeModel.catppuccinMocha,
      ...customThemes,
    ];

    _currentTheme = _availableThemes.firstWhere(
      (t) => t.name == selectedName,
      orElse: () => ThemeModel.bentoDefault,
    );
    notifyListeners();
  }

  Future<void> setTheme(ThemeModel theme) async {
    _currentTheme = theme;
    await _themeService.setSelectedThemeName(theme.name);
    notifyListeners();
  }

  Future<void> addTheme(ThemeModel theme) async {
    await _themeService.addCustomTheme(theme);
    _availableThemes.add(theme);
    notifyListeners();
  }
}

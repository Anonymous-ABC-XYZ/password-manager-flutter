import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:password_manager/features/settings/theme_model.dart';

class ThemeService {
  final File? _customFile;

  ThemeService({File? customFile}) : _customFile = customFile;

  Future<File> get _file async {
    if (_customFile != null) return _customFile;
    final directory = await getApplicationDocumentsDirectory();
    return File(join(directory.path, 'themes.json'));
  }

  Future<Map<String, dynamic>> _loadData() async {
    try {
      final file = await _file;
      if (await file.exists()) {
        final content = await file.readAsString();
        return jsonDecode(content);
      }
    } catch (e) {
      // Fallback
    }
    return {};
  }

  Future<void> _saveData(Map<String, dynamic> data) async {
    final file = await _file;
    await file.writeAsString(jsonEncode(data));
  }

  Future<String> getSelectedThemeName() async {
    final data = await _loadData();
    return data['selectedTheme'] as String? ?? 'Bento Default';
  }

  Future<void> setSelectedThemeName(String name) async {
    final data = await _loadData();
    data['selectedTheme'] = name;
    await _saveData(data);
  }

  Future<List<ThemeModel>> getCustomThemes() async {
    final data = await _loadData();
    final List<dynamic>? themesJson = data['customThemes'] as List<dynamic>?;
    if (themesJson == null) return [];
    return themesJson
        .map((e) => ThemeModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addCustomTheme(ThemeModel theme) async {
    final themes = await getCustomThemes();
    themes.add(theme);
    final data = await _loadData();
    data['customThemes'] = themes.map((e) => e.toJson()).toList();
    await _saveData(data);
  }
}

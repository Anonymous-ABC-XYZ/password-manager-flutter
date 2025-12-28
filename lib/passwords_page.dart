import 'package:flutter/material.dart';
import 'dbinit.dart';
import 'bento_constants.dart';
import 'credential_card.dart';
import 'credentials_header.dart';

class PasswordsPage extends StatefulWidget {
  const PasswordsPage({super.key});

  @override
  State<PasswordsPage> createState() => _PasswordsPageState();
}

class _PasswordsPageState extends State<PasswordsPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, Object?>> _allCredentials = [];
  List<Map<String, Object?>> _filteredCredentials = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDB();
  }

  Future<void> _loadDB() async {
    final db = await InitDB().dB;
    final result = await db.rawQuery("SELECT * FROM demo");
    if (mounted) {
      setState(() {
        _allCredentials = result;
        _filterCredentials();
        _isLoading = false;
      });
    }
  }

  void _filterCredentials() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCredentials = List.from(_allCredentials);
      } else {
        _filteredCredentials = _allCredentials.where((cred) {
          final website = cred['Website'].toString().toLowerCase();
          final username = cred['Username'].toString().toLowerCase();
          final email = cred['Email'].toString().toLowerCase();
          return website.contains(query) || username.contains(query) || email.contains(query);
        }).toList();
      }
    });
  }

  void removeSite(String websiteToDelete) async {
    var db = await InitDB().dB;
    await db.rawDelete('DELETE FROM demo WHERE Website=?', [
      websiteToDelete,
    ]);
    _loadDB(); // Reload list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BentoColors.backgroundDark,
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: BentoColors.primary))
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  CredentialsHeader(
                    count: _allCredentials.length,
                    searchController: _searchController,
                    onSearchChanged: _filterCredentials,
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: _filteredCredentials.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off, size: 64, color: BentoColors.surfaceHover),
                                const SizedBox(height: 16),
                                const Text(
                                  'No credentials found',
                                  style: TextStyle(color: BentoColors.textMuted, fontSize: 18),
                                ),
                              ],
                            ),
                          )
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              int crossAxisCount = 1;
                              if (constraints.maxWidth > 700) crossAxisCount = 2;
                              if (constraints.maxWidth > 1100) crossAxisCount = 3;
                              if (constraints.maxWidth > 1500) crossAxisCount = 4;

                              return GridView.builder(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 24,
                                  mainAxisSpacing: 24,
                                  childAspectRatio: 0.85, // Adjust as needed
                                  mainAxisExtent: 360, // Fixed height for consistency
                                ),
                                itemCount: _filteredCredentials.length,
                                itemBuilder: (context, index) {
                                  final item = _filteredCredentials[index];
                                  return CredentialCard(
                                    website: item['Website'].toString(),
                                    username: item['Username'].toString(),
                                    email: item['Email'].toString(),
                                    password: item['Password'].toString(),
                                    onDelete: () => removeSite(item['Website'].toString()),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
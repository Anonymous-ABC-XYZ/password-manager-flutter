import 'package:flutter/material.dart';
import 'dbinit.dart';
import 'bento_constants.dart';
import 'credential_card.dart';
import 'credentials_header.dart';
import 'category_selector.dart';
import 'category_filter_bar.dart';

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
  String? _selectedFilterCategory;

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
      _filteredCredentials = _allCredentials.where((cred) {
        // Text Search
        final website = cred['Website'].toString().toLowerCase();
        final username = cred['Username'].toString().toLowerCase();
        final email = cred['Email'].toString().toLowerCase();
        final matchesQuery = query.isEmpty || website.contains(query) || username.contains(query) || email.contains(query);
        
        // Category Filter
        final category = cred['category']?.toString();
        final matchesCategory = _selectedFilterCategory == null || category == _selectedFilterCategory;

        return matchesQuery && matchesCategory;
      }).toList();
    });
  }

  void removeSite(String websiteToDelete) async {
    var db = await InitDB().dB;
    await db.rawDelete('DELETE FROM demo WHERE Website=?', [
      websiteToDelete,
    ]);
    _loadDB(); // Reload list
  }

  void editSite(String website, String newUsername, String newEmail, String newPassword, String? newCategory) async {
    var db = await InitDB().dB;
    await db.rawUpdate(
      'UPDATE demo SET Username = ?, Email = ?, Password = ?, category = ? WHERE Website = ?',
      [newUsername, newEmail, newPassword, newCategory, website],
    );
    _loadDB();
  }

  void _showEditDialog(Map<String, Object?> item) {
    final usernameController = TextEditingController(text: item['Username'].toString());
    final emailController = TextEditingController(text: item['Email'].toString());
    final passwordController = TextEditingController(text: item['Password'].toString());
    String? currentCategory = item['category']?.toString();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: BentoColors.of(context).surfaceDark,
              title: Text(
                'Edit ${item['Website']}',
                style: BentoStyles.header.copyWith(color: BentoColors.of(context).textWhite),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: usernameController,
                      style: BentoStyles.body.copyWith(color: BentoColors.of(context).textWhite),
                      decoration: InputDecoration(
                        labelText: 'Username',
                        labelStyle: BentoStyles.body.copyWith(color: BentoColors.of(context).textMuted),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: BentoColors.of(context).textMuted)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: BentoColors.of(context).primary)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: emailController,
                      style: BentoStyles.body.copyWith(color: BentoColors.of(context).textWhite),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: BentoStyles.body.copyWith(color: BentoColors.of(context).textMuted),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: BentoColors.of(context).textMuted)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: BentoColors.of(context).primary)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      style: BentoStyles.body.copyWith(color: BentoColors.of(context).textWhite),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: BentoStyles.body.copyWith(color: BentoColors.of(context).textMuted),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: BentoColors.of(context).textMuted)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: BentoColors.of(context).primary)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Category',
                      style: BentoStyles.body.copyWith(color: BentoColors.of(context).textMuted, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    CategorySelector(
                      initialValue: currentCategory,
                      onSelected: (cat) {
                        setDialogState(() {
                          currentCategory = cat;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: BentoStyles.body.copyWith(color: BentoColors.textMuted)),
                ),
                ElevatedButton(
                  onPressed: () {
                    editSite(
                      item['Website'].toString(),
                      usernameController.text,
                      emailController.text,
                      passwordController.text,
                      currentCategory,
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BentoColors.of(context).primary,
                    foregroundColor: BentoColors.of(context).onPrimary,
                  ),
                  child: Text('Save', style: BentoStyles.body.copyWith(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BentoColors.of(context).backgroundDark,
      body: _isLoading 
          ? Center(child: CircularProgressIndicator(color: BentoColors.of(context).primary))
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  CredentialsHeader(
                    count: _allCredentials.length,
                    searchController: _searchController,
                    onSearchChanged: _filterCredentials,
                  ),
                  const SizedBox(height: 16),
                  CategoryFilterBar(
                    selectedCategory: _selectedFilterCategory,
                    onSelected: (category) {
                      setState(() {
                        _selectedFilterCategory = category;
                        _filterCredentials();
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: _filteredCredentials.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off, size: 64, color: BentoColors.of(context).surfaceHover),
                                const SizedBox(height: 16),
                                Text(
                                  'No credentials found',
                                  style: TextStyle(color: BentoColors.of(context).textMuted, fontSize: 18),
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
                                    category: item['category']?.toString(),
                                    onDelete: () => removeSite(item['Website'].toString()),
                                    onEdit: () => _showEditDialog(item),
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
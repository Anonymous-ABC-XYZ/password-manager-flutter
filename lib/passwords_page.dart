import 'dart:ui';
import 'package:flutter/material.dart';
import 'core/dbinit.dart';
import 'package:password_manager/core/utils/bento_constants.dart';
import 'credentials_header.dart';
import 'category_selector.dart';
import 'category_filter_bar.dart';
import 'credential_model.dart';
import 'credential_focus_card.dart';

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
        final website = cred['Website'].toString().toLowerCase();
        final username = cred['Username'].toString().toLowerCase();
        final email = cred['Email'].toString().toLowerCase();
        final matchesQuery = query.isEmpty || website.contains(query) || username.contains(query) || email.contains(query);
        
        final category = cred['category']?.toString();
        final matchesCategory = _selectedFilterCategory == null || category == _selectedFilterCategory;

        return matchesQuery && matchesCategory;
      }).toList();
    });
  }

  void _showFocusView(Map<String, Object?> item) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(color: Colors.transparent),
            ),
            CredentialFocusCard(credential: Credential.fromMap(item)),
          ],
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: animation, child: child),
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
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
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
                        : ListView.separated(
                            padding: const EdgeInsets.only(bottom: 100),
                            itemCount: _filteredCredentials.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final item = _filteredCredentials[index];
                              final website = item['Website'].toString();
                              final username = item['Username'].toString();
                              
                              return Material(
                                color: BentoColors.of(context).surfaceDark,
                                borderRadius: BorderRadius.circular(20),
                                child: InkWell(
                                  onTap: () => _showFocusView(item),
                                  borderRadius: BorderRadius.circular(20),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: BentoColors.of(context).primary.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Center(
                                            child: Text(
                                              website.isNotEmpty ? website[0].toUpperCase() : '?',
                                              style: TextStyle(
                                                color: BentoColors.of(context).primary,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                website,
                                                style: TextStyle(
                                                  color: BentoColors.of(context).textWhite,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                username,
                                                style: TextStyle(
                                                  color: BentoColors.of(context).textMuted,
                                                  fontSize: 14,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          size: 16,
                                          color: BentoColors.of(context).textMuted.withValues(alpha: 0.5),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
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
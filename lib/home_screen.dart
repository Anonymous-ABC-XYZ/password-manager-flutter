import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:sqflite/sqflite.dart';

import 'dbinit.dart';
import 'bento_constants.dart';
import 'identity_tile.dart';
import 'notes_tile.dart';
import 'otp_island.dart';
import 'secure_credentials_tile.dart';
import 'home_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final websiteController = TextEditingController();
  final userNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final otpController = TextEditingController();
  
  String? _authKey;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    loadKey();
  }

  Future<void> loadKey() async {
    final storage = FlutterSecureStorage();
    var readKey = await storage.read(key: 'authkey');
    setState(() {
      _authKey = readKey;
    });
  }

  void searchFn(BuildContext context) async {
    final db = await InitDB().dB;
    var list = await db.rawQuery("SELECT Website FROM demo");

    List<String> allWebsites = [];

    for (var l = 0; l < list.length; l++) {
      allWebsites.add(list[l]['Website'].toString());
    }

    if (allWebsites.isEmpty) return;

    var correctWeb = extractOne(
      query: websiteController.text,
      choices: allWebsites,
    );
    
    var result = await db.rawQuery("SELECT * FROM demo WHERE Website=?", [
      correctWeb.choice,
    ]);
    
    if (result.isEmpty) return;

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return SizedBox(
            child: AlertDialog(
              backgroundColor: BentoColors.surfaceDark,
              title: Text("${result[0]['Website']}", style: const TextStyle(color: BentoColors.textWhite)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   ListTile(
                     title: const Text('Username', style: TextStyle(color: BentoColors.textMuted)),
                     subtitle: Text(result[0]['Username'].toString(), style: const TextStyle(color: BentoColors.textWhite)),
                     trailing: IconButton(
                       icon: const Icon(Icons.copy, color: BentoColors.primary),
                       onPressed: () => Clipboard.setData(ClipboardData(text: result[0]['Username'].toString())),
                     ),
                   ),
                   ListTile(
                     title: const Text('Email', style: TextStyle(color: BentoColors.textMuted)),
                     subtitle: Text(result[0]['Email'].toString(), style: const TextStyle(color: BentoColors.textWhite)),
                      trailing: IconButton(
                       icon: const Icon(Icons.copy, color: BentoColors.primary),
                       onPressed: () => Clipboard.setData(ClipboardData(text: result[0]['Email'].toString())),
                     ),
                   ),
                   ListTile(
                     title: const Text('Password', style: TextStyle(color: BentoColors.textMuted)),
                     subtitle: Text(result[0]['Password'].toString(), style: const TextStyle(color: BentoColors.textWhite)),
                      trailing: IconButton(
                       icon: const Icon(Icons.copy, color: BentoColors.primary),
                       onPressed: () => Clipboard.setData(ClipboardData(text: result[0]['Password'].toString())),
                     ),
                   ),
                ],
              ),
              actions: [
                 TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Close", style: TextStyle(color: BentoColors.primary)),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  void generatePassword() {
    var pass = [];
    var letters = <String>['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'];
    var numbers = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    var specialChars = ['!', '@', '#', '<', '%', '^', '&'];
    var numLetters = Random().nextInt(9) + 5;
    var numNumbers = Random().nextInt(16 - numLetters) + 4;
    var numSpecialChars = Random().nextInt(20 - (numNumbers + numLetters)) + 3;
    for (var i = 0; i < numLetters; i++) {
      var randomNo = Random().nextInt(25);
      var randomizedUppercase = Random().nextInt(2);
      if (randomizedUppercase == 0) {
        pass.add(letters[randomNo].toUpperCase());
      } else {
        pass.add(letters[randomNo]);
      }
    }
    for (var j = 0; j < numNumbers; j++) {
      var randomNum = Random().nextInt(9);
      pass.add(numbers[randomNum]);
    }
    for (var k = 0; k < numSpecialChars; k++) {
      var randomNumb = Random().nextInt(6);
      pass.add(specialChars[randomNumb]);
    }

    pass.shuffle();

    String password = pass.join('');
    passwordController.text = password;
    Clipboard.setData(ClipboardData(text: password));
  }

  void emailGenerator(BuildContext context) async {
    final dio = Dio();

    final headers = {
      'Accept': '*/*',
      'Accept-Encoding': 'gzip, deflate, br',
      'Accept-Language': 'en-US,en;q=0.5',
      'Authorization': _authKey,
      'Connection': 'keep-alive',
      'Content-Length': '0',
      'DNT': '1',
      'Host': 'quack.duckduckgo.com',
      'Origin': 'https://duckduckgo.com',
      'Referer': 'https://duckduckgo.com/',
      'Sec-Fetch-Dest': 'empty',
      'Sec-Fetch-Mode': 'cors',
      'Sec-Fetch-Site': 'same-site',
      'Sec-GPC': '1',
      'TE': 'trailers',
    };
    var emailAddress = "";

    try {
      Response response = await dio.post(
        "https://quack.duckduckgo.com/api/email/addresses",
        options: Options(headers: headers),
      );

      emailAddress = '${response.data['address']}@duck.com';
    } catch (e) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: BentoColors.surfaceDark,
              title: const Text("Error", style: TextStyle(color: BentoColors.textWhite)),
              content: const Text(
                "Could not fetch the email. \nCheck if you have a working Internet connection.",
                style: TextStyle(color: BentoColors.textMuted),
              ),
              actions: [
                 TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("OK", style: TextStyle(color: BentoColors.primary)),
                ),
              ],
            );
          },
        );
      }
    }
    emailController.text = emailAddress;
    Clipboard.setData(ClipboardData(text: emailAddress));
  }

  void addData(BuildContext context) async {
    var db = await InitDB().dB;
    var website = websiteController.text;
    var username = userNameController.text;
    var email = emailController.text;
    var password = passwordController.text;
    var category = _selectedCategory;

    await db.insert('demo', {
      'Website': website,
      'Username': username,
      'Email': email,
      'Password': password,
      'category': category,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
             backgroundColor: BentoColors.surfaceDark,
            title: const Text("Success", style: TextStyle(color: BentoColors.textWhite)),
            content: const Text("The details have been saved.", style: TextStyle(color: BentoColors.textMuted)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("OK", style: TextStyle(color: BentoColors.primary)),
              ),
            ],
          );
        },
      );
      websiteController.text = "";
      userNameController.text = "";
      emailController.text = "";
      passwordController.text = "";
      setState(() {
        _selectedCategory = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BentoColors.backgroundDark,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            HomeHeader(onSearch: () => searchFn(context)),
            const SizedBox(height: 32),
            
            // Bento Grid Layout
            LayoutBuilder(
              builder: (context, constraints) {
                bool isDesktop = constraints.maxWidth > 900;
                
                if (isDesktop) {
                   return Row(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       // Left Column
                       Expanded(
                         flex: 7,
                         child: Column(
                           children: [
                             IdentityTile(
                               websiteController: websiteController,
                               usernameController: userNameController,
                               onSearchWebsite: () => searchFn(context),
                               onSearchUsername: () => searchFn(context),
                               onCategorySelected: (cat) => _selectedCategory = cat,
                               initialCategory: _selectedCategory,
                             ),
                             const SizedBox(height: 24),
                             const NotesTile(),
                           ],
                         ),
                       ),
                       const SizedBox(width: 24),
                       // Right Column
                       Expanded(
                         flex: 5,
                         child: Column(
                           children: [
                             OtpIsland(controller: otpController),
                             const SizedBox(height: 24),
                             SecureCredentialsTile(
                               emailController: emailController,
                               passwordController: passwordController,
                               onAcquireEmail: () => emailGenerator(context),
                               onGeneratePassword: generatePassword,
                             ),
                           ],
                         ),
                       ),
                     ],
                   );
                } else {
                  // Mobile Layout
                   return Column(
                     children: [
                       IdentityTile(
                               websiteController: websiteController,
                               usernameController: userNameController,
                               onSearchWebsite: () => searchFn(context),
                               onSearchUsername: () => searchFn(context),
                               onCategorySelected: (cat) => _selectedCategory = cat,
                               initialCategory: _selectedCategory,
                       ),
                       const SizedBox(height: 24),
                       OtpIsland(controller: otpController),
                       const SizedBox(height: 24),
                       SecureCredentialsTile(
                               emailController: emailController,
                               passwordController: passwordController,
                               onAcquireEmail: () => emailGenerator(context),
                               onGeneratePassword: generatePassword,
                       ),
                       const SizedBox(height: 24),
                       const NotesTile(),
                       const SizedBox(height: 100), // Space for FAB
                     ],
                   );
                }
              }
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => addData(context),
        backgroundColor: BentoColors.primary,
        foregroundColor: BentoColors.onPrimary,
        elevation: 8,
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Entry',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

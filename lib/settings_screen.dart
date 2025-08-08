import 'dart:io';

import 'package:animated_button/animated_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'outlined_text_field.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final authController = TextEditingController();

  @override
  void initState() {
    super.initState();
    checkAuthKey(context);
  }

  Future<void> checkAuthKey(context) async {
    final storage = FlutterSecureStorage();
    String? readKey = await storage.read(key: 'authkey');
    if (readKey == null) {
      showDialog(context: context, builder: (BuildContext context) {
        return SizedBox(
          child: AlertDialog(title: Text('Enter the Auth Key')),
        );
      });
    }
    else {
      authController.text = readKey;
    }
  }


  Future<void> saveAuthKey(String authKey) async {
    final storage = FlutterSecureStorage();
    String? readKey = await storage.read(key: 'authkey');
    if (readKey == null) {
      await storage.write(key: 'authkey', value: authKey);
    }
    else {
      authController.text = authKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 60, 0, 10),
          child: Text(
            'Enter Auth Key for Duckduckgo',
            style: GoogleFonts.bricolageGrotesque(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 20, 40),
          child: OutlinedTextField('Auth', Icons.settings, authController, () {
            saveAuthKey(authController.text);
          }),
        ),
        AnimatedButton(
          width: MediaQuery.sizeOf(context).width - 280,
          height: 50,
          color: Theme.of(context).colorScheme.error,
          onPressed: () {
            saveAuthKey(authController.text);
          },
          child: Text(
            "Save",
            style: GoogleFonts.bricolageGrotesque(
              fontWeight: FontWeight.bold,
              fontSize: 23,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ],
    );
  }
}
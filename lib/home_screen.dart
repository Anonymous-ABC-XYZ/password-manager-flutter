import 'dart:math';
import 'package:animated_button/animated_button.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqflite/sqflite.dart';
import 'alert_button.dart';
import 'front_page_entries.dart';
import 'dbinit.dart';
import 'gmail_service.dart';
import 'otp_input_field.dart';

class HomeScreen extends StatefulWidget {
  final GmailService gmailService;

  const HomeScreen({super.key, required this.gmailService});

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
    var correctWeb = extractOne(
      query: websiteController.text,
      choices: allWebsites,
    );
    var result = await db.rawQuery("SELECT * FROM demo WHERE Website=?", [
      correctWeb.choice,
    ]);
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return SizedBox(
            child: AlertDialog(
              title: Text("${result[0]['Website']}"),
              actions: [
                Column(
                  children: [
                    AlertButton(result[0]['Username'], 'Username'),
                    AlertButton(result[0]['Email'], 'Email'),
                    AlertButton(result[0]['Password'], 'Password'),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll<Color>(
                            Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        child: Text(
                          "Ok",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
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
    var letters = <String>[
      'a',
      'b',
      'c',
      'd',
      'e',
      'f',
      'g',
      'h',
      'i',
      'j',
      'k',
      'l',
      'm',
      'n',
      'o',
      'p',
      'q',
      'r',
      's',
      't',
      'u',
      'v',
      'w',
      'x',
      'y',
      'z',
    ];
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

      emailAddress =
          '${response.data['address']}'
          '@duck.com';
    } catch (e) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text(
                "Could not fetch the email. \nCheck if you have a working Internet connection. ",
              ),
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

    await db.insert('demo', {
      'Website': website,
      'Username': username,
      'Email': email,
      'Password': password,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Success"),
            content: Text("The details have been saved."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("OK"),
              ),
            ],
          );
        },
      );
      websiteController.text = "";
      userNameController.text = "";
      emailController.text = "";
      passwordController.text = "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 20.0, 0, 0.0),
                  child: Text(
                    "Add Details",
                    style: GoogleFonts.bricolageGrotesque(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                ),
              ],
            ),
            FrontPageEntries("Website", Icons.language, websiteController, () {
              searchFn(context);
            }, "Search"),
            FrontPageEntries("Username", Icons.person, userNameController, () {
              searchFn(context);
            }, "Find"),

            FrontPageEntries("Email", Icons.email, emailController, () {
              emailGenerator(context);
            }, "Acquire"),

            FrontPageEntries(
              "Password",
              Icons.password,
              passwordController,
              () {
                generatePassword();
              },
              "Create",
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 40, 0, 40),
              child: OTPInputField(
                controller: otpController,
                gmailService: widget.gmailService,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 25.0, 0, 0),
              child: AnimatedButton(
                width: MediaQuery.sizeOf(context).width - 130,
                height: 70,
                color: Theme.of(context).colorScheme.error,
                onPressed: () {
                  addData(context);
                },
                child: Text(
                  "Add",
                  style: GoogleFonts.bricolageGrotesque(
                    fontWeight: FontWeight.bold,
                    fontSize: 23,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

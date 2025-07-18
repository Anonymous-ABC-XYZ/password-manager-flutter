import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqflite/sqflite.dart';
import 'color-schemes.dart';
import 'package:animated_button/animated_button.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:password_manager/dbinit.dart';

Future main() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  runApp(const MyApp());
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
    return MaterialApp(
      title: 'Password Manager',
      debugShowCheckedModeBanner: false,
      home: MyHomePage(
        toggleTheme: toggleTheme,
        isDark: _themeMode == ThemeMode.dark,
      ),
      theme: ThemeData(colorScheme: lightColorScheme),
      darkTheme: ThemeData(colorScheme: darkColorScheme),
      themeMode: _themeMode,
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
  var defaultIcon = Icon(Icons.light_mode);

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = HomeScreen();
      case 1:
        page = PasswordsPage();
      case 2:
        page = SettingsScreen();

      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              elevation: 500,
              groupAlignment: -1,
              extended: false,
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.password),
                  label: Text('Favorites'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings),
                  label: Text('Settings'),
                ),
              ],
              selectedIndex: selectedIndex,
              onDestinationSelected: (value) {
                setState(() {
                  selectedIndex = value;
                });
              },
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                    child: FloatingActionButton(
                      onPressed: () {
                        setState(() {
                          widget.toggleTheme();
                        });
                      },
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      child: Icon(
                        widget.isDark ? Icons.light_mode : Icons.dark_mode,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: page,
            ),
          ),
        ],
      ),
    );
  }
}

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
    print(result);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          child: AlertDialog(
            title: Text("${result[0]['Website']}"),
            actions: [
              Column(
                children: [
                  TextButton(
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: result[0]['Email'].toString()),
                      );
                    },
                    child: Text("Email: ${result[0]['Email']}"),
                  ),
                  TextButton(
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: result[0]['Password'].toString()),
                      );
                    },
                    child: Text("Password: ${result[0]['Password']}"),
                  ),
                  TextButton(
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: result[0]['Username'].toString()),
                      );
                    },
                    child: Text("Username: ${result[0]['Username']}"),
                  ),
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
                      child: Text("Ok"),
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
    print(pass);

    String password = pass.join('');
    passwordController.text = password;
    Clipboard.setData(ClipboardData(text: password));
  }

  void emailGenerator() async {
    final dio = Dio();
    const String authKey = '';

    final headers = {
      'Accept': '*/*',
      'Accept-Encoding': 'gzip, deflate, br',
      'Accept-Language': 'en-US,en;q=0.5',
      'Authorization': authKey,
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
    var emailAddr = "";

    try {
      Response response = await dio.post(
        "https://quack.duckduckgo.com/api/email/addresses",
        options: Options(headers: headers),
      );

      emailAddr =
          '${response.data['address']}'
          '@duck.com';
    } catch (e) {
      print('Error: $e');
    }
    emailController.text = emailAddr;
    Clipboard.setData(ClipboardData(text: emailAddr));
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

    print("Data inserted.");

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
                  padding: const EdgeInsets.fromLTRB(16.0, 20.0, 0, 0),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 50, 0, 50),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: OutlinedTextField(
                        "Website",
                        Icons.language,
                        websiteController,
                        () {
                          searchFn(context);
                        },
                      ),
                    ),
                    FrontPageButtons("Search", () {
                      searchFn(context);
                    }),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 30, 0, 50),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: OutlinedTextField(
                        "Username",
                        Icons.person,
                        userNameController,
                        () {
                          searchFn(context);
                        },
                      ),
                    ),
                    FrontPageButtons("Search", () {
                      searchFn(context);
                    }),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 30, 0, 60),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: OutlinedTextField(
                        "Email",
                        Icons.email,
                        emailController,
                        () {
                          emailGenerator();
                        },
                      ),
                    ),
                    FrontPageButtons("Acquire", () {
                      emailGenerator();
                    }),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 30, 0, 30),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: OutlinedTextField(
                        "Password",
                        Icons.password,
                        passwordController,
                        () {
                          generatePassword();
                        },
                      ),
                    ),
                    FrontPageButtons("Create", () {
                      generatePassword();
                    }),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 25.0, 0, 0),
              child: AnimatedButton(
                width: MediaQuery.sizeOf(context).width - 130,
                height: 70,
                color: Color(0xffDA253C),
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

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final authController = TextEditingController();

  void saveAuthKey() {}

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
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
            saveAuthKey();
          }),
        ),
        AnimatedButton(
          width: MediaQuery.sizeOf(context).width - 280,
          height: 50,
          color: Color(0xffDA253C),
          onPressed: () {
            saveAuthKey();
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

class PasswordsPage extends StatefulWidget {
  @override
  State<PasswordsPage> createState() => _PasswordsPageState();
}

class _PasswordsPageState extends State<PasswordsPage> {
  Future<List<Map<String, Object?>>> getDB() async {
    var db = await InitDB().dB;
    var result = await db.rawQuery("SELECT * FROM demo");
    return result;
  }

  void removeSite(String websiteToDelete) async {
    var db = await InitDB().dB;
    var count = await db.rawDelete('DELETE FROM demo WHERE Website=?', [
      websiteToDelete,
    ]);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, Object?>>>(
      future: getDB(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data == 0) {
          return Center(child: Text('No websites found!'));
        } else {
          // Use the data from the snapshot to build the list
          int itemCount = snapshot.data!.length;
          return ListView.builder(
            itemCount: itemCount,
            itemBuilder: (BuildContext context, int index) {
              final website = snapshot.data![index]["Website"]?.toString();
              final email = snapshot.data![index]["Email"].toString();
              final password = snapshot.data![index]["Password"].toString();
              final userName = snapshot.data![index]['Username'].toString();

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xff000000),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            website!,
                            style: GoogleFonts.bricolageGrotesque(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                            ),
                            onPressed: () {
                              removeSite(website);
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Boxes(identifier: userName, icon: Icons.person),
                      SizedBox(height: 15),
                      Boxes(identifier: email, icon: Icons.email),
                      SizedBox(height: 15),
                      Boxes(identifier: password, icon: Icons.password),
                      SizedBox(height: 15),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}

class Boxes extends StatelessWidget {
  const Boxes({super.key, required this.identifier, required this.icon});

  final String identifier;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Text(identifier),
            ),
          ),
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: identifier));
            },
            icon: Icon(Icons.copy),
          ),
        ],
      ),
    );
  }
}

class OutlinedTextField extends StatelessWidget {
  final String fieldName;
  final IconData fieldIcon;
  final TextEditingController controller;
  final Function function;

  const OutlinedTextField(
    this.fieldName,
    this.fieldIcon,
    this.controller,
    this.function,
  );

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18.0, 0, 0, 0),
      child: TextField(
        controller: controller,
        onSubmitted: (value) {
          function();
        },
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.circular(5.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.circular(5.5),
          ),
          prefixIcon: Icon(fieldIcon, color: theme.onSecondary),
          hintText: fieldName,
          hintStyle: GoogleFonts.bricolageGrotesque(color: theme.onSecondary),
          filled: true,
          fillColor: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }
}

class FrontPageButtons extends StatelessWidget {
  final String text;
  final Function function;

  const FrontPageButtons(this.text, this.function);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18.0, 0, 18.0, 0),
      child: SizedBox(
        width: 105,
        height: 50,
        child: Center(
          child: AnimatedButton(
            onPressed: () {
              function();
            },
            color: Theme.of(context).colorScheme.secondary,
            width: 105,
            height: 50,
            child: Text(
              text,
              style: GoogleFonts.bricolageGrotesque(
                color: Theme.of(context).colorScheme.onSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

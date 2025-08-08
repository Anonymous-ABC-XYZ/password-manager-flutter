import 'package:google_fonts/google_fonts.dart';

import 'boxes.dart';
import 'package:flutter/material.dart';

import 'dbinit.dart';

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
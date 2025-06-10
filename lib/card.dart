import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      backgroundColor: Color(0xFF0D0D0D), // dark background
      body: Center(child: InstantPixCard()),
    ),
    theme: ThemeData.dark(),
    debugShowCheckedModeBanner: false,
  ));
}

class InstantPixCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1A), // dark card color
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row with delete icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "InstantPix",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Icon(Icons.delete_outline, color: Colors.white54),
            ],
          ),
          SizedBox(height: 4),
          Text(
            "Last updated on 5 June 2022",
            style: TextStyle(fontSize: 12, color: Colors.white38),
          ),
          SizedBox(height: 16),
          // Password field imitation
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: List.generate(
                    8,
                        (index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Icon(Icons.circle, size: 10, color: Colors.white60),
                    ),
                  ),
                ),
                Icon(Icons.remove_red_eye_outlined, color: Colors.blueAccent),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

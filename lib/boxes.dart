import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
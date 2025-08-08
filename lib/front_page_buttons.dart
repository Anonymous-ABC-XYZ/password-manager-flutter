import 'package:animated_button/animated_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

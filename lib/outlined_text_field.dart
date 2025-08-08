import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


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
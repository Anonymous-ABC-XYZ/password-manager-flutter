import 'package:flutter/material.dart';

import 'front_page_buttons.dart';
import 'outlined_text_field.dart';

class FrontPageEntries extends StatelessWidget {
  final String fieldName;
  final IconData fieldIcon;
  final TextEditingController controller;
  final Function function;
  final String text;

  const FrontPageEntries(this.fieldName,
      this.fieldIcon,
      this.controller,
      this.function,
      this.text);

  @override
  Widget build(BuildContext context) {
    var theme = Theme
        .of(context)
        .colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 40, 0, 40),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: OutlinedTextField(
                fieldName,
                fieldIcon,
                controller,
                    () {
                  function();
                },
              ),
            ),
            FrontPageButtons(text, () {
              function();
            }),
          ],
        ),
      ),
    );
  }


}

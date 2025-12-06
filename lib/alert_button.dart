import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AlertButton extends StatelessWidget {

  final String data;
  final String dataType;

  const AlertButton(this.data, this.dataType);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Clipboard.setData(
          ClipboardData(text: data.toString()),
        );
      },
      child: Text("$dataType: $data", textAlign: TextAlign.start),
    );
  }
}
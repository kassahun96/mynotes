
import 'package:flutter/material.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String errorMessage,
) {
  return showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('An error occurred'),
          content: Text(errorMessage),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Ok'))
          ],
        );
      });
}

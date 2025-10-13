import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final String cancelText;
  final Color? confirmColor;

  const ConfirmationDialog({
    Key? key,
    this.title = 'Are you sure?',
    this.content = 'Do you really want to delete this entry? This action cannot be undone.',
    this.confirmText = 'Delete',
    this.cancelText = 'Cancel',
    this.confirmColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0xFF0ea5e9), width: 1), // Neon blue line
      ),
      title: const Text(
        'Are you sure?',
        style: TextStyle(color: Colors.white),
      ),
      content: const Text(
        'Do you really want to delete this entry? This action cannot be undone.',
        style: TextStyle(color: Colors.grey),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            'Delete',
            style: TextStyle(
              color: confirmColor ?? Colors.red,
            ),
          ),
        ),
      ],
    );
  }
}
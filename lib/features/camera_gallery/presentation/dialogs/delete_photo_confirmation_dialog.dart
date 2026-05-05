import 'package:flutter/material.dart';

Future<bool> showDeletePhotoConfirmationDialog(BuildContext context) async {
  final shouldDelete = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Удалить фотографию?'),
        content: const Text('Файл будет удалён только из AquaCamera.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Удалить'),
          ),
        ],
      );
    },
  );

  return shouldDelete ?? false;
}

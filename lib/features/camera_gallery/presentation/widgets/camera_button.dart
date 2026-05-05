import 'package:flutter/material.dart';

class CameraButton extends StatelessWidget {
  const CameraButton({
    required this.onPressed,
    required this.isBusy,
    super.key,
  });

  final VoidCallback? onPressed;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      tooltip: 'Сделать фото',
      onPressed: isBusy ? null : onPressed,
      icon: SizedBox.square(
        dimension: 24,
        child: isBusy
            ? const CircularProgressIndicator(strokeWidth: 2)
            : const Icon(Icons.photo_camera_outlined),
      ),
    );
  }
}

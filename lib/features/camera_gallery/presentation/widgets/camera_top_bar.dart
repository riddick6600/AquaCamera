import 'package:flutter/material.dart';

class CameraTopBar extends StatelessWidget {
  const CameraTopBar({required this.onClose, super.key});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: IconButton.filled(
              tooltip: 'Закрыть камеру',
              onPressed: onClose,
              style: IconButton.styleFrom(
                backgroundColor: Colors.black54,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.close),
            ),
          ),
        ),
      ),
    );
  }
}

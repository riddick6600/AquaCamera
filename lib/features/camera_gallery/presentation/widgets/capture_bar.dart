import 'package:flutter/material.dart';

class CaptureBar extends StatelessWidget {
  const CaptureBar({
    required this.isCapturing,
    required this.onCapture,
    super.key,
  });

  final bool isCapturing;
  final VoidCallback onCapture;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Center(
            child: IconButton.filled(
              tooltip: 'Снять фото',
              onPressed: isCapturing ? null : onCapture,
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                disabledBackgroundColor: Colors.white70,
                foregroundColor: Colors.black,
                fixedSize: const Size(76, 76),
                minimumSize: const Size(76, 76),
              ),
              icon: SizedBox.square(
                dimension: 32,
                child: isCapturing
                    ? const CircularProgressIndicator(strokeWidth: 3)
                    : const Icon(Icons.camera_alt, size: 32),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:aqua_camera/features/camera_gallery/presentation/widgets/error_view.dart';
import 'package:flutter/material.dart';

class CameraFailureContent extends StatelessWidget {
  const CameraFailureContent({
    required this.message,
    required this.permissionDenied,
    required this.onRetry,
    required this.onClose,
    super.key,
  });

  final String message;
  final bool permissionDenied;
  final VoidCallback onRetry;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: IconButton(
                tooltip: 'Закрыть камеру',
                onPressed: onClose,
                color: Colors.white,
                icon: const Icon(Icons.close),
              ),
            ),
          ),
          Expanded(
            child: Theme(
              data: Theme.of(
                context,
              ).copyWith(colorScheme: const ColorScheme.dark()),
              child: ErrorView(
                message: message,
                actionLabel: permissionDenied ? 'Проверить снова' : 'Повторить',
                onRetry: onRetry,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

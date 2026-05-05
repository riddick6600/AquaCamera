import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraPreviewView extends StatelessWidget {
  const CameraPreviewView({required this.controller, super.key});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final previewScale = screenSize.aspectRatio * controller.value.aspectRatio;
    final scale = previewScale < 1 ? 1 / previewScale : previewScale;

    return ClipRect(
      child: Transform.scale(
        scale: scale,
        child: Center(child: CameraPreview(controller)),
      ),
    );
  }
}

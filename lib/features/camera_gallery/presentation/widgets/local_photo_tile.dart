import 'dart:io';

import 'package:aqua_camera/features/camera_gallery/models/local_photo.dart';
import 'package:flutter/material.dart';

class LocalPhotoTile extends StatelessWidget {
  const LocalPhotoTile({
    required this.photo,
    required this.onOpen,
    required this.onDelete,
    super.key,
  });

  final LocalPhoto photo;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final pixelRatio = MediaQuery.devicePixelRatioOf(context);
        final cacheWidth = (constraints.maxWidth * pixelRatio).round();

        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Material(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: InkWell(
              onTap: onOpen,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'photo-${photo.id}',
                    child: Image.file(
                      File(photo.filePath),
                      cacheWidth: cacheWidth > 0 ? cacheWidth : null,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.low,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.broken_image_outlined),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: IconButton.filled(
                      tooltip: 'Удалить фото',
                      onPressed: onDelete,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black54,
                        foregroundColor: Colors.white,
                        fixedSize: const Size(36, 36),
                        minimumSize: const Size(36, 36),
                        padding: EdgeInsets.zero,
                      ),
                      icon: const Icon(Icons.delete_outline, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

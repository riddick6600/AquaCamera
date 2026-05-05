import 'dart:io';

import 'package:aqua_camera/features/camera_gallery/bloc/camera_gallery_bloc.dart';
import 'package:aqua_camera/features/camera_gallery/bloc/camera_gallery_event.dart';
import 'package:aqua_camera/features/camera_gallery/models/local_photo.dart';
import 'package:aqua_camera/features/camera_gallery/presentation/dialogs/delete_photo_confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PhotoViewPage extends StatelessWidget {
  const PhotoViewPage({required this.photo, super.key});

  final LocalPhoto photo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(_formatDate(photo.createdAt)),
        actions: [
          IconButton(
            tooltip: 'Удалить фото',
            onPressed: () => _confirmDelete(context),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Hero(
            tag: 'photo-${photo.id}',
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: Image.file(
                File(photo.filePath),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white,
                    size: 64,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final shouldDelete = await showDeletePhotoConfirmationDialog(context);

    if (!shouldDelete || !context.mounted) {
      return;
    }

    context.read<CameraGalleryBloc>().add(DeletePhotoRequested(photo));
    Navigator.of(context).pop();
  }

  String _formatDate(DateTime dateTime) {
    final localDateTime = dateTime.toLocal();
    final day = _twoDigits(localDateTime.day);
    final month = _twoDigits(localDateTime.month);
    final hour = _twoDigits(localDateTime.hour);
    final minute = _twoDigits(localDateTime.minute);

    return '$day.$month.${localDateTime.year} $hour:$minute';
  }

  String _twoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }
}

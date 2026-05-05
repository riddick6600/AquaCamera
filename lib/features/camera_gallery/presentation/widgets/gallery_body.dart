import 'package:aqua_camera/features/camera_gallery/bloc/camera_gallery_state.dart';
import 'package:aqua_camera/features/camera_gallery/models/local_photo.dart';
import 'package:aqua_camera/features/camera_gallery/presentation/widgets/empty_gallery_view.dart';
import 'package:aqua_camera/features/camera_gallery/presentation/widgets/error_view.dart';
import 'package:aqua_camera/features/camera_gallery/presentation/widgets/inline_message_banner.dart';
import 'package:aqua_camera/features/camera_gallery/presentation/widgets/local_photo_grid.dart';
import 'package:flutter/material.dart';

class GalleryBody extends StatelessWidget {
  const GalleryBody({
    required this.state,
    required this.onRetry,
    required this.onCheckPermission,
    required this.onOpenSettings,
    required this.onOpen,
    required this.onDelete,
    super.key,
  });

  final CameraGalleryState state;
  final VoidCallback onRetry;
  final VoidCallback onCheckPermission;
  final VoidCallback onOpenSettings;
  final ValueChanged<LocalPhoto> onOpen;
  final ValueChanged<LocalPhoto> onDelete;

  @override
  Widget build(BuildContext context) {
    final photos = state.photos;

    if (state is CameraGalleryLoading && photos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is CameraGalleryFailure && photos.isEmpty) {
      return ErrorView(
        message: (state as CameraGalleryFailure).message,
        onRetry: onRetry,
      );
    }

    if (state is CameraPermissionDenied && photos.isEmpty) {
      return ErrorView(
        message: (state as CameraPermissionDenied).message,
        actionLabel: 'Проверить снова',
        onRetry: onCheckPermission,
        secondaryActionLabel: 'Открыть настройки',
        onSecondaryAction: onOpenSettings,
      );
    }

    if (photos.isEmpty) {
      return const EmptyGalleryView();
    }

    return Column(
      children: [
        if (state is CameraGalleryLoading) const LinearProgressIndicator(),
        if (state is CameraGalleryFailure)
          InlineMessageBanner(
            icon: Icons.error_outline,
            message: (state as CameraGalleryFailure).message,
            color: Theme.of(context).colorScheme.error,
          ),
        if (state is CameraPermissionDenied)
          InlineMessageBanner(
            icon: Icons.no_photography_outlined,
            message: (state as CameraPermissionDenied).message,
            color: Theme.of(context).colorScheme.error,
            actionLabel: 'Настройки',
            onAction: onOpenSettings,
          ),
        Expanded(
          child: LocalPhotoGrid(
            photos: photos,
            onOpen: onOpen,
            onDelete: onDelete,
          ),
        ),
      ],
    );
  }
}

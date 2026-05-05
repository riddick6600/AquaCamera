import 'package:aqua_camera/features/camera_gallery/camera_gallery_constants.dart';
import 'package:aqua_camera/features/camera_gallery/models/local_photo.dart';
import 'package:aqua_camera/features/camera_gallery/presentation/widgets/local_photo_tile.dart';
import 'package:flutter/material.dart';

class LocalPhotoGrid extends StatelessWidget {
  const LocalPhotoGrid({
    required this.photos,
    required this.onOpen,
    required this.onDelete,
    super.key,
  });

  final List<LocalPhoto> photos;
  final ValueChanged<LocalPhoto> onOpen;
  final ValueChanged<LocalPhoto> onDelete;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: CameraGalleryConstants.gridCrossAxisCount,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        final photo = photos[index];

        return LocalPhotoTile(
          photo: photo,
          onOpen: () => onOpen(photo),
          onDelete: () => onDelete(photo),
        );
      },
    );
  }
}

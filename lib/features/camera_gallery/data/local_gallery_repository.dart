import 'dart:io';
import 'dart:ui' as ui;

import 'package:aqua_camera/features/camera_gallery/data/local_media_storage.dart';
import 'package:aqua_camera/features/camera_gallery/models/local_photo.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

abstract interface class CameraGalleryRepository {
  Future<List<LocalPhoto>> loadPhotos();

  Future<LocalPhoto> saveCapturedPhoto(XFile capturedFile);

  Future<void> deletePhoto(LocalPhoto photo);
}

class LocalGalleryRepository implements CameraGalleryRepository {
  LocalGalleryRepository({required LocalMediaStorage storage, Uuid? uuid})
    : _storage = storage,
      _uuid = uuid ?? const Uuid();

  final LocalMediaStorage _storage;
  final Uuid _uuid;

  @override
  Future<List<LocalPhoto>> loadPhotos() {
    return _storage.readPhotos();
  }

  @override
  Future<LocalPhoto> saveCapturedPhoto(XFile capturedFile) async {
    final id = _uuid.v4();
    final createdAt = DateTime.now();
    final extension = _safeImageExtension(capturedFile.path);
    final storedFile = await _storage.copyCapturedFile(
      sourcePath: capturedFile.path,
      targetFileName: '$id$extension',
    );
    final imageSize = await _readImageSize(storedFile);
    final photo = LocalPhoto(
      id: id,
      filePath: storedFile.path,
      createdAt: createdAt,
      sizeBytes: await storedFile.length(),
      width: imageSize?.width,
      height: imageSize?.height,
      source: 'camera',
    );

    final photos = await _storage.readPhotos();
    await _storage.writePhotos([photo, ...photos]);

    return photo;
  }

  @override
  Future<void> deletePhoto(LocalPhoto photo) async {
    final photos = await _storage.readPhotos();
    final updatedPhotos = photos
        .where((existingPhoto) => existingPhoto.id != photo.id)
        .toList(growable: false);

    await _storage.deletePhotoFile(photo.filePath);
    await _storage.writePhotos(updatedPhotos);
  }

  String _safeImageExtension(String filePath) {
    final extension = p.extension(filePath).toLowerCase();
    if (extension == '.jpg' ||
        extension == '.jpeg' ||
        extension == '.png' ||
        extension == '.heic') {
      return extension;
    }

    return '.jpg';
  }

  Future<({int width, int height})?> _readImageSize(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      final size = (width: image.width, height: image.height);

      image.dispose();
      codec.dispose();

      return size;
    } catch (_) {
      return null;
    }
  }
}

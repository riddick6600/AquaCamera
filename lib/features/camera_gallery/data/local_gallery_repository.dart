import 'dart:io';
import 'dart:ui' as ui;

import 'package:aqua_camera/features/camera_gallery/data/async_mutex.dart';
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
  final AsyncMutex _metadataMutex = AsyncMutex();

  @override
  Future<List<LocalPhoto>> loadPhotos() {
    return _metadataMutex.run(_storage.readPhotos);
  }

  @override
  Future<LocalPhoto> saveCapturedPhoto(XFile capturedFile) async {
    final id = _uuid.v4();
    final createdAt = DateTime.now();
    final extension = _safeImageExtension(capturedFile.path);
    final fileName = '$id$extension';
    final storedFile = await _storage.copyCapturedFile(
      sourcePath: capturedFile.path,
      targetFileName: fileName,
    );

    try {
      final imageSize = await _readImageSize(storedFile);
      final photo = LocalPhoto(
        id: id,
        fileName: fileName,
        filePath: storedFile.path,
        createdAt: createdAt,
        sizeBytes: await storedFile.length(),
        width: imageSize?.width,
        height: imageSize?.height,
        source: 'camera',
      );

      await _metadataMutex.run(() async {
        final photos = await _storage.readPhotos();
        await _storage.writePhotos([photo, ...photos]);
      });

      return photo;
    } catch (error) {
      await _deleteCopiedFileSilently(storedFile.path);
      rethrow;
    }
  }

  @override
  Future<void> deletePhoto(LocalPhoto photo) async {
    await _metadataMutex.run(() async {
      final photos = await _storage.readPhotos();
      final updatedPhotos = photos
          .where((existingPhoto) => existingPhoto.id != photo.id)
          .toList(growable: false);

      await _storage.writePhotos(updatedPhotos);
    });

    await _deleteCopiedFileSilently(photo.filePath);
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
      final buffer = await ui.ImmutableBuffer.fromFilePath(file.path);
      final codec = await ui.instantiateImageCodecFromBuffer(buffer);
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

  Future<void> _deleteCopiedFileSilently(String filePath) async {
    try {
      await _storage.deletePhotoFileIfExists(filePath);
    } catch (_) {
      // Запись в JSON важнее файла-сироты: галерея не должна возвращать уже
      // удалённое фото из-за ошибки удаления файла на диске.
    }
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:aqua_camera/features/camera_gallery/models/local_photo.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class StorageException implements Exception {
  const StorageException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() {
    if (cause == null) {
      return message;
    }

    return '$message Причина: $cause';
  }
}

class LocalMediaStorage {
  static const _rootDirectoryName = 'aqua_camera';
  static const _imagesDirectoryName = 'images';
  static const _metadataFileName = 'gallery.json';

  Future<List<LocalPhoto>> readPhotos() async {
    try {
      final metadataFile = await _metadataFile();
      if (!await metadataFile.exists()) {
        return const [];
      }

      final content = await metadataFile.readAsString();
      if (content.trim().isEmpty) {
        return const [];
      }

      final decoded = jsonDecode(content);
      if (decoded is! List) {
        throw const FormatException('Файл метаданных должен содержать список.');
      }

      final photos = <LocalPhoto>[];
      for (final item in decoded) {
        if (item is Map<String, dynamic>) {
          photos.add(LocalPhoto.fromJson(item));
        } else if (item is Map) {
          photos.add(LocalPhoto.fromJson(Map<String, dynamic>.from(item)));
        }
      }

      final existingPhotos = <LocalPhoto>[];
      for (final photo in photos) {
        if (await File(photo.filePath).exists()) {
          existingPhotos.add(photo);
        }
      }

      existingPhotos.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Если файл был удалён вне приложения, синхронизируем JSON, чтобы UI не
      // показывал битые записи после следующего запуска.
      if (existingPhotos.length != photos.length) {
        await writePhotos(existingPhotos);
      }

      return existingPhotos;
    } on StorageException {
      rethrow;
    } catch (error) {
      throw StorageException('Не удалось прочитать локальную галерею.', error);
    }
  }

  Future<void> writePhotos(List<LocalPhoto> photos) async {
    try {
      final metadataFile = await _metadataFile();
      final sortedPhotos = [...photos]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      const encoder = JsonEncoder.withIndent('  ');
      await metadataFile.writeAsString(
        encoder.convert(sortedPhotos.map((photo) => photo.toJson()).toList()),
        flush: true,
      );
    } catch (error) {
      throw StorageException('Не удалось сохранить метаданные галереи.', error);
    }
  }

  Future<File> copyCapturedFile({
    required String sourcePath,
    required String targetFileName,
  }) async {
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        throw const FileSystemException('Файл снимка не найден.');
      }

      final imagesDirectory = await ensureImagesDirectory();
      final targetFile = File(p.join(imagesDirectory.path, targetFileName));
      return sourceFile.copy(targetFile.path);
    } catch (error) {
      throw StorageException('Не удалось сохранить фотографию.', error);
    }
  }

  Future<void> deletePhotoFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (error) {
      throw StorageException('Не удалось удалить файл фотографии.', error);
    }
  }

  Future<Directory> ensureImagesDirectory() async {
    final rootDirectory = await _rootDirectory();
    final imagesDirectory = Directory(
      p.join(rootDirectory.path, _imagesDirectoryName),
    );

    if (!await imagesDirectory.exists()) {
      await imagesDirectory.create(recursive: true);
    }

    return imagesDirectory;
  }

  Future<Directory> _rootDirectory() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final rootDirectory = Directory(
      p.join(documentsDirectory.path, _rootDirectoryName),
    );

    if (!await rootDirectory.exists()) {
      await rootDirectory.create(recursive: true);
    }

    return rootDirectory;
  }

  Future<File> _metadataFile() async {
    final rootDirectory = await _rootDirectory();
    return File(p.join(rootDirectory.path, _metadataFileName));
  }
}

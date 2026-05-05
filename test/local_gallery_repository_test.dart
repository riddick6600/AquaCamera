import 'dart:io';

import 'package:aqua_camera/features/camera_gallery/data/local_gallery_repository.dart';
import 'package:aqua_camera/features/camera_gallery/data/local_media_storage.dart';
import 'package:aqua_camera/features/camera_gallery/models/local_photo.dart';
import 'package:camera/camera.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  group('LocalGalleryRepository', () {
    late Directory tempDirectory;
    late Directory imagesDirectory;

    setUp(() async {
      tempDirectory = await Directory.systemTemp.createTemp(
        'aqua_camera_repository_test_',
      );
      imagesDirectory = Directory(p.join(tempDirectory.path, 'images'));
      await imagesDirectory.create();
    });

    tearDown(() async {
      if (await tempDirectory.exists()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    test('откатывает скопированный файл, если запись JSON упала', () async {
      final capturedFile = await _createFile(tempDirectory, 'captured.jpg', [
        1,
        2,
        3,
        4,
      ]);
      final storage = _FakeLocalMediaStorage(
        imagesDirectory: imagesDirectory,
        throwOnWrite: true,
      );
      final repository = LocalGalleryRepository(storage: storage);

      await expectLater(
        repository.saveCapturedPhoto(XFile(capturedFile.path)),
        throwsA(isA<StorageException>()),
      );

      expect(await imagesDirectory.list().isEmpty, isTrue);
      expect(storage.operations, containsAllInOrder(['copy', 'read', 'write']));
      expect(storage.operations.last, 'delete');
    });

    test('сначала обновляет JSON при удалении, потом удаляет файл', () async {
      final file = await _createFile(imagesDirectory, 'photo-1.jpg', [1]);
      final photo = _photo(file);
      final storage = _FakeLocalMediaStorage(
        imagesDirectory: imagesDirectory,
        photos: [photo],
      );
      final repository = LocalGalleryRepository(storage: storage);

      await repository.deletePhoto(photo);

      expect(storage.photos, isEmpty);
      expect(await file.exists(), isFalse);
      expect(
        storage.operations.indexOf('write'),
        lessThan(storage.operations.indexOf('delete')),
      );
    });

    test('не теряет записи при конкурентном сохранении снимков', () async {
      final firstFile = await _createFile(tempDirectory, 'first.jpg', [1]);
      final secondFile = await _createFile(tempDirectory, 'second.jpg', [2]);
      final storage = _FakeLocalMediaStorage(
        imagesDirectory: imagesDirectory,
        writeDelay: const Duration(milliseconds: 10),
      );
      final repository = LocalGalleryRepository(storage: storage);

      await Future.wait([
        repository.saveCapturedPhoto(XFile(firstFile.path)),
        repository.saveCapturedPhoto(XFile(secondFile.path)),
      ]);

      expect(storage.photos, hasLength(2));
      expect(
        storage.photos.map((photo) => photo.fileName).toSet(),
        hasLength(2),
      );
    });
  });
}

Future<File> _createFile(
  Directory directory,
  String name,
  List<int> bytes,
) async {
  final file = File(p.join(directory.path, name));
  await file.writeAsBytes(bytes, flush: true);
  return file;
}

LocalPhoto _photo(File file) {
  return LocalPhoto(
    id: 'photo-1',
    fileName: p.basename(file.path),
    filePath: file.path,
    createdAt: DateTime(2026, 5, 5, 10),
    sizeBytes: 1,
  );
}

final class _FakeLocalMediaStorage extends LocalMediaStorage {
  _FakeLocalMediaStorage({
    required Directory imagesDirectory,
    List<LocalPhoto> photos = const [],
    this.throwOnWrite = false,
    this.writeDelay = Duration.zero,
  }) : _imagesDirectory = imagesDirectory,
       photos = [...photos];

  final Directory _imagesDirectory;
  final bool throwOnWrite;
  final Duration writeDelay;
  final List<String> operations = [];
  List<LocalPhoto> photos;

  @override
  Future<List<LocalPhoto>> readPhotos() async {
    operations.add('read');
    return [...photos];
  }

  @override
  Future<void> writePhotos(List<LocalPhoto> photos) async {
    operations.add('write');
    if (writeDelay > Duration.zero) {
      await Future<void>.delayed(writeDelay);
    }

    if (throwOnWrite) {
      throw const StorageException('Не удалось сохранить метаданные галереи.');
    }

    this.photos = [...photos];
  }

  @override
  Future<File> copyCapturedFile({
    required String sourcePath,
    required String targetFileName,
  }) async {
    operations.add('copy');
    final sourceFile = File(sourcePath);
    final targetFile = File(p.join(_imagesDirectory.path, targetFileName));
    return sourceFile.copy(targetFile.path);
  }

  @override
  Future<void> deletePhotoFileIfExists(String filePath) async {
    operations.add('delete');
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}

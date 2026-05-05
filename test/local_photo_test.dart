import 'package:aqua_camera/features/camera_gallery/models/local_photo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('LocalPhoto сохраняет и восстанавливает метаданные из JSON', () {
    final photo = LocalPhoto(
      id: 'photo-1',
      fileName: 'photo-1.jpg',
      filePath: '/tmp/aqua_camera/photo-1.jpg',
      createdAt: DateTime(2026, 5, 5, 14, 30),
      sizeBytes: 2048,
      width: 1200,
      height: 900,
    );

    expect(
      LocalPhoto.fromJson(
        photo.toJson(),
        imagesDirectoryPath: '/tmp/aqua_camera',
      ),
      photo,
    );
  });

  test('LocalPhoto мигрирует абсолютный путь старого формата в fileName', () {
    final photo = LocalPhoto.fromJson({
      'id': 'photo-1',
      'filePath': '/var/mobile/Containers/Data/photo-1.jpg',
      'createdAt': DateTime(2026, 5, 5, 14, 30).toIso8601String(),
      'sizeBytes': 2048,
    }, imagesDirectoryPath: '/tmp/aqua_camera');

    expect(photo.fileName, 'photo-1.jpg');
    expect(photo.filePath, '/tmp/aqua_camera/photo-1.jpg');
  });
}

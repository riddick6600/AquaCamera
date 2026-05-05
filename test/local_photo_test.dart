import 'package:aqua_camera/features/camera_gallery/models/local_photo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('LocalPhoto сохраняет и восстанавливает метаданные из JSON', () {
    final photo = LocalPhoto(
      id: 'photo-1',
      filePath: '/tmp/aqua_camera/photo-1.jpg',
      createdAt: DateTime(2026, 5, 5, 14, 30),
      sizeBytes: 2048,
      width: 1200,
      height: 900,
    );

    expect(LocalPhoto.fromJson(photo.toJson()), photo);
  });
}

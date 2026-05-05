import 'package:aqua_camera/features/camera_gallery/bloc/camera_gallery_bloc.dart';
import 'package:aqua_camera/features/camera_gallery/bloc/camera_gallery_event.dart';
import 'package:aqua_camera/features/camera_gallery/bloc/camera_gallery_state.dart';
import 'package:aqua_camera/features/camera_gallery/data/local_gallery_repository.dart';
import 'package:aqua_camera/features/camera_gallery/data/local_media_storage.dart';
import 'package:aqua_camera/features/camera_gallery/models/local_photo.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:camera/camera.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CameraGalleryBloc', () {
    blocTest<CameraGalleryBloc, CameraGalleryState>(
      'показывает пустое состояние, если локальных фото нет',
      build: () =>
          CameraGalleryBloc(galleryRepository: _FakeCameraGalleryRepository()),
      act: (bloc) => bloc.add(const LoadLocalPhotosRequested()),
      expect: () => [const CameraGalleryLoading(), const CameraGalleryEmpty()],
    );

    blocTest<CameraGalleryBloc, CameraGalleryState>(
      'загружает сохранённые локальные фото',
      build: () => CameraGalleryBloc(
        galleryRepository: _FakeCameraGalleryRepository(photos: [_photo]),
      ),
      act: (bloc) => bloc.add(const LoadLocalPhotosRequested()),
      expect: () => [
        const CameraGalleryLoading(),
        CameraGalleryLoaded(photos: [_photo]),
      ],
    );

    blocTest<CameraGalleryBloc, CameraGalleryState>(
      'сохраняет новый снимок и обновляет галерею',
      build: () =>
          CameraGalleryBloc(galleryRepository: _FakeCameraGalleryRepository()),
      act: (bloc) => bloc.add(PhotoCaptured(XFile('/tmp/captured.jpg'))),
      expect: () => [
        const CameraGalleryLoading(),
        CameraGalleryLoaded(photos: [_capturedPhoto]),
      ],
    );

    blocTest<CameraGalleryBloc, CameraGalleryState>(
      'удаляет фото из локальной галереи',
      build: () => CameraGalleryBloc(
        galleryRepository: _FakeCameraGalleryRepository(photos: [_photo]),
      ),
      seed: () => CameraGalleryLoaded(photos: [_photo]),
      act: (bloc) => bloc.add(DeletePhotoRequested(_photo)),
      expect: () => [
        CameraGalleryLoading(photos: [_photo]),
        const CameraGalleryEmpty(),
      ],
    );

    blocTest<CameraGalleryBloc, CameraGalleryState>(
      'показывает ошибку локального хранилища',
      build: () => CameraGalleryBloc(
        galleryRepository: _FakeCameraGalleryRepository(throwOnLoad: true),
      ),
      act: (bloc) => bloc.add(const LoadLocalPhotosRequested()),
      expect: () => [
        const CameraGalleryLoading(),
        const CameraGalleryFailure(
          message: 'Не удалось прочитать локальную галерею.',
        ),
      ],
    );
  });
}

final _photo = LocalPhoto(
  id: 'photo-1',
  filePath: '/tmp/photo-1.jpg',
  createdAt: DateTime(2026, 5, 5, 10),
  sizeBytes: 1024,
  width: 800,
  height: 600,
);

final _capturedPhoto = LocalPhoto(
  id: 'captured-photo',
  filePath: '/tmp/captured.jpg',
  createdAt: DateTime(2026, 5, 5, 11),
  sizeBytes: 2048,
  width: 1200,
  height: 900,
);

class _FakeCameraGalleryRepository implements CameraGalleryRepository {
  _FakeCameraGalleryRepository({
    List<LocalPhoto> photos = const [],
    this.throwOnLoad = false,
  }) : _photos = [...photos];

  List<LocalPhoto> _photos;
  final bool throwOnLoad;

  @override
  Future<List<LocalPhoto>> loadPhotos() async {
    if (throwOnLoad) {
      throw const StorageException('Не удалось прочитать локальную галерею.');
    }

    return _photos;
  }

  @override
  Future<LocalPhoto> saveCapturedPhoto(XFile capturedFile) async {
    _photos = [_capturedPhoto, ..._photos];
    return _capturedPhoto;
  }

  @override
  Future<void> deletePhoto(LocalPhoto photo) async {
    _photos = _photos
        .where((existingPhoto) => existingPhoto.id != photo.id)
        .toList(growable: false);
  }
}

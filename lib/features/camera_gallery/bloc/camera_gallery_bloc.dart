import 'package:aqua_camera/features/camera_gallery/bloc/camera_gallery_event.dart';
import 'package:aqua_camera/features/camera_gallery/bloc/camera_gallery_state.dart';
import 'package:aqua_camera/features/camera_gallery/data/local_gallery_repository.dart';
import 'package:aqua_camera/features/camera_gallery/data/local_media_storage.dart';
import 'package:aqua_camera/features/camera_gallery/models/local_photo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CameraGalleryBloc extends Bloc<CameraGalleryEvent, CameraGalleryState> {
  CameraGalleryBloc({required CameraGalleryRepository galleryRepository})
    : _galleryRepository = galleryRepository,
      super(const CameraGalleryInitial()) {
    on<LoadLocalPhotosRequested>(_onLoadLocalPhotosRequested);
    on<RetryRequested>(_onRetryRequested);
    on<TakePhotoRequested>(_onTakePhotoRequested);
    on<PhotoCaptured>(_onPhotoCaptured);
    on<CameraCaptureCancelledReceived>(_onCameraCaptureCancelled);
    on<CameraCaptureFailureReceived>(_onCameraCaptureFailed);
    on<CameraPermissionDeniedReceived>(_onCameraPermissionDeniedReceived);
    on<DeletePhotoRequested>(_onDeletePhotoRequested);
  }

  final CameraGalleryRepository _galleryRepository;

  Future<void> _onLoadLocalPhotosRequested(
    LoadLocalPhotosRequested event,
    Emitter<CameraGalleryState> emit,
  ) async {
    await _loadPhotos(emit);
  }

  Future<void> _onRetryRequested(
    RetryRequested event,
    Emitter<CameraGalleryState> emit,
  ) async {
    await _loadPhotos(emit);
  }

  void _onTakePhotoRequested(
    TakePhotoRequested event,
    Emitter<CameraGalleryState> emit,
  ) {
    emit(_stateForPhotos(state.photos, isCameraBusy: true));
  }

  Future<void> _onPhotoCaptured(
    PhotoCaptured event,
    Emitter<CameraGalleryState> emit,
  ) async {
    final currentPhotos = state.photos;
    emit(CameraGalleryLoading(photos: currentPhotos));

    try {
      await _galleryRepository.saveCapturedPhoto(event.capturedFile);
      final photos = await _galleryRepository.loadPhotos();
      emit(_stateForPhotos(photos));
    } catch (error) {
      emit(
        CameraGalleryFailure(
          message: _messageFromError(
            error,
            fallback: 'Не удалось сохранить фотографию.',
          ),
          photos: currentPhotos,
        ),
      );
    }
  }

  void _onCameraCaptureCancelled(
    CameraCaptureCancelledReceived event,
    Emitter<CameraGalleryState> emit,
  ) {
    emit(_stateForPhotos(state.photos));
  }

  void _onCameraCaptureFailed(
    CameraCaptureFailureReceived event,
    Emitter<CameraGalleryState> emit,
  ) {
    emit(CameraGalleryFailure(message: event.message, photos: state.photos));
  }

  void _onCameraPermissionDeniedReceived(
    CameraPermissionDeniedReceived event,
    Emitter<CameraGalleryState> emit,
  ) {
    emit(CameraPermissionDenied(message: event.message, photos: state.photos));
  }

  Future<void> _onDeletePhotoRequested(
    DeletePhotoRequested event,
    Emitter<CameraGalleryState> emit,
  ) async {
    final currentPhotos = state.photos;
    emit(CameraGalleryLoading(photos: currentPhotos));

    try {
      await _galleryRepository.deletePhoto(event.photo);
      final photos = await _galleryRepository.loadPhotos();
      emit(_stateForPhotos(photos));
    } catch (error) {
      emit(
        CameraGalleryFailure(
          message: _messageFromError(
            error,
            fallback: 'Не удалось удалить фотографию.',
          ),
          photos: currentPhotos,
        ),
      );
    }
  }

  Future<void> _loadPhotos(Emitter<CameraGalleryState> emit) async {
    final currentPhotos = state.photos;
    emit(CameraGalleryLoading(photos: currentPhotos));

    try {
      final photos = await _galleryRepository.loadPhotos();
      emit(_stateForPhotos(photos));
    } catch (error) {
      emit(
        CameraGalleryFailure(
          message: _messageFromError(
            error,
            fallback: 'Не удалось загрузить локальную галерею.',
          ),
          photos: currentPhotos,
        ),
      );
    }
  }

  CameraGalleryState _stateForPhotos(
    List<LocalPhoto> photos, {
    bool isCameraBusy = false,
  }) {
    if (photos.isEmpty) {
      return CameraGalleryEmpty(isCameraBusy: isCameraBusy);
    }

    return CameraGalleryLoaded(photos: photos, isCameraBusy: isCameraBusy);
  }

  String _messageFromError(Object error, {required String fallback}) {
    if (error is StorageException) {
      return error.message;
    }

    return fallback;
  }
}

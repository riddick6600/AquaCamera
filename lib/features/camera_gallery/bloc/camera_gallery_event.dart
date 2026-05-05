import 'package:aqua_camera/features/camera_gallery/models/local_photo.dart';
import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';

sealed class CameraGalleryEvent extends Equatable {
  const CameraGalleryEvent();

  @override
  List<Object?> get props => const [];
}

final class LoadLocalPhotosRequested extends CameraGalleryEvent {
  const LoadLocalPhotosRequested();
}

final class RetryRequested extends CameraGalleryEvent {
  const RetryRequested();
}

final class TakePhotoRequested extends CameraGalleryEvent {
  const TakePhotoRequested();
}

final class PhotoCaptured extends CameraGalleryEvent {
  const PhotoCaptured(this.capturedFile);

  final XFile capturedFile;

  @override
  List<Object?> get props => [capturedFile.path];
}

final class CameraCaptureCancelledEvent extends CameraGalleryEvent {
  const CameraCaptureCancelledEvent();
}

final class CameraCaptureFailed extends CameraGalleryEvent {
  const CameraCaptureFailed(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class CameraPermissionDeniedReceived extends CameraGalleryEvent {
  const CameraPermissionDeniedReceived(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class DeletePhotoRequested extends CameraGalleryEvent {
  const DeletePhotoRequested(this.photo);

  final LocalPhoto photo;

  @override
  List<Object?> get props => [photo];
}

final class OpenPhotoRequested extends CameraGalleryEvent {
  const OpenPhotoRequested(this.photo);

  final LocalPhoto photo;

  @override
  List<Object?> get props => [photo];
}

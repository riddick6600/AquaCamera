import 'package:aqua_camera/features/camera_gallery/models/local_photo.dart';
import 'package:equatable/equatable.dart';

sealed class CameraGalleryState extends Equatable {
  const CameraGalleryState();

  List<LocalPhoto> get photos => const [];

  bool get isCameraBusy => false;

  @override
  List<Object?> get props => const [];
}

final class CameraGalleryInitial extends CameraGalleryState {
  const CameraGalleryInitial();
}

final class CameraGalleryLoading extends CameraGalleryState {
  const CameraGalleryLoading({this.photos = const []});

  @override
  final List<LocalPhoto> photos;

  @override
  List<Object?> get props => [photos];
}

final class CameraGalleryLoaded extends CameraGalleryState {
  const CameraGalleryLoaded({required this.photos, this.isCameraBusy = false});

  @override
  final List<LocalPhoto> photos;

  @override
  final bool isCameraBusy;

  @override
  List<Object?> get props => [photos, isCameraBusy];
}

final class CameraGalleryEmpty extends CameraGalleryState {
  const CameraGalleryEmpty({this.isCameraBusy = false});

  @override
  final bool isCameraBusy;

  @override
  List<Object?> get props => [isCameraBusy];
}

final class CameraGalleryFailure extends CameraGalleryState {
  const CameraGalleryFailure({required this.message, this.photos = const []});

  final String message;

  @override
  final List<LocalPhoto> photos;

  @override
  List<Object?> get props => [message, photos];
}

final class CameraPermissionDenied extends CameraGalleryState {
  const CameraPermissionDenied({required this.message, this.photos = const []});

  final String message;

  @override
  final List<LocalPhoto> photos;

  @override
  List<Object?> get props => [message, photos];
}

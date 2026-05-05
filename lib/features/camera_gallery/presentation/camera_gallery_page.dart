import 'package:aqua_camera/features/about/presentation/about_app_page.dart';
import 'package:aqua_camera/features/about/presentation/widgets/about_button.dart';
import 'package:aqua_camera/features/camera_gallery/bloc/camera_gallery_bloc.dart';
import 'package:aqua_camera/features/camera_gallery/bloc/camera_gallery_event.dart';
import 'package:aqua_camera/features/camera_gallery/bloc/camera_gallery_state.dart';
import 'package:aqua_camera/features/camera_gallery/camera_gallery_constants.dart';
import 'package:aqua_camera/features/camera_gallery/data/camera_permission_repository.dart';
import 'package:aqua_camera/features/camera_gallery/data/camera_repository.dart';
import 'package:aqua_camera/features/camera_gallery/models/local_photo.dart';
import 'package:aqua_camera/features/camera_gallery/presentation/camera_capture_page.dart';
import 'package:aqua_camera/features/camera_gallery/presentation/dialogs/delete_photo_confirmation_dialog.dart';
import 'package:aqua_camera/features/camera_gallery/presentation/photo_view_page.dart';
import 'package:aqua_camera/features/camera_gallery/presentation/utils/app_resume_waiter.dart';
import 'package:aqua_camera/features/camera_gallery/presentation/widgets/camera_button.dart';
import 'package:aqua_camera/features/camera_gallery/presentation/widgets/gallery_body.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CameraGalleryPage extends StatelessWidget {
  const CameraGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AquaCamera'),
        actions: [
          BlocBuilder<CameraGalleryBloc, CameraGalleryState>(
            buildWhen: (previous, current) {
              return previous.isCameraBusy != current.isCameraBusy;
            },
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CameraButton(
                  isBusy: state.isCameraBusy,
                  onPressed: () => _openCamera(context),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<CameraGalleryBloc, CameraGalleryState>(
        builder: (context, state) {
          return GalleryBody(
            state: state,
            onRetry: () {
              context.read<CameraGalleryBloc>().add(const RetryRequested());
            },
            onCheckPermission: () => _openCamera(context),
            onOpenSettings: () => _openCameraSettings(context),
            onOpen: (photo) => _openPhoto(context, photo),
            onDelete: (photo) => _confirmDelete(context, photo),
          );
        },
      ),
      floatingActionButton: AboutButton(onPressed: () => _openAbout(context)),
    );
  }

  Future<void> _openCamera(BuildContext context) async {
    final bloc = context.read<CameraGalleryBloc>()
      ..add(const TakePhotoRequested());

    final permissionRepository = context.read<CameraPermissionRepository>();
    late final CameraPermissionStatus permissionStatus;
    try {
      permissionStatus = await permissionRepository.requestCameraPermission();
    } catch (_) {
      bloc.add(
        const CameraCaptureFailureReceived(
          'Не удалось проверить доступ к камере. Повторите попытку.',
        ),
      );
      return;
    }

    if (!context.mounted) {
      return;
    }

    if (permissionStatus != CameraPermissionStatus.granted) {
      bloc.add(
        CameraPermissionDeniedReceived(
          permissionRepository.messageForStatus(permissionStatus),
        ),
      );
      return;
    }

    // После первого системного запроса iOS нужно дождаться возврата приложения
    // в активное состояние, иначе AVFoundation иногда отдаёт пустой preview.
    await _waitForPermissionDialogToSettle();

    if (!context.mounted) {
      return;
    }

    final result = await Navigator.of(context).push<CameraCaptureResult>(
      MaterialPageRoute(
        builder: (_) => const CameraCapturePage(),
        fullscreenDialog: true,
      ),
    );

    if (!context.mounted) {
      return;
    }

    if (result is CameraCaptureSuccess) {
      bloc.add(PhotoCaptured(result.file));
    } else if (result is CameraCaptureFailure) {
      if (result.permissionDenied) {
        bloc.add(CameraPermissionDeniedReceived(result.message));
      } else {
        bloc.add(CameraCaptureFailureReceived(result.message));
      }
    } else {
      bloc.add(const CameraCaptureCancelledReceived());
    }
  }

  Future<void> _openCameraSettings(BuildContext context) async {
    await context.read<CameraPermissionRepository>().openAppSettings();
  }

  Future<void> _waitForPermissionDialogToSettle() async {
    await WidgetsBinding.instance.endOfFrame;

    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      final waiter = AppResumeWaiter();
      await waiter.wait();
    }

    await Future<void>.delayed(
      CameraGalleryConstants.permissionDialogSettleDelay,
    );
  }

  void _openPhoto(BuildContext context, LocalPhoto photo) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: context.read<CameraGalleryBloc>(),
          child: PhotoViewPage(photo: photo),
        ),
      ),
    );
  }

  void _openAbout(BuildContext context) {
    Navigator.of(
      context,
    ).push(CupertinoPageRoute<void>(builder: (_) => const AboutAppPage()));
  }

  Future<void> _confirmDelete(BuildContext context, LocalPhoto photo) async {
    final shouldDelete = await showDeletePhotoConfirmationDialog(context);

    if (!shouldDelete || !context.mounted) {
      return;
    }

    context.read<CameraGalleryBloc>().add(DeletePhotoRequested(photo));
  }
}

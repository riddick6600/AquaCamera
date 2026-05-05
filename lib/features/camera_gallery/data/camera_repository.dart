import 'dart:async';

import 'package:camera/camera.dart';

sealed class CameraCaptureResult {
  const CameraCaptureResult();
}

final class CameraCaptureSuccess extends CameraCaptureResult {
  const CameraCaptureSuccess(this.file);

  final XFile file;
}

final class CameraCaptureCancelled extends CameraCaptureResult {
  const CameraCaptureCancelled();
}

final class CameraCaptureFailure extends CameraCaptureResult {
  const CameraCaptureFailure(this.message, {this.permissionDenied = false});

  final String message;
  final bool permissionDenied;
}

class CameraRepository {
  Future<List<CameraDescription>> loadAvailableCameras() {
    return availableCameras();
  }

  Future<CameraController> createController(CameraDescription camera) async {
    final controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await controller.initialize().timeout(const Duration(seconds: 12));
      return controller;
    } catch (_) {
      await controller.dispose();
      rethrow;
    }
  }

  Future<XFile> takePicture(CameraController controller) {
    if (!controller.value.isInitialized) {
      throw CameraException('CameraNotReady', 'Камера ещё не готова к съёмке.');
    }

    if (controller.value.isTakingPicture) {
      throw CameraException('CameraBusy', 'Фотография уже создаётся.');
    }

    return controller.takePicture();
  }

  bool isPermissionDenied(Object error) {
    return error is CameraException &&
        (error.code == 'CameraAccessDenied' ||
            error.code == 'CameraAccessDeniedWithoutPrompt' ||
            error.code == 'CameraAccessRestricted');
  }

  String messageForError(Object error) {
    if (isPermissionDenied(error)) {
      return 'Доступ к камере запрещён. Разрешите доступ в настройках iOS.';
    }

    if (error is CameraException &&
        (error.code == 'CameraNotReady' || error.code == 'CameraBusy') &&
        error.description != null) {
      return error.description!;
    }

    if (error is TimeoutException) {
      return 'Камера не запустилась вовремя. Закройте экран и попробуйте ещё раз.';
    }

    return 'Не удалось открыть камеру. Повторите попытку.';
  }
}

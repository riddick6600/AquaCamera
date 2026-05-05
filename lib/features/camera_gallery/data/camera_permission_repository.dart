import 'package:flutter/services.dart';

enum CameraPermissionStatus { granted, denied, restricted }

class CameraPermissionRepository {
  static const _channel = MethodChannel('aqua_camera/camera_permission');

  Future<CameraPermissionStatus> requestCameraPermission() async {
    final status = await _channel.invokeMethod<String>(
      'requestCameraPermission',
    );

    return switch (status) {
      'granted' => CameraPermissionStatus.granted,
      'restricted' => CameraPermissionStatus.restricted,
      _ => CameraPermissionStatus.denied,
    };
  }

  Future<bool> openAppSettings() async {
    return await _channel.invokeMethod<bool>('openAppSettings') ?? false;
  }

  String messageForStatus(CameraPermissionStatus status) {
    // iOS показывает системный запрос только один раз. После отказа пользователь
    // должен включить камеру вручную в настройках приложения.
    return switch (status) {
      CameraPermissionStatus.granted => '',
      CameraPermissionStatus.restricted =>
        'Доступ к камере ограничен настройками устройства.',
      CameraPermissionStatus.denied =>
        'Доступ к камере запрещён. Разрешите доступ в настройках iOS.',
    };
  }
}

import 'dart:async';

import 'package:aqua_camera/features/camera_gallery/camera_gallery_constants.dart';
import 'package:flutter/widgets.dart';

class AppResumeWaiter with WidgetsBindingObserver {
  AppResumeWaiter() {
    WidgetsBinding.instance.addObserver(this);
  }

  final Completer<void> _completer = Completer<void>();

  Future<void> wait({
    Duration timeout = CameraGalleryConstants.appResumeTimeout,
  }) {
    if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
      _complete();
    }

    return _completer.future.timeout(
      timeout,
      onTimeout: () {
        _complete();
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _complete();
    }
  }

  void _complete() {
    WidgetsBinding.instance.removeObserver(this);
    if (!_completer.isCompleted) {
      _completer.complete();
    }
  }
}

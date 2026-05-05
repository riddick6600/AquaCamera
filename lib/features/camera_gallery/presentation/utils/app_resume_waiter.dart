import 'dart:async';

import 'package:flutter/widgets.dart';

class AppResumeWaiter with WidgetsBindingObserver {
  AppResumeWaiter() {
    WidgetsBinding.instance.addObserver(this);
  }

  final Completer<void> _completer = Completer<void>();

  Future<void> wait({Duration timeout = const Duration(seconds: 2)}) {
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

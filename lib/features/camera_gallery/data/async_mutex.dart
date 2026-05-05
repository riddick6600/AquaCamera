import 'dart:async';

class AsyncMutex {
  Future<void> _last = Future<void>.value();

  Future<T> run<T>(Future<T> Function() action) {
    final previous = _last;
    final next = Completer<void>();
    _last = next.future;

    return () async {
      await previous;

      try {
        return await action();
      } finally {
        next.complete();
      }
    }();
  }
}

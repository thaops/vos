import 'notification_intent.dart';

typedef IntentHandler = Future<void> Function(NotificationIntent intent);

class IntentQueue {
  final _queue = <NotificationIntent>[];
  bool _processing = false;
  IntentHandler? _handler;

  void setHandler(IntentHandler handler) {
    _handler = handler;
  }

  Future<void> enqueue(NotificationIntent intent) async {
    _queue.add(intent);

    if (!_processing) {
      await _processQueue();
    }
  }

  Future<void> _processQueue() async {
    if (_handler == null) return;

    _processing = true;

    while (_queue.isNotEmpty) {
      final intent = _queue.removeAt(0);
      try {
        await _handler!(intent);
      } catch (_) {}
    }

    _processing = false;
  }

  bool get hasPending => _queue.isNotEmpty;
}


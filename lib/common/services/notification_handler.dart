import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'notification/notification_parser.dart';
import 'notification/intent_queue.dart';
import 'notification/navigation_coordinator.dart';
import 'notification/notification_intent.dart';

class NotificationHandler {
  final NotificationParser _parser = NotificationParser();
  final IntentQueue _queue = IntentQueue();
  final NavigationCoordinator _coordinator = NavigationCoordinator();

  int? _lastProcessedId;
  DateTime? _lastProcessedTime;
  static const _dedupWindow = Duration(seconds: 2);

  NotificationHandler() {
    _queue.setHandler(_coordinator.handle);
  }

  Future<void> handleNotificationClick(OSNotificationClickEvent event) async {
    final intent = _parser.parse(event);
    if (intent == null) return;

    if (intent is TimeOffDetailIntent) {
      final now = DateTime.now();
      if (_lastProcessedId == intent.vRegId && _lastProcessedTime != null) {
        final diff = now.difference(_lastProcessedTime!);
        if (diff < _dedupWindow) {
          return;
        }
      }
      _lastProcessedId = intent.vRegId;
      _lastProcessedTime = now;
    }

    await _queue.enqueue(intent);
  }

  Future<void> handlePendingAfterLogin() async {
    await _coordinator.handlePendingAfterLogin();
  }

  Future<bool> hasPending() => _coordinator.hasPending();
}

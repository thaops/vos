abstract class NotificationIntent {
  const NotificationIntent();
}

class TimeOffDetailIntent extends NotificationIntent {
  final int vRegId;
  const TimeOffDetailIntent(this.vRegId);

  @override
  String toString() => 'TimeOffDetailIntent(vRegId: $vRegId)';
}

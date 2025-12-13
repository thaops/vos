class TimeOffWorkCodeItem {
  final String code;
  final String name;
  double days;

  TimeOffWorkCodeItem({
    required this.code,
    required this.name,
    this.days = 0.0,
  });
}

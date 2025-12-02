class LeaveLocation {
  final String code;
  final String nameVn;

  const LeaveLocation({
    required this.code,
    required this.nameVn,
  });

  LeaveLocation copyWith({
    String? code,
    String? nameVn,
  }) {
    return LeaveLocation(
      code: code ?? this.code,
      nameVn: nameVn ?? this.nameVn,
    );
  }
}


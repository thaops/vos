class VacationReason {
  final String code;
  final String nameVn;

  const VacationReason({
    required this.code,
    required this.nameVn,
  });

  VacationReason copyWith({
    String? code,
    String? nameVn,
  }) {
    return VacationReason(
      code: code ?? this.code,
      nameVn: nameVn ?? this.nameVn,
    );
  }
}


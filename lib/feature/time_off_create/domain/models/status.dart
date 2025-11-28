class Status {
  final String code;
  final String nameVn;

  const Status({
    required this.code,
    required this.nameVn,
  });

  Status copyWith({
    String? code,
    String? nameVn,
  }) {
    return Status(
      code: code ?? this.code,
      nameVn: nameVn ?? this.nameVn,
    );
  }
}


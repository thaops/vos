class AuthorizeCreate {
  final String id;
  final String? title;
  final String? description;
  final String? thumbnailUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AuthorizeCreate({
    required this.id,
    this.title,
    this.description,
    this.thumbnailUrl,
    this.createdAt,
    this.updatedAt,
  });

  AuthorizeCreate copyWith({
    String? id,
    String? title,
    String? description,
    String? thumbnailUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AuthorizeCreate(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}


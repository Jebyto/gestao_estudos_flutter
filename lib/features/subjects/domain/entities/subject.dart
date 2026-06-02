class Subject {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Subject({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Subject &&
            other.id == id &&
            other.name == name &&
            other.description == description &&
            other.createdAt == createdAt &&
            other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, description, createdAt, updatedAt);
  }
}

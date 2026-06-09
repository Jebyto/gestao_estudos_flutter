import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/subjects/data/models/subject_model.dart';
import 'package:gestao_estudos_flutter/features/subjects/domain/entities/subject.dart';

void main() {
  group('SubjectModel', () {
    test('should create a model from a domain entity', () {
      // Arrange
      final subject = Subject(
        id: 'subject-1',
        name: 'Math',
        description: 'Study for exams',
        createdAt: DateTime(2026, 6, 8),
        updatedAt: DateTime(2026, 6, 9),
      );

      // Act
      final model = SubjectModel.fromEntity(subject);

      // Assert
      expect(model.id, subject.id);
      expect(model.name, subject.name);
      expect(model.description, subject.description);
      expect(model.createdAt, subject.createdAt);
      expect(model.updatedAt, subject.updatedAt);
    });

    test('should convert a model to a domain entity', () {
      // Arrange
      final model = SubjectModel(
        id: 'subject-1',
        name: 'Math',
        description: 'Study for exams',
        createdAt: DateTime(2026, 6, 8),
        updatedAt: DateTime(2026, 6, 9),
      );

      // Act
      final subject = model.toEntity();

      // Assert
      expect(subject, isA<Subject>());
      expect(subject.id, model.id);
      expect(subject.name, model.name);
      expect(subject.description, model.description);
      expect(subject.createdAt, model.createdAt);
      expect(subject.updatedAt, model.updatedAt);
    });

    test('should convert a model to map', () {
      // Arrange
      final model = SubjectModel(
        id: 'subject-1',
        name: 'Math',
        description: 'Study for exams',
        createdAt: DateTime(2026, 6, 8),
        updatedAt: DateTime(2026, 6, 9),
      );

      // Act
      final map = model.toMap();

      // Assert
      expect(map['id'], 'subject-1');
      expect(map['name'], 'Math');
      expect(map['description'], 'Study for exams');
      expect(map['created_at'], DateTime(2026, 6, 8).toIso8601String());
      expect(map['updated_at'], DateTime(2026, 6, 9).toIso8601String());
    });

    test('should convert a map to model', () {
      // Arrange
      final map = {
        'id': 'subject-1',
        'name': 'Math',
        'description': null,
        'created_at': DateTime(2026, 6, 8).toIso8601String(),
        'updated_at': null,
      };

      // Act
      final model = SubjectModel.fromMap(map);

      // Assert
      expect(model.id, 'subject-1');
      expect(model.name, 'Math');
      expect(model.description, isNull);
      expect(model.createdAt, DateTime(2026, 6, 8));
      expect(model.updatedAt, isNull);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/subjects/domain/entities/subject.dart';

void main() {
  group('Subject', () {
    final createdAt = DateTime(2026, 6);
    final updatedAt = DateTime(2026, 6, 1);

    test('should create a valid subject', () {
      // Arrange
      const name = 'Mathematics';
      const description = 'Basic mathematics studies';

      // Act
      final subject = Subject(
        id: 'subject-1',
        name: name,
        description: description,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      // Assert
      expect(subject, isA<Subject>());
    });

    test('should keep the values passed to the constructor', () {
      // Arrange
      const name = 'Programming';
      const description = 'Flutter and Dart';

      // Act
      final subject = Subject(
        id: 'subject-1',
        name: name,
        description: description,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      // Assert
      expect(subject.id, 'subject-1');
      expect(subject.name, name);
      expect(subject.description, description);
      expect(subject.createdAt, createdAt);
      expect(subject.updatedAt, updatedAt);
    });

    test('should accept a null description', () {
      // Arrange
      const name = 'English';

      // Act
      final subject = Subject(
        id: 'subject-1',
        name: name,
        createdAt: createdAt,
      );

      // Assert
      expect(subject.description, isNull);
    });

    test('should accept a null updatedAt', () {
      // Arrange
      const name = 'Database';

      // Act
      final subject = Subject(
        id: 'subject-1',
        name: name,
        createdAt: createdAt,
      );

      // Assert
      expect(subject.updatedAt, isNull);
    });

    test('should compare subjects by value', () {
      // Arrange
      const name = 'Computer Networks';

      // Act
      final firstSubject = Subject(
        id: 'subject-1',
        name: name,
        createdAt: createdAt,
      );
      final secondSubject = Subject(
        id: 'subject-1',
        name: name,
        createdAt: createdAt,
      );

      // Assert
      expect(firstSubject, secondSubject);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/subjects/domain/entities/subject.dart';

void main() {
  group('Subject', () {
    final createdAt = DateTime(2026, 6);
    final updatedAt = DateTime(2026, 6, 1);

    test('deve criar uma matéria válida', () {
      final subject = Subject(
        id: 'subject-1',
        name: 'Matemática',
        description: 'Estudos de matemática básica',
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      expect(subject, isA<Subject>());
    });

    test('deve manter os valores passados no construtor', () {
      final subject = Subject(
        id: 'subject-1',
        name: 'Programação',
        description: 'Flutter e Dart',
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      expect(subject.id, 'subject-1');
      expect(subject.name, 'Programação');
      expect(subject.description, 'Flutter e Dart');
      expect(subject.createdAt, createdAt);
      expect(subject.updatedAt, updatedAt);
    });

    test('deve aceitar descrição nula', () {
      final subject = Subject(
        id: 'subject-1',
        name: 'Inglês',
        createdAt: createdAt,
      );

      expect(subject.description, isNull);
    });

    test('deve aceitar updatedAt nulo', () {
      final subject = Subject(
        id: 'subject-1',
        name: 'Banco de Dados',
        createdAt: createdAt,
      );

      expect(subject.updatedAt, isNull);
    });

    test('deve comparar matérias por valor', () {
      final firstSubject = Subject(
        id: 'subject-1',
        name: 'Redes de Computadores',
        createdAt: createdAt,
      );
      final secondSubject = Subject(
        id: 'subject-1',
        name: 'Redes de Computadores',
        createdAt: createdAt,
      );

      expect(firstSubject, secondSubject);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/core/database/app_database.dart';
import 'package:gestao_estudos_flutter/features/reviews/data/datasources/review_local_datasource.dart';
import 'package:gestao_estudos_flutter/features/reviews/data/models/review_model.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/entities/review.dart';
import 'package:gestao_estudos_flutter/features/subjects/data/datasources/subject_local_datasource.dart';
import 'package:gestao_estudos_flutter/features/subjects/data/models/subject_model.dart';
import 'package:gestao_estudos_flutter/features/topics/data/datasources/topic_local_datasource.dart';
import 'package:gestao_estudos_flutter/features/topics/data/models/topic_model.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/entities/topic.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('ReviewLocalDataSourceImpl', () {
    late AppDatabase appDatabase;
    late SubjectLocalDataSourceImpl subjectDataSource;
    late TopicLocalDataSourceImpl topicDataSource;
    late ReviewLocalDataSourceImpl reviewDataSource;
    late Future<void> Function({required String id}) createTopic;

    setUp(() {
      sqfliteFfiInit();
      appDatabase = AppDatabase(
        databasePath: inMemoryDatabasePath,
        databaseFactory: databaseFactoryFfi,
        singleInstance: false,
      );
      subjectDataSource = SubjectLocalDataSourceImpl(appDatabase);
      topicDataSource = TopicLocalDataSourceImpl(appDatabase);
      reviewDataSource = ReviewLocalDataSourceImpl(appDatabase);
      createTopic = ({required String id}) async {
        final subjectId = 'subject-$id';
        await subjectDataSource.createSubject(makeSubject(id: subjectId));
        await topicDataSource.createTopic(
          makeTopic(id: id, subjectId: subjectId),
        );
      };
    });

    tearDown(() async {
      await appDatabase.close();
    });

    test('should save and get reviews from SQLite', () async {
      // Arrange
      await createTopic(id: 'topic-1');
      final review = makeReview(id: 'review-1', topicId: 'topic-1');

      // Act
      await reviewDataSource.createReview(review);
      final reviews = await reviewDataSource.getReviews();

      // Assert
      expect(reviews.length, 1);
      expect(reviews.first.id, 'review-1');
      expect(reviews.first.topicId, 'topic-1');
      expect(reviews.first.reviewedAt, isNull);
      expect(reviews.first.quality, isNull);
    });

    test('should get a review by id', () async {
      // Arrange
      await createTopic(id: 'topic-1');
      await reviewDataSource.createReview(
        makeReview(id: 'review-1', topicId: 'topic-1'),
      );

      // Act
      final review = await reviewDataSource.getReviewById('review-1');

      // Assert
      expect(review?.id, 'review-1');
    });

    test('should return null when review is not found', () async {
      // Arrange

      // Act
      final review = await reviewDataSource.getReviewById('missing-review');

      // Assert
      expect(review, isNull);
    });

    test('should return reviews by topic', () async {
      // Arrange
      await createTopic(id: 'topic-1');
      await createTopic(id: 'topic-2');
      await reviewDataSource.createReview(
        makeReview(id: 'review-1', topicId: 'topic-1'),
      );
      await reviewDataSource.createReview(
        makeReview(id: 'review-2', topicId: 'topic-2'),
      );

      // Act
      final reviews = await reviewDataSource.getReviewsByTopic('topic-1');

      // Assert
      expect(reviews.length, 1);
      expect(reviews.first.id, 'review-1');
    });

    test('should order reviews by scheduledFor ascending', () async {
      // Arrange
      await createTopic(id: 'topic-1');
      await reviewDataSource.createReview(
        makeReview(
          id: 'review-1',
          topicId: 'topic-1',
          scheduledFor: DateTime(2026, 6, 28),
        ),
      );
      await reviewDataSource.createReview(
        makeReview(
          id: 'review-2',
          topicId: 'topic-1',
          scheduledFor: DateTime(2026, 6, 25),
        ),
      );

      // Act
      final reviews = await reviewDataSource.getReviews();

      // Assert
      expect(reviews.map((review) => review.id), ['review-2', 'review-1']);
    });

    test('should update a review in SQLite', () async {
      // Arrange
      await createTopic(id: 'topic-1');
      await reviewDataSource.createReview(
        makeReview(id: 'review-1', topicId: 'topic-1'),
      );
      final completedReview = makeReview(
        id: 'review-1',
        topicId: 'topic-1',
        reviewedAt: DateTime(2026, 6, 25),
        quality: ReviewQuality.good,
      );

      // Act
      await reviewDataSource.updateReview(completedReview);
      final review = await reviewDataSource.getReviewById('review-1');

      // Assert
      expect(review?.reviewedAt, DateTime(2026, 6, 25));
      expect(review?.quality, ReviewQuality.good);
    });

    test('should replace a review when creating with an existing id', () async {
      // Arrange
      await createTopic(id: 'topic-1');
      await reviewDataSource.createReview(
        makeReview(id: 'review-1', topicId: 'topic-1'),
      );
      await reviewDataSource.createReview(
        makeReview(
          id: 'review-1',
          topicId: 'topic-1',
          scheduledFor: DateTime(2026, 6, 30),
        ),
      );

      // Act
      final reviews = await reviewDataSource.getReviews();

      // Assert
      expect(reviews.length, 1);
      expect(reviews.first.scheduledFor, DateTime(2026, 6, 30));
    });

    test('should reject a review when the topic does not exist', () async {
      // Arrange
      final review = makeReview(id: 'review-1', topicId: 'missing-topic');

      // Act
      Future<void> action() => reviewDataSource.createReview(review);

      // Assert
      expect(action, throwsA(isA<DatabaseException>()));
    });

    test('should delete topic reviews when the topic is deleted', () async {
      // Arrange
      await createTopic(id: 'topic-1');
      await reviewDataSource.createReview(
        makeReview(id: 'review-1', topicId: 'topic-1'),
      );

      // Act
      await topicDataSource.deleteTopic('topic-1');
      final reviews = await reviewDataSource.getReviews();

      // Assert
      expect(reviews, isEmpty);
    });

    test('should save review quality as a string', () async {
      // Arrange
      await createTopic(id: 'topic-1');
      await reviewDataSource.createReview(
        makeReview(
          id: 'review-1',
          topicId: 'topic-1',
          reviewedAt: DateTime(2026, 6, 25),
          quality: ReviewQuality.hard,
        ),
      );
      final database = await appDatabase.database;

      // Act
      final result = await database.query(
        'reviews',
        columns: ['quality'],
        where: 'id = ?',
        whereArgs: ['review-1'],
      );

      // Assert
      expect(result.first['quality'], 'hard');
    });

    test('should save review quality as null when review is pending', () async {
      // Arrange
      await createTopic(id: 'topic-1');
      await reviewDataSource.createReview(
        makeReview(id: 'review-1', topicId: 'topic-1'),
      );
      final database = await appDatabase.database;

      // Act
      final result = await database.query(
        'reviews',
        columns: ['quality'],
        where: 'id = ?',
        whereArgs: ['review-1'],
      );

      // Assert
      expect(result.first['quality'], isNull);
    });
  });
}

SubjectModel makeSubject({required String id}) {
  return SubjectModel(id: id, name: 'Math', createdAt: DateTime(2026, 6, 24));
}

TopicModel makeTopic({required String id, required String subjectId}) {
  return TopicModel(
    id: id,
    subjectId: subjectId,
    title: 'Functions',
    status: TopicStatus.notStarted,
    priority: TopicPriority.medium,
    createdAt: DateTime(2026, 6, 24),
  );
}

ReviewModel makeReview({
  required String id,
  required String topicId,
  DateTime? scheduledFor,
  DateTime? reviewedAt,
  ReviewQuality? quality,
}) {
  return ReviewModel(
    id: id,
    topicId: topicId,
    scheduledFor: scheduledFor ?? DateTime(2026, 6, 25),
    reviewedAt: reviewedAt,
    quality: quality,
    createdAt: DateTime(2026, 6, 24),
  );
}

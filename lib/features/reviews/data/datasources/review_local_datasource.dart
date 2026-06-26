import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../models/review_model.dart';

abstract class ReviewLocalDataSource {
  Future<void> createReview(ReviewModel review);
  Future<List<ReviewModel>> getReviews();
  Future<ReviewModel?> getReviewById(String id);
  Future<List<ReviewModel>> getReviewsByTopic(String topicId);
  Future<void> updateReview(ReviewModel review);
}

class ReviewLocalDataSourceImpl implements ReviewLocalDataSource {
  final AppDatabase appDatabase;

  const ReviewLocalDataSourceImpl(this.appDatabase);

  @override
  Future<void> createReview(ReviewModel review) async {
    final database = await appDatabase.database;

    await database.insert(
      'reviews',
      review.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<ReviewModel?> getReviewById(String id) async {
    final database = await appDatabase.database;
    final result = await database.query(
      'reviews',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) return null;

    return ReviewModel.fromMap(result.first);
  }

  @override
  Future<List<ReviewModel>> getReviews() async {
    final database = await appDatabase.database;
    final result = await database.query(
      'reviews',
      orderBy: 'scheduled_for ASC',
    );

    return result.map(ReviewModel.fromMap).toList();
  }

  @override
  Future<List<ReviewModel>> getReviewsByTopic(String topicId) async {
    final database = await appDatabase.database;
    final result = await database.query(
      'reviews',
      where: 'topic_id = ?',
      whereArgs: [topicId],
      orderBy: 'scheduled_for ASC',
    );

    return result.map(ReviewModel.fromMap).toList();
  }

  @override
  Future<void> updateReview(ReviewModel review) async {
    final database = await appDatabase.database;

    await database.update(
      'reviews',
      review.toMap(),
      where: 'id = ?',
      whereArgs: [review.id],
    );
  }
}

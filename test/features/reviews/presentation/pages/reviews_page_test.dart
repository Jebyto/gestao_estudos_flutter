import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/entities/review.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/repositories/review_repository.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/usecases/complete_review.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/usecases/create_review.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/usecases/get_pending_reviews.dart';
import 'package:gestao_estudos_flutter/features/reviews/presentation/cubit/reviews_cubit.dart';
import 'package:gestao_estudos_flutter/features/reviews/presentation/pages/reviews_page.dart';
import 'package:gestao_estudos_flutter/features/subjects/domain/entities/subject.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/entities/topic.dart';

void main() {
  late FakeReviewRepository repository;
  late ReviewsCubit cubit;
  final today = DateTime(2026, 7, 3, 9);
  final subject = Subject(
    id: 'subject-1',
    name: 'Banco de Dados',
    createdAt: today,
  );
  final topics = [
    Topic(
      id: 'topic-1',
      subjectId: subject.id,
      title: 'Normalização',
      status: TopicStatus.review,
      priority: TopicPriority.high,
      createdAt: today,
    ),
  ];

  setUp(() {
    repository = FakeReviewRepository();
    cubit = ReviewsCubit(
      topicIds: topics.map((topic) => topic.id).toList(),
      getPendingReviews: GetPendingReviews(repository),
      createReviewUseCase: CreateReview(repository),
      completeReviewUseCase: CompleteReview(
        repository,
        generateReviewId: () => 'review-next',
      ),
      generateReviewId: () => 'review-created',
      now: () => today,
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  testWidgets('deve exibir estado vazio quando não houver revisões', (
    tester,
  ) async {
    await cubit.loadPendingReviews();
    await tester.pumpReviewsPage(cubit, subject, topics);

    expect(find.text('Revisões - Banco de Dados'), findsOneWidget);
    expect(find.text('Nenhuma revisão pendente'), findsOneWidget);
  });

  testWidgets('deve listar revisões pendentes', (tester) async {
    repository.reviews.add(
      Review(
        id: 'review-1',
        topicId: 'topic-1',
        scheduledFor: today,
        createdAt: today,
      ),
    );

    await cubit.loadPendingReviews();
    await tester.pumpReviewsPage(cubit, subject, topics);

    expect(find.text('Normalização'), findsOneWidget);
    expect(find.text('Agendada para 03/07/2026'), findsOneWidget);
    expect(find.text('Difícil'), findsOneWidget);
    expect(find.text('Boa'), findsOneWidget);
    expect(find.text('Fácil'), findsOneWidget);
  });

  testWidgets('deve criar revisão pelo formulário', (tester) async {
    await cubit.loadPendingReviews();
    await tester.pumpReviewsPage(cubit, subject, topics);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
    await tester.pumpAndSettle();

    expect(repository.reviews.length, 1);
    expect(repository.reviews.first.id, 'review-created');
    expect(repository.reviews.first.topicId, 'topic-1');
    expect(find.text('Normalização'), findsOneWidget);
  });

  testWidgets('deve concluir revisão pela tela', (tester) async {
    repository.reviews.add(
      Review(
        id: 'review-1',
        topicId: 'topic-1',
        scheduledFor: today,
        createdAt: today,
      ),
    );

    await cubit.loadPendingReviews();
    await tester.pumpReviewsPage(cubit, subject, topics);
    await tester.tap(find.widgetWithText(FilledButton, 'Boa'));
    await tester.pumpAndSettle();

    expect(repository.reviews.length, 2);
    expect(repository.reviews.first.reviewedAt, today);
    expect(repository.reviews.first.quality, ReviewQuality.good);
    expect(repository.reviews.last.id, 'review-next');
    expect(find.text('Nenhuma revisão pendente'), findsOneWidget);
  });
}

extension on WidgetTester {
  Future<void> pumpReviewsPage(
    ReviewsCubit cubit,
    Subject subject,
    List<Topic> topics,
  ) {
    return pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: ReviewsPage(subject: subject, topics: topics),
        ),
      ),
    );
  }
}

class FakeReviewRepository implements ReviewRepository {
  final List<Review> reviews = [];

  @override
  Future<void> createReview(Review review) async {
    reviews.add(review);
  }

  @override
  Future<Review?> getReviewById(String id) async {
    for (final review in reviews) {
      if (review.id == id) return review;
    }

    return null;
  }

  @override
  Future<List<Review>> getReviews() async {
    return reviews;
  }

  @override
  Future<List<Review>> getReviewsByTopic(String topicId) async {
    return reviews.where((review) => review.topicId == topicId).toList();
  }

  @override
  Future<void> updateReview(Review review) async {
    final index = reviews.indexWhere((currentReview) {
      return currentReview.id == review.id;
    });

    reviews[index] = review;
  }
}

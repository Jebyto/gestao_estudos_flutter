import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/entities/review.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/repositories/review_repository.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/usecases/complete_review.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/usecases/cancel_review.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/usecases/reschedule_review.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/usecases/create_review.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/usecases/get_reviews_by_topic.dart';
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
      getReviewsByTopic: GetReviewsByTopic(repository),
      createReviewUseCase: CreateReview(repository),
      completeReviewUseCase: CompleteReview(
        repository,
        generateReviewId: () => 'review-next',
      ),
      cancelReviewUseCase: CancelReview(repository),
      rescheduleReviewUseCase: RescheduleReview(repository, now: () => today),
      generateReviewId: () => 'review-created',
      now: () => today,
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  testWidgets('cancelamento exige confirmação e preserva histórico', (
    tester,
  ) async {
    final pending = Review(
      id: 'pending',
      topicId: 'topic-1',
      scheduledFor: today.add(const Duration(days: 7)),
      createdAt: today,
    );
    final history = Review(
      id: 'history',
      topicId: 'topic-1',
      scheduledFor: today,
      reviewedAt: today,
      quality: ReviewQuality.good,
      createdAt: today,
    );
    repository.reviews.addAll([pending, history]);
    await cubit.loadReviews();
    await tester.pumpReviewsPage(cubit, subject, topics);
    await tester.tap(find.byTooltip('Cancelar revisão'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Voltar'));
    await tester.pumpAndSettle();
    expect(repository.reviews, [pending, history]);
    await tester.tap(find.byTooltip('Cancelar revisão'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Cancelar revisão'));
    await tester.pumpAndSettle();
    expect(repository.reviews, [history]);
    expect(find.text('Nenhuma revisão pendente'), findsOneWidget);
    await tester.tap(find.text('Histórico'));
    await tester.pumpAndSettle();
    expect(find.text('Qualidade: Boa'), findsOneWidget);
    expect(find.byTooltip('Cancelar revisão'), findsNothing);
    expect(find.byTooltip('Reagendar revisão'), findsNothing);
  });

  testWidgets('reagenda no calendário e mantém a pendência acessível', (
    tester,
  ) async {
    final pending = Review(
      id: 'pending',
      topicId: 'topic-1',
      scheduledFor: today,
      createdAt: today,
    );
    repository.reviews.add(pending);
    await cubit.loadReviews();
    await tester.pumpReviewsPage(cubit, subject, topics);
    await tester.tap(find.byTooltip('Reagendar revisão'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Voltar'));
    await tester.pumpAndSettle();
    expect(repository.reviews, [pending]);
    await tester.tap(find.byTooltip('Reagendar revisão'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('20'));
    await tester.tap(find.text('Reagendar'));
    await tester.pumpAndSettle();
    expect(repository.reviews.single.id, pending.id);
    expect(repository.reviews.single.scheduledFor, DateTime(2026, 7, 20));
    expect(find.text('Agendada para 20/07/2026'), findsOneWidget);
    expect(find.byTooltip('Cancelar revisão'), findsOneWidget);
  });

  testWidgets('exibe falha e permite repetir cancelamento', (tester) async {
    repository.reviews.add(
      Review(
        id: 'pending',
        topicId: 'topic-1',
        scheduledFor: today,
        createdAt: today,
      ),
    );
    await cubit.loadReviews();
    await tester.pumpReviewsPage(cubit, subject, topics);
    repository.failDelete = true;
    await tester.tap(find.byTooltip('Cancelar revisão'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Cancelar revisão'));
    await tester.pumpAndSettle();
    expect(find.text('Não foi possível cancelar a revisão.'), findsOneWidget);
    expect(repository.reviews, hasLength(1));
    repository.failDelete = false;
    await tester.tap(find.byTooltip('Cancelar revisão'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Cancelar revisão'));
    await tester.pumpAndSettle();
    expect(repository.reviews, isEmpty);
  });

  testWidgets('deve exibir estado vazio quando não houver revisões', (
    tester,
  ) async {
    await cubit.loadReviews();
    await tester.pumpReviewsPage(cubit, subject, topics);

    expect(find.text('Revisões - Banco de Dados'), findsOneWidget);
    expect(find.text('Nenhuma revisão pendente'), findsOneWidget);
    expect(find.text('Pendentes'), findsOneWidget);
    expect(find.text('Histórico'), findsOneWidget);
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

    await cubit.loadReviews();
    await tester.pumpReviewsPage(cubit, subject, topics);

    expect(find.text('Normalização'), findsOneWidget);
    expect(find.text('Agendada para 03/07/2026'), findsOneWidget);
    expect(find.text('Difícil'), findsOneWidget);
    expect(find.text('Boa'), findsOneWidget);
    expect(find.text('Fácil'), findsOneWidget);
  });

  testWidgets('deve criar revisão pelo formulário', (tester) async {
    await cubit.loadReviews();
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

    await cubit.loadReviews();
    await tester.pumpReviewsPage(cubit, subject, topics);
    await tester.tap(find.widgetWithText(FilledButton, 'Boa'));
    await tester.pumpAndSettle();

    expect(repository.reviews.length, 2);
    expect(repository.reviews.first.reviewedAt, today);
    expect(repository.reviews.first.quality, ReviewQuality.good);
    expect(repository.reviews.last.id, 'review-next');
    expect(find.text('Agendada para 06/07/2026'), findsOneWidget);
  });

  testWidgets('deve exibir revisões concluídas no histórico', (tester) async {
    repository.reviews.add(
      Review(
        id: 'review-1',
        topicId: 'topic-1',
        scheduledFor: today.subtract(const Duration(days: 3)),
        reviewedAt: today,
        quality: ReviewQuality.good,
        createdAt: today.subtract(const Duration(days: 3)),
      ),
    );

    await cubit.loadReviews();
    await tester.pumpReviewsPage(cubit, subject, topics);
    await tester.tap(find.text('Histórico'));
    await tester.pumpAndSettle();

    expect(find.text('Normalização'), findsOneWidget);
    expect(find.text('Revisada em 03/07/2026'), findsOneWidget);
    expect(find.text('Qualidade: Boa'), findsOneWidget);
  });

  testWidgets('deve exibir estado vazio no histórico', (tester) async {
    await cubit.loadReviews();
    await tester.pumpReviewsPage(cubit, subject, topics);
    await tester.tap(find.text('Histórico'));
    await tester.pumpAndSettle();

    expect(find.text('Nenhuma revisão concluída'), findsOneWidget);
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
  bool failDelete = false;
  @override
  Future<void> deleteReview(String id) async {
    if (failDelete) throw StateError('write failed');
    reviews.removeWhere((review) => review.id == id);
  }

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

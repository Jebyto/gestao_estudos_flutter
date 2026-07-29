import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/entities/review.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/repositories/review_repository.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/usecases/complete_review.dart';
import 'package:gestao_estudos_flutter/features/reviews/domain/usecases/get_review_overview.dart';
import 'package:gestao_estudos_flutter/features/reviews/presentation/cubit/review_overview_cubit.dart';
import 'package:gestao_estudos_flutter/features/reviews/presentation/pages/review_overview_page.dart';
import 'package:gestao_estudos_flutter/features/subjects/domain/entities/subject.dart';
import 'package:gestao_estudos_flutter/features/subjects/domain/repositories/subject_repository.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/entities/topic.dart';
import 'package:gestao_estudos_flutter/features/topics/domain/repositories/topic_repository.dart';

void main() {
  late FakeSubjectRepository subjectRepository;
  late FakeTopicRepository topicRepository;
  late FakeReviewRepository reviewRepository;
  late ReviewOverviewCubit cubit;
  final today = DateTime(2026, 7, 10, 9);
  final subject = Subject(
    id: 'subject-1',
    name: 'Banco de Dados',
    createdAt: DateTime(2026, 7, 1),
  );
  final topic = Topic(
    id: 'topic-1',
    subjectId: 'subject-1',
    title: 'Normalização',
    status: TopicStatus.review,
    priority: TopicPriority.high,
    createdAt: DateTime(2026, 7, 1),
  );

  setUp(() {
    subjectRepository = FakeSubjectRepository()..subjects.add(subject);
    topicRepository = FakeTopicRepository()..topics.add(topic);
    reviewRepository = FakeReviewRepository();
    cubit = ReviewOverviewCubit(
      getReviewOverview: GetReviewOverview(
        subjectRepository: subjectRepository,
        topicRepository: topicRepository,
        reviewRepository: reviewRepository,
      ),
      completeReviewUseCase: CompleteReview(
        reviewRepository,
        generateReviewId: () => 'review-next',
      ),
      now: () => today,
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  testWidgets('deve exibir estado vazio das revisões globais', (tester) async {
    await cubit.loadOverview();
    await tester.pumpOverviewPage(cubit);

    expect(find.text('Nenhuma revisão pendente'), findsOneWidget);

    await tester.tap(find.text('Histórico'));
    await tester.pumpAndSettle();

    expect(find.text('Nenhuma revisão concluída'), findsOneWidget);
  });

  testWidgets('deve exibir tópico e matéria nas pendências', (tester) async {
    reviewRepository.reviews.add(
      Review(
        id: 'review-1',
        topicId: topic.id,
        scheduledFor: today,
        createdAt: today,
      ),
    );

    await cubit.loadOverview();
    await tester.pumpOverviewPage(cubit);

    expect(find.text('Normalização'), findsOneWidget);
    expect(find.text('Banco de Dados'), findsOneWidget);
    expect(find.text('Agendada para 10/07/2026'), findsOneWidget);
  });

  testWidgets('deve exibir matéria no histórico global', (tester) async {
    reviewRepository.reviews.add(
      Review(
        id: 'review-1',
        topicId: topic.id,
        scheduledFor: today.subtract(const Duration(days: 3)),
        reviewedAt: today,
        quality: ReviewQuality.easy,
        createdAt: today.subtract(const Duration(days: 3)),
      ),
    );

    await cubit.loadOverview();
    await tester.pumpOverviewPage(cubit);
    await tester.tap(find.text('Histórico'));
    await tester.pumpAndSettle();

    expect(find.text('Normalização'), findsOneWidget);
    expect(find.text('Banco de Dados'), findsOneWidget);
    expect(find.text('Qualidade: Fácil'), findsOneWidget);
  });
}

extension on WidgetTester {
  Future<void> pumpOverviewPage(ReviewOverviewCubit cubit) {
    return pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cubit,
          child: const ReviewOverviewPage(),
        ),
      ),
    );
  }
}

class FakeSubjectRepository implements SubjectRepository {
  final List<Subject> subjects = [];

  @override
  Future<void> createSubject(Subject subject) async {}

  @override
  Future<void> deleteSubject(String id) async {}

  @override
  Future<List<Subject>> getSubjects() async => subjects;
}

class FakeTopicRepository implements TopicRepository {
  final List<Topic> topics = [];

  @override
  Future<void> createTopic(Topic topic) async {}

  @override
  Future<void> deleteTopic(String id) async {}

  @override
  Future<List<Topic>> getTopicsBySubject(String subjectId) async {
    return topics.where((topic) => topic.subjectId == subjectId).toList();
  }

  @override
  Future<void> updateTopicStatus(String topicId, TopicStatus status) async {}
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
  Future<List<Review>> getReviews() async => reviews;

  @override
  Future<List<Review>> getReviewsByTopic(String topicId) async {
    return reviews.where((review) => review.topicId == topicId).toList();
  }

  @override
  Future<void> updateReview(Review review) async {
    final index = reviews.indexWhere((item) => item.id == review.id);
    reviews[index] = review;
  }
}

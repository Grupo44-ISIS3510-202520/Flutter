// domain/use_cases/get_rag_answer.dart

import '../../data/models/rag_model.dart';
import '../../data/repositories/rag_repository.dart';

class GetRagAnswer {
  final RagRepository repository;

  GetRagAnswer({required this.repository});

  Stream<RagState> call(String query) async* {
    if (query.trim().isEmpty) {
      yield RagError('Question cannot be empty');
      return;
    }

    yield RagLoading();

    try {
      final (response, fromCache) = await repository.getAnswer(query);

      yield RagSuccess(
        answer: response.answer,
        sources: response.sources,
        fromCache: fromCache,
      );
    } catch (e) {
      yield RagError(e.toString());
    }
  }
}
import '../../../../core/usecase/usecase.dart';
import '../repository/news_repository.dart';
import '../entities/news_entity.dart';

class SearchNewsUseCase
    implements UseCase<(List<NewsEntity>, String?), SearchParams> {
  final NewsRepository repository;

  SearchNewsUseCase(this.repository);

  @override
  Future<(List<NewsEntity>, String?)> call(SearchParams params) {
    return repository.searchNews(params.query, params.nextPage);
  }
}

class SearchParams {
  final String query;
  final String? nextPage;

  SearchParams(this.query, this.nextPage);
}

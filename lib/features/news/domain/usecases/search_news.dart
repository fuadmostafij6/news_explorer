import '../../../../core/usecase/usecase.dart';
import '../repository/news_repository.dart';
import '../entities/news_entity.dart';

class SearchNewsUseCase
    implements UseCase<(List<NewsEntity>, String?), SearchNewsParams> {
  SearchNewsUseCase(this.repository);

  final NewsRepository repository;

  @override
  Future<(List<NewsEntity>, String?)> call(SearchNewsParams params) {
    return repository.searchNews(
      params.query,
      params.nextPage,
      params.category,
    );
  }
}

class SearchNewsParams {
  const SearchNewsParams({
    required this.query,
    required this.category,
    this.nextPage,
  });

  final String query;
  final String? nextPage;
  final String category;
}

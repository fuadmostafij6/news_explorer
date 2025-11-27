import '../../../../core/usecase/usecase.dart';
import '../repository/news_repository.dart';
import '../entities/news_entity.dart';

class CacheNewsUseCase implements UseCase<void, CacheParams> {
  final NewsRepository repository;

  CacheNewsUseCase(this.repository);

  @override
  Future<void> call(CacheParams params) {
    return repository.cacheNews(params.news);
  }
}

class CacheParams {
  final List<NewsEntity> news;

  CacheParams(this.news);
}

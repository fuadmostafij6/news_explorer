import '../../../../core/usecase/usecase.dart';
import '../repository/news_repository.dart';
import '../entities/news_entity.dart';

class GetNewsByCategoryUsecase
    implements UseCase<(List<NewsEntity>, String?), GetNewsByCategoryParams> {
  GetNewsByCategoryUsecase(this.repository);

  final NewsRepository repository;

  @override
  Future<(List<NewsEntity>, String?)> call(
    GetNewsByCategoryParams params,
  ) {
    return repository.getNewsByCategory(
      params.category,
      params.nextPage,
      pageId: params.pageId,
      resetCache: params.resetCache,
    );
  }
}

class GetNewsByCategoryParams {
  const GetNewsByCategoryParams({
    required this.category,
    this.nextPage,
    required this.pageId,
    this.resetCache = false,
  });

  final String category;
  final String? nextPage;
  final String pageId;
  final bool resetCache;
}

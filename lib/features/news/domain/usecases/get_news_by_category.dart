import '../../../../core/usecase/usecase.dart';
import '../repository/news_repository.dart';
import '../entities/news_entity.dart';

class GetNewsByCategoryUsecase
    implements UseCase<(List<NewsEntity>, String?), Params> {
  final NewsRepository repo;

  GetNewsByCategoryUsecase(this.repo);

  @override
  Future<(List<NewsEntity>, String?)> call(Params params) async {
    return repo.getNewsByCategory(params.category, params.nextPage);
  }
}

class Params {
  final String category;
  final String? nextPage;

  Params(this.category, this.nextPage);
}

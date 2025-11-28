import '../../domain/entities/news_entity.dart';
import '../../domain/repository/news_repository.dart';
import '../datasources/news_local_data_source.dart';
import '../datasources/news_remote_data_source.dart';
import '../models/news_model.dart';

class NewsRepositoryImpl implements NewsRepository {
  NewsRepositoryImpl(this.remote, this.local);

  final NewsRemoteDataSource remote;
  final NewsLocalDataSource local;

  @override
  Future<(List<NewsEntity>, String?)> getNewsByCategory(
    String category,
    String? nextPage, {
    required String pageId,
    bool resetCache = false,
  }) async {
    try {
      final response = await remote.fetchNews(category, nextPage);
      await local.cacheNewsPage(
        news: response.results,
        pageId: pageId,
        reset: resetCache,
      );
      return (response.results, response.nextPage);
    } catch (_) {
      final cached = await local.getCachedNews();
      return (cached, null);
    }
  }

  @override
  Future<(List<NewsEntity>, String?)> searchNews(
    String query,
    String? nextPage,
    String category,
  ) async {
    try {
      final response = await remote.searchNews(query, nextPage, category);
      return (response.results, response.nextPage);
    } catch (_) {
      final cached = await local.getCachedNews();
      final filtered = cached
          .where(
            (e) => (e.title ?? '').toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
      return (filtered, null);
    }
  }

  @override
  Future<void> cacheNews(List<NewsEntity> news) async {
    final models = news
        .map((e) => e is NewsModel ? e : NewsModel.fromEntity(e))
        .toList();
    await local.cacheNewsPage(news: models, pageId: 'manual', reset: true);
  }

  @override
  Future<List<NewsEntity>> getCachedNews() {
    return local.getCachedNews();
  }

  @override
  Future<List<(String, List<NewsEntity>)>> getCachedNewsPages() async {
    final pages = await local.getCachedPages();
    return pages
        .map(
          (entry) =>
              (entry.$1, entry.$2.map<NewsEntity>((model) => model).toList()),
        )
        .toList();
  }
}

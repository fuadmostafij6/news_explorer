import 'package:news_app/features/news/domain/entities/news_entity.dart';

abstract class NewsRepository {
  Future<(List<NewsEntity>, String?)> getNewsByCategory(
    String category,
    String? nextPage, {
    required String pageId,
    bool resetCache = false,
  });

  Future<(List<NewsEntity>, String?)> searchNews(
    String query,
    String? nextPage,
    String category,
  );
  Future<void> cacheNews(List<NewsEntity> news);
  Future<List<NewsEntity>> getCachedNews();
  Future<List<(String pageId, List<NewsEntity> articles)>> getCachedNewsPages();
}

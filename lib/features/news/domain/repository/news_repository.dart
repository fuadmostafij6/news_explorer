import 'package:news_app/features/news/domain/entities/news_entity.dart';

abstract class NewsRepository {
  Future<(List<NewsEntity>, String?)> getNewsByCategory(
    String category,
    String? nextPage,
  );

  Future<(List<NewsEntity>, String?)> searchNews(
    String query,
    String? nextPage,
  );
  Future<void> cacheNews(List<NewsEntity> news);
}

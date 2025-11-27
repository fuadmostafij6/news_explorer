import 'package:news_app/features/news/data/models/news_model.dart';

import '../../domain/repository/news_repository.dart';
import '../datasources/news_remote_data_source.dart';
import '../datasources/news_local_data_source.dart';
import '../../domain/entities/news_entity.dart';

class NewsRepositoryImpl implements NewsRepository {
  final NewsRemoteDataSource remote;
  final NewsLocalDataSource local;

  NewsRepositoryImpl(this.remote, this.local);

  @override
  Future<(List<NewsEntity>, String?)> getNewsByCategory(
    String category,
    String? nextPage,
  ) async {
    try {
      final response = await remote.fetchNews(category, nextPage);

      await local.cacheNews(response.results);

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
  ) async {
    try {
      final response = await remote.searchNews(query, nextPage);
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
    await local.cacheNews(news.cast<NewsModel>());
  }
}

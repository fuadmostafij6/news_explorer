import 'package:hive/hive.dart';
import '../models/news_model.dart';
import '../../../../core/error/exceptions.dart';

abstract class NewsLocalDataSource {
  Future<void> cacheNews(List<NewsModel> news);
  Future<List<NewsModel>> getCachedNews();
}

class NewsLocalDataSourceImpl implements NewsLocalDataSource {
  final Box box;

  NewsLocalDataSourceImpl(this.box);

  @override
  Future<void> cacheNews(List<NewsModel> news) async {
    await box.put('news_cache', news.map((e) => e.toJson()).toList());

    await box.put('cache_time', DateTime.now().millisecondsSinceEpoch);
  }

  @override
  Future<List<NewsModel>> getCachedNews() async {
    final data = box.get('news_cache');

    if (data == null) throw CacheException();

    return (data as List)
        .map((e) => NewsModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}

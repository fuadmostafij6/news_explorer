import 'package:hive/hive.dart';
import '../models/news_model.dart';
import '../../../../core/error/exceptions.dart';

const _newsCachePagesKey = 'news_cache_pages';
const _cacheTimestampKey = 'news_cache_timestamp';
const _cacheDuration = Duration(hours: 1);

abstract class NewsLocalDataSource {
  Future<void> cacheNewsPage({
    required List<NewsModel> news,
    required String pageId,
    required bool reset,
  });
  Future<List<(String pageId, List<NewsModel> articles)>> getCachedPages();
  Future<List<NewsModel>> getCachedNews();
}

class NewsLocalDataSourceImpl implements NewsLocalDataSource {
  final Box box;

  NewsLocalDataSourceImpl(this.box);

  @override
  Future<void> cacheNewsPage({
    required List<NewsModel> news,
    required String pageId,
    required bool reset,
  }) async {
    final List<Map<String, dynamic>> existingPages = reset
        ? []
        : List<Map<String, dynamic>>.from(
            box.get(_newsCachePagesKey) as List? ?? [],
          );

    final pageMap = <String, dynamic>{
      'id': pageId,
      'items': news.map((e) => e.toJson()).toList(),
    };

    final idx = existingPages.indexWhere((element) => element['id'] == pageId);
    if (idx >= 0) {
      existingPages[idx] = pageMap;
    } else {
      existingPages.add(pageMap);
    }

    await box.put(_newsCachePagesKey, existingPages);
    await box.put(_cacheTimestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  @override
  Future<List<(String pageId, List<NewsModel> articles)>> getCachedPages() async {
    final cachedData = box.get(_newsCachePagesKey);
    final cachedTimestamp = box.get(_cacheTimestampKey) as int?;

    if (cachedData == null || cachedTimestamp == null) {
      throw CacheException();
    }

    final cachedTime =
        DateTime.fromMillisecondsSinceEpoch(cachedTimestamp, isUtc: false);
    final isExpired = DateTime.now().difference(cachedTime) > _cacheDuration;

    if (isExpired) {
      throw CacheException();
    }

    final List data = cachedData as List;
    return data
        .map(
          (page) => (
            page['id'] as String,
            (page['items'] as List)
                .map(
                  (item) => NewsModel.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ),
                )
                .toList()
          ),
        )
        .toList();
  }

  @override
  Future<List<NewsModel>> getCachedNews() async {
    final pages = await getCachedPages();
    return pages.expand((page) => page.$2).toList();
  }
}

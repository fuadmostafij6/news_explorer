import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../features/news/data/datasources/news_local_data_source.dart';
import '../../features/news/data/datasources/news_remote_data_source.dart';
import '../../features/news/data/repository_impl/news_repository_impl.dart';
import '../../features/news/domain/repository/news_repository.dart';
import '../../features/news/domain/usecases/get_news_by_category.dart';
import '../../features/news/domain/usecases/search_news.dart';

const String newsCacheBoxName = 'news_cache_box';

final hiveNewsBoxProvider = Provider<Box>((ref) {
  throw UnimplementedError('Provide Hive box via override in main.dart');
});

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
    ),
  );
  return dio;
});

final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

final newsRemoteDataSourceProvider = Provider<NewsRemoteDataSource>((ref) {
  return NewsRemoteDataSourceImpl(ref.watch(dioProvider));
});

final newsLocalDataSourceProvider = Provider<NewsLocalDataSource>((ref) {
  return NewsLocalDataSourceImpl(ref.watch(hiveNewsBoxProvider));
});

final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  return NewsRepositoryImpl(
    ref.watch(newsRemoteDataSourceProvider),
    ref.watch(newsLocalDataSourceProvider),
  );
});

final getNewsByCategoryUseCaseProvider =
    Provider<GetNewsByCategoryUsecase>((ref) {
  return GetNewsByCategoryUsecase(ref.watch(newsRepositoryProvider));
});

final searchNewsUseCaseProvider = Provider<SearchNewsUseCase>((ref) {
  return SearchNewsUseCase(ref.watch(newsRepositoryProvider));
});


import 'package:dio/dio.dart';
import '../models/news_model.dart';
import '../../../../core/error/exceptions.dart';

class NewsRemoteResponse {
  final List<NewsModel> results;
  final String? nextPage;

  NewsRemoteResponse({required this.results, this.nextPage});
}

abstract class NewsRemoteDataSource {
  Future<NewsRemoteResponse> fetchNews(String category, String? nextPage);
  Future<NewsRemoteResponse> searchNews(
    String query,
    String? nextPage,
    String category,
  );
}

class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  final Dio dio;

  NewsRemoteDataSourceImpl(this.dio);

  static const apiKey = "pub_a2ef077a8ddf497287e6e7aa3fb864a4";

  @override
  Future<NewsRemoteResponse> fetchNews(
    String category,
    String? nextPage,
  ) async {
    try {
      final res = await dio.get(
        'https://newsdata.io/api/1/news',
        queryParameters: {
          'apikey': apiKey,
          'category': category,
          if (nextPage != null) 'page': nextPage,
        },
      );

      final results = (res.data['results'] as List? ?? [])
          .map((e) => NewsModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();

      return NewsRemoteResponse(
        results: results,
        nextPage: res.data['nextPage'] as String?,
      );
    } catch (_) {
      throw ServerException();
    }
  }

  @override
  Future<NewsRemoteResponse> searchNews(
    String query,
    String? nextPage,
    String category,
  ) async {
    try {
      final res = await dio.get(
        'https://newsdata.io/api/1/news',
        queryParameters: {
          'apikey': apiKey,
          'q': query,
          'category': category,
          if (nextPage != null) 'page': nextPage,
        },
      );

      final results = (res.data['results'] as List? ?? [])
          .map((e) => NewsModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();

      return NewsRemoteResponse(
        results: results,
        nextPage: res.data['nextPage'] as String?,
      );
    } catch (_) {
      throw ServerException();
    }
  }
}

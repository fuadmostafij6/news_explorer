import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

  String get apiKey {
    final key = dotenv.env['NEWS_API_KEY'] ?? '';
    if (key.isEmpty) {
      throw Exception('NEWS_API_KEY is not set in .env file');
    }
    return key;
  }

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

      // Check if API returned an error in the response
      if (res.data is Map &&
          res.data.containsKey('status') &&
          res.data['status'] != 'success') {
        final errorMsg = res.data['message'] ?? 'API returned an error';
        debugPrint('API Error in fetchNews: $errorMsg');
        throw ServerException();
      }

      final results = (res.data['results'] as List? ?? [])
          .map((e) => NewsModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();

      return NewsRemoteResponse(
        results: results,
        nextPage: res.data['nextPage'] as String?,
      );
    } on DioException catch (e) {
      debugPrint('DioException in fetchNews: ${e.type} - ${e.message}');
      debugPrint('Status Code: ${e.response?.statusCode}');
      debugPrint('Response: ${e.response?.data}');
      throw ServerException();
    } catch (e, s) {
      if (e is! ServerException) {
        debugPrint('Unexpected error in fetchNews: $e');
        debugPrintStack(stackTrace: s);
      }
      rethrow;
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
          'qInTitle': query,
          'category': category,
          if (nextPage != null) 'page': nextPage,
        },
      );

      // Check if API returned an error in the response
      if (res.data is Map &&
          res.data.containsKey('status') &&
          res.data['status'] != 'success') {
        final errorMsg = res.data['message'] ?? 'API returned an error';
        debugPrint('API Error in searchNews: $errorMsg');
        throw ServerException();
      }

      final results = (res.data['results'] as List? ?? [])
          .map((e) => NewsModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();

      return NewsRemoteResponse(
        results: results,
        nextPage: res.data['nextPage'] as String?,
      );
    } on DioException catch (e) {
      debugPrint('DioException in searchNews: ${e.type} - ${e.message}');
      debugPrint('Status Code: ${e.response?.statusCode}');
      debugPrint('Response: ${e.response?.data}');
      throw ServerException();
    } catch (e, s) {
      if (e is! ServerException) {
        debugPrint('Unexpected error in searchNews: $e');
        debugPrintStack(stackTrace: s);
      }
      rethrow;
    }
  }
}

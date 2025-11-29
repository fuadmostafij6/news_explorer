import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/core/di/app_providers.dart';
import 'package:news_app/core/error/exceptions.dart';
import 'package:news_app/features/news/domain/entities/news_entity.dart';
import 'package:news_app/features/news/domain/repository/news_repository.dart';
import 'package:news_app/features/news/domain/usecases/get_news_by_category.dart';
import 'package:news_app/features/news/domain/usecases/search_news.dart';

const _defaultCategory = 'business';
const _nextPageSentinel = Object();
const _searchNextPageSentinel = Object();

class NewsState {
  const NewsState({
    required this.articles,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMore,
    required this.category,
    required this.query,
    required this.searchResults,
    required this.isSearchLoading,
    required this.isSearchLoadingMore,
    required this.hasMoreSearch,
    this.nextPage,
    this.searchNextPage,
    this.error,
    this.searchError,
    this.isOffline = false,
    this.lastUpdated,
  });

  factory NewsState.initial() {
    return const NewsState(
      articles: [],
      isLoading: false,
      isLoadingMore: false,
      hasMore: true,
      category: _defaultCategory,
      query: '',
      nextPage: null,
      error: null,
      isOffline: false,
      lastUpdated: null,
      searchResults: [],
      isSearchLoading: false,
      isSearchLoadingMore: false,
      hasMoreSearch: true,
      searchNextPage: null,
      searchError: null,
    );
  }

  final List<NewsEntity> articles;
  final List<NewsEntity> searchResults;
  final bool isLoading;
  final bool isSearchLoading;
  final bool isLoadingMore;
  final bool isSearchLoadingMore;
  final bool hasMore;
  final bool hasMoreSearch;
  final String category;
  final String query;
  final String? nextPage;
  final String? searchNextPage;
  final String? error;
  final String? searchError;
  final bool isOffline;
  final DateTime? lastUpdated;

  bool get isSearching => query.isNotEmpty;

  NewsState copyWith({
    List<NewsEntity>? articles,
    List<NewsEntity>? searchResults,
    bool? isLoading,
    bool? isSearchLoading,
    bool? isLoadingMore,
    bool? isSearchLoadingMore,
    bool? hasMore,
    bool? hasMoreSearch,
    String? category,
    String? query,
    Object? nextPage = _nextPageSentinel,
    Object? searchNextPage = _searchNextPageSentinel,
    String? error,
    String? searchError,
    bool? isOffline,
    DateTime? lastUpdated,
    bool clearError = false,
    bool clearSearchError = false,
  }) {
    return NewsState(
      articles: articles ?? this.articles,
      searchResults: searchResults ?? this.searchResults,
      isLoading: isLoading ?? this.isLoading,
      isSearchLoading: isSearchLoading ?? this.isSearchLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSearchLoadingMore: isSearchLoadingMore ?? this.isSearchLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      hasMoreSearch: hasMoreSearch ?? this.hasMoreSearch,
      category: category ?? this.category,
      query: query ?? this.query,
      nextPage: nextPage == _nextPageSentinel
          ? this.nextPage
          : nextPage as String?,
      searchNextPage: searchNextPage == _searchNextPageSentinel
          ? this.searchNextPage
          : searchNextPage as String?,
      error: clearError ? null : (error ?? this.error),
      searchError:
          clearSearchError ? null : (searchError ?? this.searchError),
      isOffline: isOffline ?? this.isOffline,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class NewsNotifier extends Notifier<NewsState> {
  NewsNotifier();

  Timer? _searchDebounce;
  bool _hasRequestedFirstLoad = false;
  static const _offlinePageSize = 10;
  List<NewsEntity> _offlineCache = [];
  int _offlineCursor = 0;

  GetNewsByCategoryUsecase get _getNews =>
      ref.read(getNewsByCategoryUseCaseProvider);
  SearchNewsUseCase get _searchNews => ref.read(searchNewsUseCaseProvider);
  NewsRepository get _repository => ref.read(newsRepositoryProvider);
  Connectivity get _connectivity => ref.read(connectivityProvider);

  @override
  NewsState build() {
    if (!_hasRequestedFirstLoad) {
      _hasRequestedFirstLoad = true;
      _registerDispose();
      Future.microtask(loadInitial);
    }
    return NewsState.initial();
  }

  Future<void> loadInitial() async {
    if (state.isSearching) {
      if (state.isSearchLoading) return;
      state = state.copyWith(
        isSearchLoading: true,
        hasMoreSearch: true,
        searchNextPage: null,
        searchResults: [],
        clearSearchError: true,
      );
    } else {
      if (state.isLoading) return;
      state = state.copyWith(
        isLoading: true,
        hasMore: true,
        nextPage: null,
        clearError: true,
      );
    }
    await _fetchPage(null, replace: true);
  }

  Future<void> refresh() async {
    await loadInitial();
  }

  Future<void> loadMore() async {
    if (state.isSearching) {
      if (!state.hasMoreSearch ||
          state.isSearchLoadingMore ||
          state.isSearchLoading) {
        return;
      }
      state = state.copyWith(isSearchLoadingMore: true, clearSearchError: true);
      await _fetchPage(state.searchNextPage, replace: false);
      return;
    }

    if (!state.hasMore || state.isLoadingMore || state.isLoading) return;
    if (state.isOffline) {
      state = state.copyWith(isLoadingMore: true);
      await _serveOfflinePage(replace: false);
      return;
    }
    state = state.copyWith(isLoadingMore: true, clearError: true);
    await _fetchPage(state.nextPage, replace: false);
  }

  void onQueryChanged(String query) {
    final trimmed = query.trim();
    _searchDebounce?.cancel();
    
    // Update query immediately for UI feedback
    if (trimmed != state.query) {
      state = state.copyWith(
        query: trimmed,
        searchResults: [],
        searchNextPage: null,
        clearSearchError: true,
      );
    }
    
    // Debounce the actual API call
    if (trimmed.isEmpty) {
      clearSearch();
    } else {
      _searchDebounce = Timer(const Duration(milliseconds: 500), () {
        if (trimmed == state.query && trimmed.isNotEmpty) {
          loadInitial();
        }
      });
    }
  }

  void clearSearch() {
    if (state.query.isEmpty) return;
    _searchDebounce?.cancel();
    state = state.copyWith(
      query: '',
      searchResults: [],
      searchNextPage: null,
      hasMoreSearch: true,
      isSearchLoading: false,
      isSearchLoadingMore: false,
      clearSearchError: true,
    );
    loadInitial();
  }

  Future<void> _fetchPage(String? page, {required bool replace}) async {
    final isOnline = await _isOnline();
    state = state.copyWith(isOffline: !isOnline);

    if (!isOnline && !state.isSearching) {
      await _serveOfflinePage(replace: replace);
      return;
    }

    try {
      final isSearchMode = state.isSearching;
      final response = isSearchMode
          ? await _searchNews(
              SearchNewsParams(
                query: state.query,
                nextPage: page,
                category: state.category,
              ),
            )
          : await _getNews(
              GetNewsByCategoryParams(
                category: state.category,
                nextPage: page,
                pageId: page ?? 'page_0',
                resetCache: replace,
              ),
            );

      final articles = response.$1;
      final next = response.$2;
      _offlineCache = [];
      _offlineCursor = 0;

      if (isSearchMode) {
        state = state.copyWith(
          searchResults:
              replace ? articles : [...state.searchResults, ...articles],
          searchNextPage: next,
          hasMoreSearch: next != null && articles.isNotEmpty,
          isSearchLoading: false,
          isSearchLoadingMore: false,
          clearSearchError: true,
          isOffline: !isOnline,
        );
      } else {
        state = state.copyWith(
          articles: replace ? articles : [...state.articles, ...articles],
          nextPage: next,
          hasMore: next != null && articles.isNotEmpty,
          isLoading: false,
          isLoadingMore: false,
          clearError: true,
          lastUpdated: DateTime.now(),
          isOffline: !isOnline,
        );
      }
    } on ServerException {
      // Server exception - try cache as fallback (both online and offline)
      try {
        if (state.isSearching) {
          final cached = await _repository.getCachedNews();
          final filtered = cached
              .where(
                (e) =>
                    (e.title ?? '').toLowerCase().contains(state.query.toLowerCase()),
              )
              .toList();
          if (filtered.isNotEmpty) {
            state = state.copyWith(
              searchResults: replace ? filtered : [...state.searchResults, ...filtered],
              isSearchLoading: false,
              isSearchLoadingMore: false,
              hasMoreSearch: false,
              searchNextPage: null,
              isOffline: !isOnline,
              clearSearchError: true,
            );
            return;
          }
        } else {
          // Try to serve cached news
          await _serveOfflinePage(replace: replace);
          return;
        }
      } catch (_) {
        // Cache also failed, show error
      }
      
      // If we reach here, cache is not available or empty
      if (state.isSearching) {
        state = state.copyWith(
          isSearchLoading: false,
          isSearchLoadingMore: false,
          searchError: isOnline
              ? 'Unable to search. Showing cached results if available.'
              : 'No cached search results available.',
          isOffline: !isOnline,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          error: isOnline
              ? 'Unable to load news. Please check your connection and try again.'
              : 'No cached news available.',
          isOffline: !isOnline,
        );
      }
    } on CacheException {
      if (state.isSearching) {
        state = state.copyWith(
          isSearchLoading: false,
          isSearchLoadingMore: false,
          searchError: 'No cached search results available.',
          isOffline: true,
        );
      } else {
        await _serveOfflinePage(replace: replace);
      }
    } catch (e) {
      if (state.isSearching) {
        state = state.copyWith(
          isSearchLoading: false,
          isSearchLoadingMore: false,
          searchError: 'Unable to search. Please try again.',
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          error: 'Unable to load news. Please try again.',
        );
      }
    }
  }

  Future<void> _serveOfflinePage({required bool replace}) async {
    try {
      if (_offlineCache.isEmpty || replace) {
        final cachedPages = await _repository.getCachedNewsPages();
        _offlineCache = [for (final page in cachedPages) ...page.$2];
        _offlineCursor = 0;
      }

      if (_offlineCache.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          error: 'No cached news available.',
          isOffline: true,
          hasMore: false,
        );
        return;
      }

      final slice = _offlineCache
          .skip(_offlineCursor)
          .take(_offlinePageSize)
          .toList();

      if (slice.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          hasMore: false,
          nextPage: null,
          isOffline: true,
        );
        return;
      }

      _offlineCursor += slice.length;
      final hasMore = _offlineCursor < _offlineCache.length;
      final pageNumber = (_offlineCursor / _offlinePageSize).ceil();
      final nextOfflineToken = hasMore ? 'offline_page_$pageNumber' : null;

      state = state.copyWith(
        articles: replace ? slice : [...state.articles, ...slice],
        isLoading: false,
        isLoadingMore: false,
        hasMore: hasMore,
        nextPage: nextOfflineToken,
        error: null,
        isOffline: true,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: 'No cached news available.',
        isOffline: true,
      );
    }
  }

  Future<bool> _isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return result.contains(ConnectivityResult.wifi) ||
        result.contains(ConnectivityResult.mobile);
  }

  void _registerDispose() {
    ref.onDispose(() {
      _searchDebounce?.cancel();
    });
  }
}

final newsNotifierProvider = NotifierProvider<NewsNotifier, NewsState>(
  NewsNotifier.new,
);

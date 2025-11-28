import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/core/route/app_route.dart';
import 'package:news_app/core/utils/color.dart';
import 'package:news_app/features/news/presentation/pages/widgets/news_item.dart';
import 'package:news_app/features/news/presentation/providers/news_provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  late final ScrollController _scrollController;
  late final TextEditingController _textController;
  bool _isSyncingText = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    final initialQuery = ref.read(newsNotifierProvider).query;
    _textController = TextEditingController(text: initialQuery);
    if (initialQuery.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(newsNotifierProvider.notifier).loadInitial();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.extentAfter < 320) {
      ref.read(newsNotifierProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      ref.read(newsNotifierProvider.notifier).clearSearch();
    } else {
      ref.read(newsNotifierProvider.notifier).onQueryChanged(trimmed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(newsNotifierProvider);

    if (_textController.text != state.query) {
      _isSyncingText = true;
      _textController.value = TextEditingValue(
        text: state.query,
        selection: TextSelection.collapsed(offset: state.query.length),
      );
      _isSyncingText = false;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.scaffoldBgColor,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: PhosphorIcon(
            PhosphorIcons.arrowLeft(),
            color: AppColor.textColor,
          ),
        ),
        title: TextField(
          controller: _textController,
          autofocus: true,
          onChanged: (value) {
            if (_isSyncingText) return;
            _onSearchChanged(value);
          },
          style: TextStyle(color: AppColor.textColor),
          decoration: InputDecoration(
            hintText: 'Search headlines',
            hintStyle: TextStyle(color: AppColor.textDimColor),
            border: InputBorder.none,
            suffixIcon: _textController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _textController.clear();
                      _onSearchChanged('');
                    },
                    icon: PhosphorIcon(
                      PhosphorIcons.x(),
                      color: AppColor.textColor,
                    ),
                  )
                : null,
          ),
        ),
      ),
      body: Column(
        children: [
          if (state.isSearchLoading && state.searchResults.isEmpty)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (state.searchError != null &&
              state.searchResults.isEmpty &&
              state.query.isNotEmpty)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(state.searchError!),
                ),
              ),
            )
          else if (state.searchResults.isEmpty && state.query.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  'Type a keyword to search articles.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            )
          else if (state.searchResults.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  'No articles found for "${state.query}".',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            )
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: () =>
                    ref.read(newsNotifierProvider.notifier).loadInitial(),
                child: ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: state.searchResults.length +
                      (state.isSearchLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= state.searchResults.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final article = state.searchResults[index];
                    return NewsItem(
                      article: article,
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed(AppRoute.detail, arguments: article);
                      },
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}


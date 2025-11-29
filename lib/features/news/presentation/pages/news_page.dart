import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_app/core/route/app_route.dart';
import 'package:news_app/core/utils/assets.dart';
import 'package:news_app/core/utils/color.dart';
import 'package:news_app/features/news/presentation/pages/widgets/news_item.dart';
import 'package:news_app/features/news/presentation/providers/news_provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class NewsPage extends ConsumerStatefulWidget {
  const NewsPage({super.key});

  @override
  ConsumerState<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends ConsumerState<NewsPage> with WidgetsBindingObserver {
  late final ScrollController _scrollController;
  bool _wasSearching = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    WidgetsBinding.instance.addObserver(this);
    _wasSearching = ref.read(newsNotifierProvider).isSearching;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAndRefresh();
    }
  }

  void _checkAndRefresh() {
    final currentState = ref.read(newsNotifierProvider);
    // If we were searching but now we're not, refresh the news feed
    if (_wasSearching && !currentState.isSearching) {
      _wasSearching = false;
      ref.read(newsNotifierProvider.notifier).refresh();
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.extentAfter < 320) {
      ref.read(newsNotifierProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(newsNotifierProvider);
    
    // Check if we just came back from search
    if (_wasSearching && !state.isSearching) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _wasSearching = false;
        ref.read(newsNotifierProvider.notifier).refresh();
      });
    } else if (state.isSearching) {
      _wasSearching = true;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.scaffoldBgColor,
        leadingWidth: 90,
        leading: Hero(
          tag: "logo",
          child: Material(
            color: Colors.transparent,
            child: Image.asset(
              AppAssets.logo,
              height: 200,
              width: 200,
              fit: BoxFit.contain,
            ),
          ),
        ),
        centerTitle: true,
        title: Hero(
          tag: "title",
          child: Material(
            color: Colors.transparent,
            child: Text(
              "News Explorer",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoute.search);
            },
            icon: PhosphorIcon(
              PhosphorIcons.magnifyingGlass(),
              color: AppColor.textColor,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            if (state.isOffline)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: Colors.orange.withValues(alpha: 0.2),
                child: Text(
                  state.articles.isEmpty
                      ? 'You are offline.'
                      : 'You are offline. Showing cached news.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () =>
                    ref.read(newsNotifierProvider.notifier).refresh(),
                child: _buildBody(state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(NewsState state) {
    if (state.isLoading && state.articles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.articles.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 300, child: Center(child: Text(state.error!))),
        ],
      );
    }

    if (state.articles.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 300, child: Center(child: Text('No news found.'))),
        ],
      );
    }

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: state.articles.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.articles.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final article = state.articles[index];
        return NewsItem(
          article: article,
          onTap: () {
            Navigator.of(
              context,
            ).pushNamed(AppRoute.detail, arguments: article);
          },
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
    );
  }
}

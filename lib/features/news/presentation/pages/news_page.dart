import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
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

class _NewsPageState extends ConsumerState<NewsPage> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.scaffoldBgColor,
        leadingWidth: 90,
        leading: Hero(
          tag: "logo",
          child: Material(
            color: Colors.transparent,
            child: Lottie.asset(
              AppAssets.logo,
              height: 200,
              width: 200,
              fit: BoxFit.contain,
              repeat: true,
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

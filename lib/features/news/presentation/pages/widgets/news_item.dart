import 'package:cached_network_image/cached_network_image.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:news_app/core/utils/color.dart';
import 'package:news_app/features/news/domain/entities/news_entity.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class NewsItem extends StatelessWidget {
  const NewsItem({super.key, required this.article, this.onTap});

  final NewsEntity article;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final imageUrl = article.imageUrl;
    final published = _formatDate(article.pubDate);

    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.all(Radius.circular(18)),
      child: Container(
        width: double.infinity,
        height: 100,
        decoration: ShapeDecoration(
          color: AppColor.scaffoldDimBgColor.withValues(alpha: 0.9),
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 18,
              cornerSmoothing: 0.9,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title ?? 'Untitled article',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Row(
                      children: [
                        if ((article.source ?? '').isNotEmpty)
                          Flexible(
                            child: Text(
                              article.source!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ),
                        if (published != null) ...[
                          if ((article.source ?? '').isNotEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Text('•'),
                            ),
                          Text(
                            published,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Hero(
                tag: _imageHeroTag(article.articleId),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _placeholderImage(),
                          errorWidget: (_, __, ___) => _placeholderImage(),
                        )
                      : _placeholderImage(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      color: Colors.black26,
      alignment: Alignment.center,
      child: PhosphorIcon(
        PhosphorIcons.imageBroken(),
        color: AppColor.textDimColor,
        size: 26,
      ),
    );
  }

  String? _formatDate(String? value) {
    if (value == null || value.isEmpty) return null;
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    return '${parsed.day.toString().padLeft(2, '0')} '
        '${_monthName(parsed.month)} ${parsed.year}';
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  static String _imageHeroTag(String id) => 'news_image_$id';
}

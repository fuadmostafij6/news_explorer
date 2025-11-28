import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:news_app/core/utils/color.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/entities/news_entity.dart';

class NewsDetailPage extends StatelessWidget {
  const NewsDetailPage({super.key, required this.article});

  final NewsEntity article;

  @override
  Widget build(BuildContext context) {
    final published = _formatDate(article.pubDate);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.scaffoldBgColor,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: PhosphorIcon(
            PhosphorIcons.arrowLeft(),
            color: AppColor.textColor,
          ),
        ),
        title: Text(
          article.source ?? 'Article',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        actions: [],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
             if ((article.imageUrl ?? '').isNotEmpty)
               Hero(
                 tag: 'news_image_${article.articleId}',
                 child: ClipRRect(
                   borderRadius: BorderRadius.circular(12),
                   child: CachedNetworkImage(
                     imageUrl: article.imageUrl!,
                     fit: BoxFit.cover,
                     height: 220,
                     placeholder: (_, __) => _placeholderImage(),
                     errorWidget: (_, __, ___) => _placeholderImage(),
                   ),
                 ),
               ),
            const SizedBox(height: 16),
            Text(
              article.title ?? 'Untitled Article',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (published != null)
                  Text(published, style: Theme.of(context).textTheme.bodySmall)
                else
                  Spacer(),

                IconButton(
                  icon: PhosphorIcon(
                    PhosphorIcons.share(),
                    size: 22,
                    color: AppColor.textColor,
                  ),
                  onPressed: () {
                    final shareContent = article.link ?? article.title ?? '';
                    if (shareContent.isNotEmpty) {
                      SharePlus.instance.share(ShareParams(text: shareContent));
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 8),
            Text(
              article.description ??
                  article.content ??
                  'No additional information is available for this article.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  String? _formatDate(String? value) {
    if (value == null || value.isEmpty) return null;
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    return '${parsed.day.toString().padLeft(2, '0')} '
        '${_monthName(parsed.month)} ${parsed.year} • '
        '${parsed.hour.toString().padLeft(2, '0')}:'
        '${parsed.minute.toString().padLeft(2, '0')}';
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
}

Widget _placeholderImage() {
  return Container(
    height: 220,
    color: AppColor.scaffoldDimBgColor,
    alignment: Alignment.center,
    child: PhosphorIcon(
      PhosphorIcons.imageBroken(),
      color: AppColor.textDimColor,
      size: 26,
    ),
  );
}

class NewsEntity {
  final String articleId;
  final String? title;
  final String? description;
  final String? content;
  final String? link;
  final String? imageUrl;
  final String? pubDate;
  final List<String>? keywords;
  final List<String>? creator;
  final List<String>? country;
  final List<String>? category;
  final String? source;

  NewsEntity({
    required this.articleId,
    this.title,
    this.description,
    this.content,
    this.link,
    this.imageUrl,
    this.pubDate,
    this.keywords,
    this.creator,
    this.country,
    this.category,
    this.source,
  });
}

import '../../domain/entities/news_entity.dart';

class NewsModel extends NewsEntity {
  NewsModel({
    required super.articleId,
    super.title,
    super.description,
    super.content,
    super.link,
    super.imageUrl,
    super.pubDate,
    super.keywords,
    super.creator,
    super.country,
    super.category,
    super.source,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      articleId: json['article_id'] ?? "",
      title: json['title'],
      description: json['description'],
      content: json['content'],
      link: json['link'],
      imageUrl: json['image_url'],
      pubDate: json['pubDate'],
      keywords: (json['keywords'] as List?)?.map((e) => e.toString()).toList(),
      creator: (json['creator'] as List?)?.map((e) => e.toString()).toList(),
      country: (json['country'] as List?)?.map((e) => e.toString()).toList(),
      category: (json['category'] as List?)?.map((e) => e.toString()).toList(),
      source: json['source_id'] ?? json['source'],
    );
  }

  Map<String, dynamic> toJson() => {
    "article_id": articleId,
    "title": title,
    "description": description,
    "content": content,
    "link": link,
    "image_url": imageUrl,
    "pubDate": pubDate,
    "keywords": keywords,
    "creator": creator,
    "country": country,
    "category": category,
    "source": source,
  };

  factory NewsModel.fromEntity(NewsEntity entity) {
    return NewsModel(
      articleId: entity.articleId,
      title: entity.title,
      description: entity.description,
      content: entity.content,
      link: entity.link,
      imageUrl: entity.imageUrl,
      pubDate: entity.pubDate,
      keywords: entity.keywords,
      creator: entity.creator,
      country: entity.country,
      category: entity.category,
      source: entity.source,
    );
  }
}

class NewsItem {
  final String title;
  final String category;
  final String date;
  final String imageUrl;
  final String link;
  final bool isVideo;
  final String? videoUrl;

  const NewsItem({
    required this.title,
    required this.category,
    required this.date,
    required this.imageUrl,
    required this.link,
    this.isVideo = false,
    this.videoUrl,
  });
}

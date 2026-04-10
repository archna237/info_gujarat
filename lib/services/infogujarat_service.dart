import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/news_category.dart';
import '../models/news_item.dart';

class InfoGujaratService {
  static const String _apiBase = 'https://infogujarat.com/api';
  static const String _fallbackImage = 'https://picsum.photos/seed/gujarat-fallback/400/200';

  Future<Map<String, dynamic>> _fetchCommonData() async {
    final commonResponse = await http
        .get(Uri.parse('$_apiBase/common/1'))
        .timeout(const Duration(seconds: 20));
    if (commonResponse.statusCode != 200) {
      throw Exception('Unable to load InfoGujarat API.');
    }
    final commonJson = jsonDecode(commonResponse.body) as Map<String, dynamic>;
    return (commonJson['data'] ?? {}) as Map<String, dynamic>;
  }

  Future<List<NewsCategory>> fetchCategories() async {
    final commonData = await _fetchCommonData();
    final categoriesRaw = (commonData['Category'] as List<dynamic>? ?? const []);
    final categories = <NewsCategory>[];

    for (final raw in categoriesRaw) {
      final map = raw as Map<String, dynamic>;
      final id = map['id'] as int?;
      final name = _clean('${map['name'] ?? ''}');
      if (id == null || name.isEmpty) continue;
      categories.add(NewsCategory(id: id, name: name));
    }

    if (categories.isEmpty) {
      categories.add(const NewsCategory(id: 1, name: 'સમાચાર'));
    }
    return categories;
  }

  Future<List<NewsItem>> fetchHomepageNews() {
    return fetchNewsByCategory(1, includeTopVideos: true);
  }

  Future<List<NewsItem>> fetchNewsByCategory(
    int categoryId, {
    bool includeTopVideos = false,
  }) async {
    final items = <NewsItem>[];
    final seen = <String>{};

    Map<String, dynamic>? commonData;
    if (includeTopVideos) {
      commonData = await _fetchCommonData();
    }

    if (includeTopVideos && commonData != null) {
      final videos = (commonData['Video'] as List<dynamic>? ?? const []);
      for (final raw in videos.take(8)) {
        final videoMap = raw as Map<String, dynamic>;
        final rawVideo = _clean('${videoMap['video'] ?? ''}');
        if (rawVideo.isEmpty) continue;
        final videoId = _extractYouTubeId(rawVideo);
        if (videoId == null || videoId.isEmpty) continue;

        final title = _clean('${videoMap['name'] ?? ''}').isEmpty
            ? 'Video Update'
            : _clean('${videoMap['name'] ?? ''}');
        final key = 'video_${title.toLowerCase()}_$videoId';
        if (seen.contains(key)) continue;
        seen.add(key);

        items.add(
          NewsItem(
            title: title,
            category: 'Video',
            date: 'Latest',
            imageUrl: _resolveImage(_youtubeThumb(videoId)),
            link: _youtubeWatch(videoId),
            isVideo: true,
            videoUrl: _youtubeWatch(videoId),
          ),
        );
      }
    }

    final newsResponse = await http
        .get(Uri.parse('$_apiBase/news/1/$categoryId'))
        .timeout(const Duration(seconds: 20));
    if (newsResponse.statusCode == 200) {
      final newsJson = jsonDecode(newsResponse.body) as Map<String, dynamic>;
      final newsList = (newsJson['data'] as List<dynamic>? ?? const []);

      for (final raw in newsList) {
        final map = raw as Map<String, dynamic>;
        final title = _clean('${map['title'] ?? ''}');
        if (title.isEmpty) continue;

        final date = _clean('${map['create_date'] ?? ''}').isEmpty
            ? 'Latest'
            : _clean('${map['create_date'] ?? ''}');
        final category = _clean('${map['name'] ?? ''}').isEmpty
            ? 'News'
            : _clean('${map['name'] ?? ''}');

        final blogImages = (map['blog_image'] as List<dynamic>? ?? const []);
        final mediaToken = blogImages.isNotEmpty
            ? _clean('${(blogImages.first as Map<String, dynamic>)['details'] ?? ''}')
            : '';

        final videoId = _extractYouTubeId(mediaToken);
        final isVideo = videoId != null;
        final imageUrl = isVideo
            ? _youtubeThumb(videoId)
            : (blogImages.isNotEmpty
                ? _clean('${(blogImages.first as Map<String, dynamic>)['image_path'] ?? ''}')
                : '');

        final link = isVideo
            ? _youtubeWatch(videoId)
            : 'https://infogujarat.com/share?nid=${map['id']}';
        final uniqueKey = '${title.toLowerCase()}_$link';
        if (seen.contains(uniqueKey)) continue;
        seen.add(uniqueKey);

        items.add(
          NewsItem(
            title: title,
            category: isVideo ? 'Video' : category,
            date: date,
            imageUrl: _resolveImage(imageUrl),
            link: link,
            isVideo: isVideo,
            videoUrl: isVideo ? link : null,
          ),
        );
        if (items.length >= 30) break;
      }
    }

    if (items.isEmpty) {
      throw Exception('InfoGujarat API returned no usable items.');
    }
    return items;
  }

  String? _extractYouTubeId(String raw) {
    final value = _clean(raw);
    if (value.isEmpty) return null;
    if (value.startsWith('http://') || value.startsWith('https://')) {
      final uri = Uri.tryParse(value);
      if (uri == null) return null;
      final v = uri.queryParameters['v'];
      if (v != null && v.isNotEmpty) return v;
      if (uri.host.contains('youtu.be')) {
        final segments = uri.pathSegments;
        return segments.isNotEmpty ? segments.first : null;
      }
      return null;
    }

    final isYoutubeId = RegExp(r'^[A-Za-z0-9_-]{8,15}$').hasMatch(value);
    return isYoutubeId ? value : null;
  }

  String _youtubeThumb(String id) {
    return 'https://img.youtube.com/vi/$id/hqdefault.jpg';
  }

  String _youtubeWatch(String id) {
    return 'https://www.youtube.com/watch?v=$id';
  }

  String _resolveImage(String rawUrl) {
    final cleaned = _clean(rawUrl);
    if (cleaned.isEmpty) return _fallbackImage;
    return cleaned;
  }

  String _clean(String value) {
    return value.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}

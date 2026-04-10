import 'package:flutter/foundation.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

import '../models/news_item.dart';

class InfoGujaratService {
  static const String _baseUrl = 'https://infogujarat.com';
  static const String _jinaMirrorUrl = 'https://r.jina.ai/http://infogujarat.com/';
  static const String _fallbackImage = 'https://picsum.photos/seed/gujarat-fallback/400/200';

  Future<List<NewsItem>> fetchHomepageNews() async {
    try {
      final scraped = await _fetchFromHomepageHtml();
      if (scraped.isNotEmpty) return scraped;
    } catch (_) {
      // Ignore and continue to fallback sources below.
    }

    final fallback = await _fetchFromJinaMirror();
    if (fallback.isNotEmpty) return fallback;

    if (kIsWeb) {
      throw Exception(
        'Failed to fetch from InfoGujarat (likely CORS/network restriction on web).',
      );
    }
    throw Exception('Failed to fetch latest updates from InfoGujarat.');
  }

  Future<List<NewsItem>> _fetchFromHomepageHtml() async {
    final uri = Uri.parse(_baseUrl);
    final response = await http.get(
      uri,
      headers: const {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.9',
      },
    ).timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      return const <NewsItem>[];
    }

    final document = html_parser.parse(response.body);
    final collected = <NewsItem>[];
    final seenTitles = <String>{};

    final articleNodes = document.querySelectorAll(
      'article, .post, .jeg_post, .td_module_wrap, .news-item, .item-list',
    );

    for (final node in articleNodes) {
      final item = _mapNodeToNews(node);
      if (item == null) continue;

      final normalizedTitle = item.title.trim().toLowerCase();
      if (normalizedTitle.isEmpty || seenTitles.contains(normalizedTitle)) continue;

      seenTitles.add(normalizedTitle);
      collected.add(item);
      if (collected.length >= 25) break;
    }

    if (collected.isNotEmpty) return collected;

    final anchors = document.querySelectorAll('a[title], h1 a, h2 a, h3 a');
    for (final anchor in anchors) {
      final rawTitle = anchor.attributes['title'] ?? anchor.text;
      final title = _clean(rawTitle);
      if (title.isEmpty) continue;

      final normalizedTitle = title.toLowerCase();
      if (seenTitles.contains(normalizedTitle)) continue;

      seenTitles.add(normalizedTitle);
      collected.add(
        NewsItem(
          title: title,
          category: 'News',
          date: 'Latest',
          imageUrl: _fallbackImage,
          link: _resolveUrl(anchor.attributes['href'] ?? ''),
        ),
      );
      if (collected.length >= 25) break;
    }

    return collected;
  }

  Future<List<NewsItem>> _fetchFromJinaMirror() async {
    final response = await http.get(Uri.parse(_jinaMirrorUrl)).timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      return const <NewsItem>[];
    }

    final lines = response.body
        .split('\n')
        .map((line) => _clean(line))
        .where((line) => line.isNotEmpty)
        .toList();

    final items = <NewsItem>[];
    final seen = <String>{};

    final imageRegex = RegExp(r'!\[[^\]]*\]\((https?://[^)]+)\)');
    final timeRegex = RegExp(r'(\d+\s*(minute|min|hour|hr|day|week|month)s?\s+ago)', caseSensitive: false);
    final numericOnlyRegex = RegExp(r'^\d+$');

    for (var i = 0; i < lines.length; i++) {
      final imageMatch = imageRegex.firstMatch(lines[i]);
      if (imageMatch == null) continue;

      final imageUrl = imageMatch.group(1) ?? _fallbackImage;

      String title = '';
      String date = 'Latest';

      for (var j = i + 1; j < lines.length && j <= i + 8; j++) {
        final candidate = lines[j];
        if (candidate.startsWith('![') ||
            candidate.startsWith('Title:') ||
            candidate.startsWith('URL Source:') ||
            candidate == 'Markdown Content:' ||
            candidate == 'Info Gujarat...' ||
            numericOnlyRegex.hasMatch(candidate)) {
          continue;
        }

        final timeMatch = timeRegex.firstMatch(candidate);
        if (timeMatch != null) {
          date = timeMatch.group(1) ?? date;
          continue;
        }

        if (title.isEmpty && candidate.length > 10) {
          title = candidate;
        }
      }

      if (title.isEmpty) continue;
      final key = title.toLowerCase();
      if (seen.contains(key)) continue;
      seen.add(key);

      items.add(
        NewsItem(
          title: title,
          category: 'News',
          date: date,
          imageUrl: imageUrl,
          link: _baseUrl,
        ),
      );
      if (items.length >= 25) break;
    }

    return items;
  }

  NewsItem? _mapNodeToNews(dynamic node) {
    final titleAnchor = node.querySelector('h1 a, h2 a, h3 a, h4 a, a[title]');
    final title = _clean(titleAnchor?.attributes['title'] ?? titleAnchor?.text ?? '');
    if (title.isEmpty) return null;

    final categoryText = _clean(
      node.querySelector('.cat-links a, .jeg_post_category a, .meta-category a, .td-post-category')
              ?.text ??
          '',
    );
    final dateText = _extractDate(node);

    final imageNode = node.querySelector('img');
    final imageUrl = _resolveImage(
      imageNode?.attributes['data-src'] ??
          imageNode?.attributes['data-lazy-src'] ??
          imageNode?.attributes['src'] ??
          '',
    );

    final link = _resolveUrl(titleAnchor?.attributes['href'] ?? '');

    return NewsItem(
      title: title,
      category: categoryText.isEmpty ? 'News' : categoryText,
      date: dateText,
      imageUrl: imageUrl,
      link: link,
    );
  }

  String _extractDate(dynamic node) {
    final timeNode = node.querySelector('time');
    final dateValue = _clean(
      timeNode?.attributes['datetime'] ?? timeNode?.text ?? '',
    );
    if (dateValue.isEmpty) return 'Latest';

    final parsed = DateTime.tryParse(dateValue);
    if (parsed == null) return dateValue;

    final diff = DateTime.now().difference(parsed.toLocal());
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${diff.inDays} day ago';
  }

  String _resolveImage(String rawUrl) {
    final cleaned = _clean(rawUrl);
    if (cleaned.isEmpty) return _fallbackImage;
    return _resolveUrl(cleaned);
  }

  String _resolveUrl(String rawUrl) {
    final cleaned = _clean(rawUrl);
    if (cleaned.isEmpty) return _baseUrl;
    if (cleaned.startsWith('http://') || cleaned.startsWith('https://')) {
      return cleaned;
    }
    if (cleaned.startsWith('//')) {
      return 'https:$cleaned';
    }
    if (cleaned.startsWith('/')) {
      return '$_baseUrl$cleaned';
    }
    return '$_baseUrl/$cleaned';
  }

  String _clean(String value) {
    return value.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}

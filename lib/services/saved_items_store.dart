import 'package:flutter/foundation.dart';

import '../models/news_item.dart';

class SavedItemsStore {
  SavedItemsStore._();

  static final SavedItemsStore instance = SavedItemsStore._();

  final ValueNotifier<List<NewsItem>> savedItems = ValueNotifier<List<NewsItem>>(<NewsItem>[]);

  bool isSaved(NewsItem item) {
    return savedItems.value.any((entry) => _same(entry, item));
  }

  void toggle(NewsItem item) {
    final current = List<NewsItem>.from(savedItems.value);
    final index = current.indexWhere((entry) => _same(entry, item));
    if (index >= 0) {
      current.removeAt(index);
    } else {
      current.insert(0, item);
    }
    savedItems.value = current;
  }

  bool _same(NewsItem a, NewsItem b) {
    return a.link == b.link && a.title == b.title;
  }
}

import 'package:flutter/material.dart';

import '../models/news_item.dart';
import '../widgets/article_card.dart';

class NewsSearchDelegate extends SearchDelegate<void> {
  final List<NewsItem> items;
  final void Function(NewsItem item) onItemTap;
  final bool Function(NewsItem item) isSaved;
  final void Function(NewsItem item) onBookmarkTap;

  NewsSearchDelegate({
    required this.items,
    required this.onItemTap,
    required this.isSaved,
    required this.onBookmarkTap,
  });

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildList();

  @override
  Widget buildSuggestions(BuildContext context) => _buildList();

  Widget _buildList() {
    final q = query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? items
        : items
            .where(
              (item) =>
                  item.title.toLowerCase().contains(q) ||
                  item.category.toLowerCase().contains(q),
            )
            .toList();

    if (filtered.isEmpty) {
      return const Center(child: Text('No matching results.'));
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        return ArticleCard(
          title: item.title,
          category: item.category,
          date: item.date,
          imageUrl: item.imageUrl,
          isVideo: item.isVideo,
          isSaved: isSaved(item),
          onTap: () => onItemTap(item),
          onBookmarkTap: () => onBookmarkTap(item),
        );
      },
    );
  }
}

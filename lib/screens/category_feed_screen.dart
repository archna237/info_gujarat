import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/constants.dart';
import '../models/news_category.dart';
import '../models/news_item.dart';
import '../services/infogujarat_service.dart';
import '../services/saved_items_store.dart';
import '../widgets/article_card.dart';

class CategoryFeedScreen extends StatefulWidget {
  final NewsCategory category;

  const CategoryFeedScreen({
    super.key,
    required this.category,
  });

  @override
  State<CategoryFeedScreen> createState() => _CategoryFeedScreenState();
}

class _CategoryFeedScreenState extends State<CategoryFeedScreen> {
  final InfoGujaratService _service = InfoGujaratService();
  final SavedItemsStore _savedStore = SavedItemsStore.instance;
  late Future<List<NewsItem>> _newsFuture;

  @override
  void initState() {
    super.initState();
    _newsFuture = _service.fetchNewsByCategory(widget.category.id);
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    bool launched = false;
    try {
      launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      launched = false;
    }
    if (!launched) {
      try {
        launched = await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
      } catch (_) {
        launched = false;
      }
    }
    if (!launched) {
      try {
        launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (_) {
        launched = false;
      }
    }
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open link')),
      );
    }
  }

  void _refresh() {
    setState(() {
      _newsFuture = _service.fetchNewsByCategory(widget.category.id);
    });
  }

  void _openAndSave(NewsItem item) {
    if (!_savedStore.isSaved(item)) {
      setState(() {
        _savedStore.toggle(item);
      });
    }
    _openUrl(item.videoUrl ?? item.link);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder<List<NewsItem>>(
        future: _newsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 44),
                    const SizedBox(height: AppConstants.paddingSmall),
                    Text('${snapshot.error}', textAlign: TextAlign.center),
                    const SizedBox(height: AppConstants.paddingSmall),
                    ElevatedButton(
                      onPressed: _refresh,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final items = snapshot.data ?? const <NewsItem>[];
          if (items.isEmpty) {
            return const Center(child: Text('No updates found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ArticleCard(
                title: item.title,
                category: item.category,
                date: item.date,
                imageUrl: item.imageUrl,
                isVideo: item.isVideo,
                isSaved: _savedStore.isSaved(item),
                onTap: () => _openAndSave(item),
                onBookmarkTap: () {
                  setState(() {
                    _savedStore.toggle(item);
                  });
                },
              );
            },
          );
        },
      ),
    );
  }
}

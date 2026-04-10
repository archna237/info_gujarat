import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/constants.dart';
import '../models/news_item.dart';
import '../services/saved_items_store.dart';
import '../widgets/article_card.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    var launched = false;
    try {
      launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      launched = false;
    }
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = SavedItemsStore.instance;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ValueListenableBuilder<List<NewsItem>>(
        valueListenable: store.savedItems,
        builder: (context, savedItems, _) {
          if (savedItems.isEmpty) {
            return const Center(
              child: Text('No saved items yet.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            itemCount: savedItems.length,
            itemBuilder: (context, index) {
              final item = savedItems[index];
              return ArticleCard(
                title: item.title,
                category: item.category,
                date: item.date,
                imageUrl: item.imageUrl,
                isVideo: item.isVideo,
                isSaved: true,
                onTap: () => _openUrl(context, item.videoUrl ?? item.link),
                onBookmarkTap: () => store.toggle(item),
              );
            },
          );
        },
      ),
    );
  }
}

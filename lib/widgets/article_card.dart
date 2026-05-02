import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/constants.dart';

class ArticleCard extends StatelessWidget {
  final String title;
  final String category;
  final String date;
  final String imageUrl;
  final bool isVideo;
  final VoidCallback? onTap;
  final bool isSaved;
  final VoidCallback? onBookmarkTap;

  const ArticleCard({
    super.key,
    required this.title,
    required this.category,
    required this.date,
    required this.imageUrl,
    this.isVideo = false,
    this.onTap,
    this.isSaved = false,
    this.onBookmarkTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingSmall),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: imageUrl,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 100,
                        width: 100,
                        color: Colors.grey.shade200,
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 100,
                        width: 100,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.image_not_supported, color: Colors.grey),
                      ),
                    ),
                    if (isVideo)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.25),
                          child: const Center(
                            child: Icon(Icons.play_circle_fill, color: Colors.white, size: 30),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              // Content
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Category & Bookmark
                      Row(
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                category.toUpperCase(),
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: onBookmarkTap,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints.tightFor(width: 24, height: 24),
                            visualDensity: VisualDensity.compact,
                            icon: Icon(
                              isSaved ? Icons.bookmark : Icons.bookmark_border,
                              size: 20,
                              color: isSaved
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                      // Title
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                        overflow: TextOverflow.visible,
                      ),
                      // Date
                      Text(
                        date,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

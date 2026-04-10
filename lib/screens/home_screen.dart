import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../models/news_item.dart';
import '../services/infogujarat_service.dart';
import '../widgets/article_card.dart';
import '../widgets/featured_carousel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final InfoGujaratService _service = InfoGujaratService();
  late Future<List<NewsItem>> _newsFuture;
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _newsFuture = _service.fetchHomepageNews();
  }

  void _refreshNews() {
    setState(() {
      _newsFuture = _service.fetchHomepageNews();
      _selectedCategory = 'All';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppConstants.appName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshNews,
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
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: AppConstants.paddingMedium),
                    Text(
                      'Could not load latest updates.',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    ElevatedButton(
                      onPressed: _refreshNews,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final allNews = snapshot.data ?? <NewsItem>[];
          if (allNews.isEmpty) {
            return Center(
              child: ElevatedButton(
                onPressed: _refreshNews,
                child: const Text('Reload News'),
              ),
            );
          }

          final categories = <String>[
            'All',
            ...allNews
                .map((item) => item.category)
                .where((category) => category.trim().isNotEmpty)
                .toSet(),
          ];

          if (!categories.contains(_selectedCategory)) {
            _selectedCategory = 'All';
          }

          final filteredNews = _selectedCategory == 'All'
              ? allNews
              : allNews.where((item) => item.category == _selectedCategory).toList();

          final carouselItems = allNews.take(5).map((item) {
            return {
              'title': item.title,
              'category': item.category,
              'date': item.date,
              'imageUrl': item.imageUrl,
            };
          }).toList();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppConstants.paddingMedium),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Breaking News',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      TextButton(
                        onPressed: _refreshNews,
                        child: const Text('Refresh'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                FeaturedCarousel(items: carouselItems),
                const SizedBox(height: AppConstants.paddingLarge),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: AppConstants.paddingSmall),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final selected = category == _selectedCategory;
                      return ChoiceChip(
                        label: Text(category),
                        selected: selected,
                        onSelected: (_) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppConstants.paddingLarge),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
                  child: Text(
                    'Recent Updates',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: filteredNews.length,
                  itemBuilder: (context, index) {
                    final item = filteredNews[index];
                    return ArticleCard(
                      title: item.title,
                      category: item.category,
                      date: item.date,
                      imageUrl: item.imageUrl,
                    );
                  },
                ),
                const SizedBox(height: AppConstants.paddingLarge),
              ],
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/constants.dart';
import '../models/news_category.dart';
import '../models/news_item.dart';
import '../services/saved_items_store.dart';
import '../services/infogujarat_service.dart';
import '../widgets/article_card.dart';
import '../widgets/featured_carousel.dart';
import 'news_search_delegate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final InfoGujaratService _service = InfoGujaratService();
  final SavedItemsStore _savedStore = SavedItemsStore.instance;
  late Future<List<NewsItem>> _newsFuture;
  List<NewsCategory> _categories = const [];
  List<NewsItem> _latestItems = const [];
  int? _selectedCategoryId;
  bool _isBootstrapping = true;
  String? _bootstrapError;

  @override
  void initState() {
    super.initState();
    _newsFuture = Future.value(const []);
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final categories = await _service.fetchCategories();
      final initialCategoryId = categories.first.id;
      setState(() {
        _categories = categories;
        _selectedCategoryId = initialCategoryId;
        _newsFuture = _service.fetchNewsByCategory(
          initialCategoryId,
          includeTopVideos: initialCategoryId == 1,
        );
        _isBootstrapping = false;
        _bootstrapError = null;
      });
    } catch (e) {
      setState(() {
        _bootstrapError = '$e';
        _isBootstrapping = false;
      });
    }
  }

  void _refreshNews() {
    if (_selectedCategoryId == null) return;
    setState(() {
      _newsFuture = _service.fetchNewsByCategory(
        _selectedCategoryId!,
        includeTopVideos: _selectedCategoryId == 1,
      );
    });
  }

  void _onCategorySelected(int id) {
    if (_selectedCategoryId == id) return;
    setState(() {
      _selectedCategoryId = id;
      _newsFuture = _service.fetchNewsByCategory(
        id,
        includeTopVideos: id == 1,
      );
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                'https://infogujarat.com/images/260319161833news_logo.png',
                height: 28,
                width: 28,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              AppConstants.appName,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No notifications right now.')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: NewsSearchDelegate(
                  items: _latestItems,
                  onItemTap: (item) => _openUrl(item.videoUrl ?? item.link),
                  isSaved: _savedStore.isSaved,
                  onBookmarkTap: (item) => _savedStore.toggle(item),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isBootstrapping ? null : _refreshNews,
          ),
        ],
      ),
      body: _isBootstrapping
          ? const Center(child: CircularProgressIndicator())
          : _bootstrapError != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingLarge),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 48),
                        const SizedBox(height: AppConstants.paddingMedium),
                        Text(_bootstrapError!, textAlign: TextAlign.center),
                        const SizedBox(height: AppConstants.paddingMedium),
                        ElevatedButton(
                          onPressed: _bootstrap,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _buildNewsBody(),
    );
  }

  Widget _buildNewsBody() {
    return FutureBuilder<List<NewsItem>>(
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
        _latestItems = allNews;
        if (allNews.isEmpty) {
          return Center(
            child: ElevatedButton(
              onPressed: _refreshNews,
              child: const Text('Reload News'),
            ),
          );
        }

        final carouselItems = allNews.take(5).map((item) {
          return {
            'title': item.title,
            'category': item.category,
            'date': item.date,
            'imageUrl': item.imageUrl,
            'isVideo': item.isVideo.toString(),
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
              FeaturedCarousel(
                items: carouselItems,
                onItemTap: (index) {
                  final item = allNews[index];
                  _openUrl(item.videoUrl ?? item.link);
                },
              ),
              const SizedBox(height: AppConstants.paddingLarge),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: AppConstants.paddingSmall),
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final selected = category.id == _selectedCategoryId;
                    return ChoiceChip(
                      label: Text(category.name),
                      selected: selected,
                      onSelected: (_) => _onCategorySelected(category.id),
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
                itemCount: allNews.length,
                itemBuilder: (context, index) {
                  final item = allNews[index];
                  return ArticleCard(
                    title: item.title,
                    category: item.category,
                    date: item.date,
                    imageUrl: item.imageUrl,
                    isVideo: item.isVideo,
                    isSaved: _savedStore.isSaved(item),
                    onTap: () => _openUrl(item.videoUrl ?? item.link),
                    onBookmarkTap: () {
                      setState(() {
                        _savedStore.toggle(item);
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: AppConstants.paddingLarge),
            ],
          ),
        );
      },
    );
  }
}

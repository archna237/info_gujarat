import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../widgets/article_card.dart';
import '../widgets/featured_carousel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy Data
    final carouselItems = [
      {
        'title': 'Gujarat Government announces new scheme for students in upcoming academic year.',
        'category': 'Education',
        'date': '2 hours ago',
        'imageUrl': 'https://picsum.photos/seed/gujarat1/400/200',
      },
      {
        'title': 'New IT Park to be established in Gandhinagar, bringing 10,000 jobs.',
        'category': 'Technology',
        'date': '4 hours ago',
        'imageUrl': 'https://picsum.photos/seed/gujarat2/400/200',
      },
    ];

    final categories = ['All', 'Jobs', 'Education', 'Schemes', 'Technology'];

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
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppConstants.paddingMedium),
            
            // Breaking News Section
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
                    onPressed: () {},
                    child: const Text('View All'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            FeaturedCarousel(items: carouselItems),
            
            const SizedBox(height: AppConstants.paddingLarge),

            // Categories Strip
            SizedBox(
              height: 40,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: AppConstants.paddingSmall),
                itemBuilder: (context, index) {
                  return ChoiceChip(
                    label: Text(categories[index]),
                    selected: index == 0,
                    onSelected: (bool selected) {},
                  );
                },
              ),
            ),
            
            const SizedBox(height: AppConstants.paddingLarge),

            // Recent Updates
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
              itemCount: 5,
              itemBuilder: (context, index) {
                return const ArticleCard(
                  title: 'A detailed guide to applying for the new state scholarships online.',
                  category: 'Guides',
                  date: '5 hours ago',
                  imageUrl: 'https://picsum.photos/seed/gujarat3/400/200',
                );
              },
            ),
            
            const SizedBox(height: AppConstants.paddingLarge),
          ],
        ),
      ),
    );
  }
}

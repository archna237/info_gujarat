import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../widgets/article_card.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Articles', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        itemCount: 4,
        itemBuilder: (context, index) {
          return const ArticleCard(
            title: 'Gujarat Government announces new scheme for students in upcoming academic year.',
            category: 'Education',
            date: '2 hours ago',
            imageUrl: 'https://picsum.photos/seed/save/400/200',
          );
        },
      ),
    );
  }
}

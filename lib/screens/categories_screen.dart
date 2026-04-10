import 'package:flutter/material.dart';
import '../core/constants.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'name': 'Jobs & Careers', 'icon': Icons.work_outline, 'color': Colors.blueAccent},
      {'name': 'Education', 'icon': Icons.school_outlined, 'color': Colors.orangeAccent},
      {'name': 'Gov Schemes', 'icon': Icons.account_balance_outlined, 'color': Colors.green},
      {'name': 'Technology', 'icon': Icons.computer_outlined, 'color': Colors.purpleAccent},
      {'name': 'Health', 'icon': Icons.local_hospital_outlined, 'color': Colors.redAccent},
      {'name': 'Agriculture', 'icon': Icons.eco_outlined, 'color': Colors.lightGreen},
      {'name': 'Sports', 'icon': Icons.sports_cricket_outlined, 'color': Colors.indigoAccent},
      {'name': 'Business', 'icon': Icons.business_center_outlined, 'color': Colors.teal},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppConstants.paddingMedium,
          mainAxisSpacing: AppConstants.paddingMedium,
          childAspectRatio: 1.1,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final color = category['color'] as Color;
          
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: color.withOpacity(0.3), width: 1),
            ),
            color: color.withOpacity(0.05),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {},
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      category['icon'] as IconData,
                      size: 32,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Text(
                    category['name'] as String,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import '../core/constants.dart';
//
// class SettingsScreen extends StatelessWidget {
//   const SettingsScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
//       ),
//       body: ListView(
//         padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingMedium),
//         children: [
//           // Profile Section
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
//             child: Row(
//               children: [
//                 CircleAvatar(
//                   radius: 30,
//                   backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
//                   child: Icon(
//                     Icons.person,
//                     size: 30,
//                     color: Theme.of(context).colorScheme.primary,
//                   ),
//                 ),
//                 const SizedBox(width: AppConstants.paddingMedium),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Ramesh Patel',
//                         style: Theme.of(context).textTheme.titleLarge,
//                       ),
//                       Text(
//                         'ramesh.patel@example.com',
//                         style: Theme.of(context).textTheme.bodyMedium,
//                       ),
//                     ],
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.edit_outlined),
//                   onPressed: () {},
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: AppConstants.paddingLarge),
//           const Divider(),
//
//           // Settings Options
//           _buildSectionHeader(context, 'Preferences'),
//           _buildListTile(context, Icons.notifications_outlined, 'Notifications', 'Manage alerts', true),
//           _buildListTile(context, Icons.dark_mode_outlined, 'Dark Mode', 'Toggle theme', true),
//           _buildListTile(context, Icons.language_outlined, 'Language', 'English', false),
//
//           const Divider(),
//           _buildSectionHeader(context, 'Support'),
//           _buildListTile(context, Icons.help_outline, 'Help Center', 'FAQ and support', false),
//           _buildListTile(context, Icons.privacy_tip_outlined, 'Privacy Policy', '', false),
//           _buildListTile(context, Icons.info_outline, 'About Us', 'Version 1.0.0', false),
//
//           const SizedBox(height: AppConstants.paddingLarge),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
//             child: OutlinedButton.icon(
//               onPressed: () {},
//               icon: const Icon(Icons.logout),
//               label: const Text('Log Out'),
//               style: OutlinedButton.styleFrom(
//                 foregroundColor: Colors.red,
//                 side: const BorderSide(color: Colors.red),
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: AppConstants.paddingLarge),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSectionHeader(BuildContext context, String title) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(AppConstants.paddingMedium, AppConstants.paddingMedium, AppConstants.paddingMedium, 8),
//       child: Text(
//         title.toUpperCase(),
//         style: Theme.of(context).textTheme.labelMedium?.copyWith(
//           color: Theme.of(context).colorScheme.primary,
//           fontWeight: FontWeight.bold,
//           letterSpacing: 1.2,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildListTile(BuildContext context, IconData icon, String title, String subtitle, bool isSwitch) {
//     return ListTile(
//       leading: Container(
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Icon(icon, color: Theme.of(context).colorScheme.primary),
//       ),
//       title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
//       subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
//       trailing: isSwitch
//           ? Switch(value: title == 'Notifications', onChanged: (val) {})
//           : const Icon(Icons.chevron_right, color: Colors.grey),
//       onTap: () {},
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_constants.dart';
import '../models/post.dart';
import '../providers/post_provider.dart';

/// Detail screen showing the full content of a selected post
class DetailScreen extends StatelessWidget {
  final Post post;

  const DetailScreen({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Detail'),
        actions: [
          Consumer<PostProvider>(
            builder: (context, provider, child) {
              final isFavorite = provider.isFavorite(post.id);
              
              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : null,
                ),
                tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
                onPressed: () {
                  provider.toggleFavorite(post.id);
                  
                  // Show snackbar feedback
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isFavorite
                            ? 'Removed from favorites'
                            : 'Added to favorites',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post metadata
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    'U${post.userId}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.smallPadding),
                Text(
                  'User ${post.userId}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const Spacer(),
                Chip(
                  label: Text('ID: ${post.id}'),
                  backgroundColor: Colors.grey[200],
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Post title
            Text(
              post.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            
            const Divider(),
            const SizedBox(height: 16),
            
            // Post body
            Text(
              post.body,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

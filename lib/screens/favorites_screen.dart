import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_constants.dart';
import '../providers/post_provider.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/post_list_item.dart';
import 'detail_screen.dart';

/// Favorites screen displaying only the posts marked as favorites
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: Consumer<PostProvider>(
        builder: (context, provider, child) {
          final favoritePosts = provider.favoritePosts;

          // Empty state if no favorites
          if (favoritePosts.isEmpty) {
            return const EmptyStateWidget(
              message: AppConstants.emptyFavoritesMessage,
              icon: Icons.favorite_border,
            );
          }

          // Display favorite posts
          return ListView.builder(
            itemCount: favoritePosts.length,
            itemBuilder: (context, index) {
              final post = favoritePosts[index];
              return PostListItem(
                key: ValueKey(post.id),
                post: post,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailScreen(post: post),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

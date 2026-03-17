import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_constants.dart';
import '../providers/post_provider.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/post_list_item.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget_custom.dart';
import '../widgets/empty_state_widget.dart';
import 'detail_screen.dart';
import 'favorites_screen.dart';

/// Home screen displaying the paginated list of posts with search functionality
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    
    // Initialize provider on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PostProvider>();
      if (!provider.isInitialized) {
        provider.initialize();
      }
    });

    // Setup infinite scroll listener
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Handle scroll events for infinite scrolling
  void _onScroll() {
    if (_isBottom) {
      final provider = context.read<PostProvider>();
      if (!provider.isLoading && provider.hasMore) {
        provider.loadPosts(loadMore: true);
      }
    }
  }

  /// Check if scrolled to bottom
  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  /// Handle pull-to-refresh
  Future<void> _onRefresh() async {
    await context.read<PostProvider>().refreshPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced News Reader'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Favorites',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoritesScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Consumer<PostProvider>(
            builder: (context, provider, child) {
              return SearchBarWidget(
                initialValue: provider.searchQuery,
                onChanged: (query) {
                  provider.updateSearchQuery(query);
                },
              );
            },
          ),
          // Posts list
          Expanded(
            child: Consumer<PostProvider>(
              builder: (context, provider, child) {
                // Loading state (initial load)
                if (provider.isLoading && provider.posts.isEmpty) {
                  return const LoadingWidget(message: 'Loading posts...');
                }

                // Error state
                if (provider.hasError && provider.posts.isEmpty) {
                  return ErrorWidgetCustom(
                    message: provider.errorMessage,
                    onRetry: () => provider.retry(),
                  );
                }

                // Empty state
                if (provider.posts.isEmpty) {
                  return const EmptyStateWidget(
                    message: AppConstants.emptyStateMessage,
                  );
                }

                final filteredPosts = provider.filteredPosts;

                // Empty search results
                if (filteredPosts.isEmpty && provider.searchQuery.isNotEmpty) {
                  return const EmptyStateWidget(
                    message: AppConstants.emptySearchMessage,
                    icon: Icons.search_off,
                  );
                }

                // Posts list with pull-to-refresh
                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: filteredPosts.length + (provider.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Loading indicator at bottom
                      if (index >= filteredPosts.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final post = filteredPosts[index];
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
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

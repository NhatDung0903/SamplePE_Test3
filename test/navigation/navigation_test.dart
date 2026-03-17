import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:petest3/models/post.dart';
import 'package:petest3/providers/post_provider.dart';
import 'package:petest3/screens/home_screen.dart';
import 'package:petest3/screens/detail_screen.dart';
import 'package:petest3/screens/favorites_screen.dart';

// Mock PostProvider
class MockPostProvider extends Mock implements PostProvider {}

void main() {
  late MockPostProvider mockProvider;

  setUp(() {
    mockProvider = MockPostProvider();
    
    // Setup default mock behavior
    when(() => mockProvider.posts).thenReturn([]);
    when(() => mockProvider.filteredPosts).thenReturn([]);
    when(() => mockProvider.favoritePosts).thenReturn([]);
    when(() => mockProvider.favoriteIds).thenReturn(<int>{});
    when(() => mockProvider.isLoading).thenReturn(false);
    when(() => mockProvider.hasError).thenReturn(false);
    when(() => mockProvider.errorMessage).thenReturn('');
    when(() => mockProvider.searchQuery).thenReturn('');
    when(() => mockProvider.hasMore).thenReturn(false);
    when(() => mockProvider.isInitialized).thenReturn(true);
    when(() => mockProvider.isFavorite(any())).thenReturn(false);
    when(() => mockProvider.updateSearchQuery(any())).thenReturn(null);
    when(() => mockProvider.clearSearch()).thenReturn(null);
    when(() => mockProvider.toggleFavorite(any())).thenAnswer((_) async => {});
  });

  Widget createTestWidget() {
    return ChangeNotifierProvider<PostProvider>.value(
      value: mockProvider,
      child: const MaterialApp(
        home: HomeScreen(),
      ),
    );
  }

  group('Navigation Tests', () {
    testWidgets('tapping post item navigates to DetailScreen', (WidgetTester tester) async {
      // Arrange
      final testPost = Post(
        userId: 1,
        id: 1,
        title: 'Test Post',
        body: 'Test Body',
      );
      
      when(() => mockProvider.posts).thenReturn([testPost]);
      when(() => mockProvider.filteredPosts).thenReturn([testPost]);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Find and tap the post item
      final postItem = find.text('Test Post');
      expect(postItem, findsOneWidget);
      
      await tester.tap(postItem);
      await tester.pumpAndSettle();

      // Assert - DetailScreen should be in the widget tree
      expect(find.byType(DetailScreen), findsOneWidget);
      expect(find.text('Post Detail'), findsOneWidget);
    });

    testWidgets('tapping favorites icon navigates to FavoritesScreen', (WidgetTester tester) async {
      // Arrange
      when(() => mockProvider.posts).thenReturn([]);
      when(() => mockProvider.filteredPosts).thenReturn([]);
      when(() => mockProvider.favoritePosts).thenReturn([]);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Find the favorites button in AppBar
      final favoritesButton = find.byIcon(Icons.favorite);
      expect(favoritesButton, findsOneWidget);
      
      await tester.tap(favoritesButton);
      await tester.pumpAndSettle();

      // Assert - FavoritesScreen should be in the widget tree
      expect(find.byType(FavoritesScreen), findsOneWidget);
      expect(find.text('Favorites'), findsOneWidget);
    });

    testWidgets('back button on DetailScreen returns to HomeScreen', (WidgetTester tester) async {
      // Arrange
      final testPost = Post(
        userId: 1,
        id: 1,
        title: 'Test Post',
        body: 'Test Body',
      );
      
      when(() => mockProvider.posts).thenReturn([testPost]);
      when(() => mockProvider.filteredPosts).thenReturn([testPost]);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Navigate to detail screen
      await tester.tap(find.text('Test Post'));
      await tester.pumpAndSettle();
      
      expect(find.byType(DetailScreen), findsOneWidget);

      // Tap back button
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // Assert - should be back on HomeScreen
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('Advanced News Reader'), findsOneWidget);
    });

    testWidgets('navigating from favorites to detail and back', (WidgetTester tester) async {
      // Arrange
      final testPost = Post(
        userId: 1,
        id: 1,
        title: 'Favorite Post',
        body: 'Favorite Body',
      );
      
      // Initially no posts to avoid multiple favorite icons
      when(() => mockProvider.posts).thenReturn([]);
      when(() => mockProvider.filteredPosts).thenReturn([]);
      when(() => mockProvider.favoritePosts).thenReturn([testPost]);
      when(() => mockProvider.isFavorite(1)).thenReturn(true);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Navigate to favorites screen (no posts on home screen, so only one favorite icon)
      await tester.tap(find.byIcon(Icons.favorite));
      await tester.pumpAndSettle();
      
      expect(find.byType(FavoritesScreen), findsOneWidget);

      // Tap on favorite post
      await tester.tap(find.text('Favorite Post'));
      await tester.pumpAndSettle();

      // Assert - should be on DetailScreen
      expect(find.byType(DetailScreen), findsOneWidget);
      expect(find.text('Post Detail'), findsOneWidget);

      // Navigate back
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // Should be back on FavoritesScreen
      expect(find.byType(FavoritesScreen), findsOneWidget);
    });
  });
}

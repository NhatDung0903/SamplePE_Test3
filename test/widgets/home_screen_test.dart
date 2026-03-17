import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:petest3/core/constants/app_constants.dart';
import 'package:petest3/models/post.dart';
import 'package:petest3/providers/post_provider.dart';
import 'package:petest3/screens/home_screen.dart';

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
    when(() => mockProvider.hasMore).thenReturn(true);
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

  group('HomeScreen Widget Tests', () {
    testWidgets('displays loading indicator when loading', (WidgetTester tester) async {
      // Arrange
      when(() => mockProvider.isLoading).thenReturn(true);
      when(() => mockProvider.posts).thenReturn([]);
      when(() => mockProvider.filteredPosts).thenReturn([]);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading posts...'), findsOneWidget);
    });

    testWidgets('displays posts list after loading', (WidgetTester tester) async {
      // Arrange
      final testPosts = [
        Post(userId: 1, id: 1, title: 'Test Post 1', body: 'Body 1'),
        Post(userId: 1, id: 2, title: 'Test Post 2', body: 'Body 2'),
      ];
      
      when(() => mockProvider.isLoading).thenReturn(false);
      when(() => mockProvider.hasError).thenReturn(false);
      when(() => mockProvider.posts).thenReturn(testPosts);
      when(() => mockProvider.filteredPosts).thenReturn(testPosts);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      expect(find.text('Test Post 1'), findsOneWidget);
      expect(find.text('Test Post 2'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('displays empty state when no posts', (WidgetTester tester) async {
      // Arrange
      when(() => mockProvider.isLoading).thenReturn(false);
      when(() => mockProvider.hasError).thenReturn(false);
      when(() => mockProvider.posts).thenReturn([]);
      when(() => mockProvider.filteredPosts).thenReturn([]);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      expect(find.text(AppConstants.emptyStateMessage), findsOneWidget);
    });

    testWidgets('displays error state with retry button', (WidgetTester tester) async {
      // Arrange
      when(() => mockProvider.isLoading).thenReturn(false);
      when(() => mockProvider.hasError).thenReturn(true);
      when(() => mockProvider.errorMessage).thenReturn('Test error message');
      when(() => mockProvider.posts).thenReturn([]);
      when(() => mockProvider.filteredPosts).thenReturn([]);
      when(() => mockProvider.retry()).thenAnswer((_) async => {});

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      expect(find.text('Test error message'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('search bar is displayed', (WidgetTester tester) async {
      // Arrange
      when(() => mockProvider.posts).thenReturn([]);
      when(() => mockProvider.filteredPosts).thenReturn([]);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search posts by title...'), findsOneWidget);
    });

    testWidgets('favorites button is displayed in AppBar', (WidgetTester tester) async {
      // Arrange
      when(() => mockProvider.posts).thenReturn([]);
      when(() => mockProvider.filteredPosts).thenReturn([]);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.text('Advanced News Reader'), findsOneWidget);
    });

    testWidgets('search updates provider query', (WidgetTester tester) async {
      // Arrange
      when(() => mockProvider.posts).thenReturn([]);
      when(() => mockProvider.filteredPosts).thenReturn([]);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      await tester.enterText(find.byType(TextField), 'test query');
      
      // Assert
      verify(() => mockProvider.updateSearchQuery('test query')).called(1);
    });
  });
}

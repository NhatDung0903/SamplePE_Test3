import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petest3/core/errors/app_exceptions.dart';
import 'package:petest3/models/post.dart';
import 'package:petest3/repositories/post_repository.dart';
import 'package:petest3/services/post_api_service.dart';
import 'package:petest3/storage/local_storage_service.dart';

// Mock classes
class MockPostApiService extends Mock implements PostApiService {}
class MockLocalStorageService extends Mock implements LocalStorageService {}

void main() {
  late PostRepository repository;
  late MockPostApiService mockApiService;
  late MockLocalStorageService mockStorageService;

  // Sample test data
  final samplePosts = [
    Post(userId: 1, id: 1, title: 'Test Post 1', body: 'Body 1'),
    Post(userId: 1, id: 2, title: 'Test Post 2', body: 'Body 2'),
    Post(userId: 1, id: 3, title: 'Test Post 3', body: 'Body 3'),
  ];

  setUp(() {
    mockApiService = MockPostApiService();
    mockStorageService = MockLocalStorageService();
    repository = PostRepository(
      apiService: mockApiService,
      storageService: mockStorageService,
    );
  });

  group('PostRepository Tests', () {
    test('fetchPosts returns list when API succeeds', () async {
      // Arrange
      when(() => mockApiService.fetchAllPosts())
          .thenAnswer((_) async => samplePosts);
      when(() => mockStorageService.saveCachedPosts(any()))
          .thenAnswer((_) async => {});

      // Act
      final result = await repository.fetchPosts(page: 0, limit: 10);

      // Assert
      expect(result, isA<List<Post>>());
      expect(result.length, 3);
      expect(result, equals(samplePosts));
      verify(() => mockApiService.fetchAllPosts()).called(1);
      verify(() => mockStorageService.saveCachedPosts(samplePosts)).called(1);
    });

    test('fetchPosts handles error and falls back to cached data', () async {
      // Arrange
      when(() => mockApiService.fetchAllPosts())
          .thenThrow(NetworkException('Network error'));
      when(() => mockStorageService.getCachedPosts())
          .thenReturn(samplePosts);

      // Act
      final result = await repository.fetchPosts(page: 0, limit: 10);

      // Assert
      expect(result, isA<List<Post>>());
      expect(result.length, 3);
      verify(() => mockApiService.fetchAllPosts()).called(1);
      verify(() => mockStorageService.getCachedPosts()).called(1);
    });

    test('fetchPosts returns sample data when API fails and no cache', () async {
      // Arrange
      when(() => mockApiService.fetchAllPosts())
          .thenThrow(NetworkException('Network error'));
      when(() => mockStorageService.getCachedPosts())
          .thenReturn([]);

      // Act
      final result = await repository.fetchPosts(page: 0, limit: 10);

      // Assert - should return sample data instead of throwing
      expect(result, isA<List<Post>>());
      expect(result.length, 10); // First page of sample data
      expect(result.first.id, 1);
      expect(result.first.title, 'Understanding Flutter Architecture');
    });

    test('fetchPosts returns paginated results', () async {
      // Arrange
      final largeSamplePosts = List.generate(
        25,
        (index) => Post(
          userId: 1,
          id: index + 1,
          title: 'Post ${index + 1}',
          body: 'Body ${index + 1}',
        ),
      );
      when(() => mockApiService.fetchAllPosts())
          .thenAnswer((_) async => largeSamplePosts);
      when(() => mockStorageService.saveCachedPosts(any()))
          .thenAnswer((_) async => {});

      // Act
      final page0 = await repository.fetchPosts(page: 0, limit: 10);
      final page1 = await repository.fetchPosts(page: 1, limit: 10);
      final page2 = await repository.fetchPosts(page: 2, limit: 10);

      // Assert
      expect(page0.length, 10);
      expect(page1.length, 10);
      expect(page2.length, 5);
      expect(page0.first.id, 1);
      expect(page1.first.id, 11);
      expect(page2.first.id, 21);
    });

    test('hasCachedPosts returns correct value', () {
      // Arrange
      when(() => mockStorageService.hasCachedPosts()).thenReturn(true);

      // Act
      final result = repository.hasCachedPosts();

      // Assert
      expect(result, true);
      verify(() => mockStorageService.hasCachedPosts()).called(1);
    });

    test('refreshPosts forces new API call', () async {
      // Arrange
      when(() => mockApiService.fetchAllPosts())
          .thenAnswer((_) async => samplePosts);
      when(() => mockStorageService.saveCachedPosts(any()))
          .thenAnswer((_) async => {});

      // Act
      await repository.fetchPosts(page: 0, limit: 10);
      await repository.refreshPosts();

      // Assert - API should be called twice (once for fetch, once for refresh)
      verify(() => mockApiService.fetchAllPosts()).called(2);
    });
  });
}

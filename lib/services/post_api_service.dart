import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';
import '../core/errors/app_exceptions.dart';
import '../models/post.dart';

/// Service responsible for API communication
class PostApiService {
  final http.Client _client;

  PostApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetch all posts from the API
  Future<List<Post>> fetchAllPosts() async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.postsEndpoint}');
      debugPrint('Fetching posts from: $url');
      
      final response = await _client
          .get(
            url,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'User-Agent': 'Flutter-News-Reader/1.0',
            },
          )
          .timeout(AppConstants.apiTimeout);
      
      debugPrint('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        final posts = jsonList.map((json) => Post.fromJson(json)).toList();
        debugPrint('Successfully fetched ${posts.length} posts');
        return posts;
      } else {
        debugPrint('API error: ${response.statusCode} - ${response.body}');
        throw ApiException(
          'Failed to load posts',
          response.statusCode,
          response.body,
        );
      }
    } on ApiException {
      rethrow;
    } on http.ClientException catch (e) {
      debugPrint('HTTP ClientException: ${e.message}');
      throw NetworkException('Network error: ${e.message}');
    } catch (e) {
      debugPrint('Unexpected error in fetchAllPosts: $e');
      throw NetworkException('Connection failed: $e');
    }
  }

  /// Fetch a single post by ID
  Future<Post> fetchPostById(int id) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.postsEndpoint}/$id');
      
      final response = await _client
          .get(
            url,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'User-Agent': 'Flutter-News-Reader/1.0',
            },
          )
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        return Post.fromJson(json.decode(response.body));
      } else {
        throw ApiException(
          'Failed to load post',
          response.statusCode,
          response.body,
        );
      }
    } on ApiException {
      rethrow;
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } catch (e) {
      throw NetworkException('Connection failed: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _client.close();
  }
}

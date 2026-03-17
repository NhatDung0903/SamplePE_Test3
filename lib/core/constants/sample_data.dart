import '../../models/post.dart';

/// Sample data for testing and fallback
class SampleData {
  static final List<Post> samplePosts = [
    Post(
      userId: 1,
      id: 1,
      title: 'Understanding Flutter Architecture',
      body: 'Flutter uses a reactive framework that makes it easy to build beautiful UIs. In this post, we explore the core concepts of Flutter architecture including widgets, state management, and the render tree.',
    ),
    Post(
      userId: 1,
      id: 2,
      title: 'Getting Started with Provider',
      body: 'Provider is one of the most popular state management solutions in Flutter. This article walks through the basics of using Provider for managing app state effectively.',
    ),
    Post(
      userId: 1,
      id: 3,
      title: 'Best Practices for API Integration',
      body: 'Learn how to integrate RESTful APIs in your Flutter app with proper error handling, caching strategies, and offline support. These patterns will make your apps more robust.',
    ),
    Post(
      userId: 2,
      id: 4,
      title: 'Building Responsive Layouts',
      body: 'Creating layouts that work across different screen sizes is crucial. Discover techniques for building responsive UIs using MediaQuery, LayoutBuilder, and adaptive widgets.',
    ),
    Post(
      userId: 2,
      id: 5,
      title: 'Testing Flutter Applications',
      body: 'Testing is essential for maintaining code quality. This guide covers unit tests, widget tests, and integration tests to ensure your Flutter app works as expected.',
    ),
    Post(
      userId: 2,
      id: 6,
      title: 'Optimizing App Performance',
      body: 'Performance optimization techniques including reducing widget rebuilds, lazy loading, image caching, and profiling tools to make your Flutter app lightning fast.',
    ),
    Post(
      userId: 3,
      id: 7,
      title: 'Navigation and Routing Guide',
      body: 'Master navigation in Flutter with Navigator 2.0, named routes, and passing data between screens. Build complex navigation flows with ease.',
    ),
    Post(
      userId: 3,
      id: 8,
      title: 'Working with Animations',
      body: 'Animations bring your app to life. Learn about implicit and explicit animations, AnimationController, Tween, and creating custom animation effects.',
    ),
    Post(
      userId: 3,
      id: 9,
      title: 'Local Storage Solutions',
      body: 'Explore different options for persisting data locally: SharedPreferences for simple key-value pairs, SQLite for structured data, and Hive for NoSQL storage.',
    ),
    Post(
      userId: 4,
      id: 10,
      title: 'Material Design in Flutter',
      body: 'Flutter provides excellent support for Material Design. Learn how to use Material widgets, themes, and design patterns to create beautiful Android-style apps.',
    ),
    Post(
      userId: 4,
      id: 11,
      title: 'Custom Paint and Canvas',
      body: 'Go beyond standard widgets with CustomPaint. Draw custom shapes, charts, and graphics using Canvas API for complete control over your UI.',
    ),
    Post(
      userId: 4,
      id: 12,
      title: 'Internationalization (i18n)',
      body: 'Make your app accessible to users worldwide by adding multi-language support. Learn about localization, date formatting, and right-to-left layout support.',
    ),
    Post(
      userId: 5,
      id: 13,
      title: 'Firebase Integration',
      body: 'Integrate Firebase services including Authentication, Firestore, Cloud Storage, and Analytics to add backend functionality to your Flutter app.',
    ),
    Post(
      userId: 5,
      id: 14,
      title: 'Push Notifications Setup',
      body: 'Implement push notifications using Firebase Cloud Messaging. Handle foreground and background notifications, and create rich notification experiences.',
    ),
    Post(
      userId: 5,
      id: 15,
      title: 'Debugging Tools and Techniques',
      body: 'Master the Flutter DevTools for debugging performance issues, inspecting widget trees, analyzing memory usage, and identifying bottlenecks in your app.',
    ),
    Post(
      userId: 6,
      id: 16,
      title: 'Platform Channels Deep Dive',
      body: 'Bridge the gap between Flutter and native code using platform channels. Access platform-specific features and integrate native libraries.',
    ),
    Post(
      userId: 6,
      id: 17,
      title: 'App Deployment Checklist',
      body: 'Everything you need to know before deploying to production: app signing, versioning, Play Store and App Store requirements, and release best practices.',
    ),
    Post(
      userId: 6,
      id: 18,
      title: 'Continuous Integration for Flutter',
      body: 'Set up CI/CD pipelines for your Flutter projects using GitHub Actions, Codemagic, or Fastlane. Automate testing and deployment processes.',
    ),
    Post(
      userId: 7,
      id: 19,
      title: 'Security Best Practices',
      body: 'Secure your Flutter app by protecting API keys, implementing certificate pinning, encrypting sensitive data, and following security guidelines.',
    ),
    Post(
      userId: 7,
      id: 20,
      title: 'Advanced State Management',
      body: 'Explore advanced state management solutions including BLoC, Riverpod, GetX, and MobX. Compare their pros and cons for different use cases.',
    ),
  ];
}

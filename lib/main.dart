import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/post_provider.dart';
import 'repositories/post_repository.dart';
import 'services/post_api_service.dart';
import 'storage/local_storage_service.dart';
import 'screens/home_screen.dart';

/// Main entry point of the application
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize local storage service
  final storageService = await LocalStorageService.create();
  
  runApp(MyApp(storageService: storageService));
}

/// Root widget of the application
class MyApp extends StatelessWidget {
  final LocalStorageService storageService;

  const MyApp({
    super.key,
    required this.storageService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provide PostProvider to entire app
        ChangeNotifierProvider(
          create: (context) {
            final apiService = PostApiService();
            final repository = PostRepository(
              apiService: apiService,
              storageService: storageService,
            );
            return PostProvider(
              repository: repository,
              storageService: storageService,
            );
          },
        ),
      ],
      child: MaterialApp(
        title: 'Advanced News Reader App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

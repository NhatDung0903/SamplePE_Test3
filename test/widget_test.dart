// Main app smoke test
// This test verifies the app can be built and initialized properly

import 'package:flutter_test/flutter_test.dart';
import 'package:petest3/main.dart';
import 'package:petest3/storage/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App initializes and builds successfully', (WidgetTester tester) async {
    // Initialize SharedPreferences with mock
    SharedPreferences.setMockInitialValues({});
    
    // Create storage service
    final storageService = await LocalStorageService.create();
    
    // Build our app and trigger a frame
    await tester.pumpWidget(MyApp(storageService: storageService));
    
    // Verify that the app title is present
    expect(find.text('Advanced News Reader'), findsOneWidget);
  });
}


import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:pulse_of_sound/main.dart';
import 'package:pulse_of_sound/utils/shared_pref_helper.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:pulse_of_sound/api/api_config.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App smoke test - Startup verification', (WidgetTester tester) async {
    // 1. Initialize dependencies manually for the test environment
    // Note: We skip dotenv.load(), so ApiConfig will use its safe fallback values.
    
    await SharedPrefsHelper.init();
    
    await Parse().initialize(
      ApiConfig.appId,
      ApiConfig.baseUrl,
      clientKey: null,
      autoSendSessionId: true,
      debug: true,
    );

    // 2. Load the App Widget directly with forced screen size for ScreenUtil
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(size: Size(375, 812)),
        child: MyApp(),
      ),
    );
    
    // 3. Wait for Splash Screen animation or initial load
    await tester.pump(const Duration(seconds: 5));

    // 4. Verify basic presence
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Optional: Log success
    debugPrint('✅ App started successfully in test environment');
  });
}

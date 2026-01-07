import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:pulse_of_sound/Colors/theme.dart';
import 'package:pulse_of_sound/SplashScreen/SplashScreen.dart';
import 'TEST/APITestScreen.dart';
import 'TEST/SuperAdminPermissionsTest.dart';

import 'utils/shared_pref_helper.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pulse_of_sound/api/api_config.dart';

// ... other imports ...

Future<void> main() async {
  // Load environment variables strictly
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("Warning: .env file not found, using fallback values.");
  }

  // Initialize Sentry for error tracking
  await SentryFlutter.init(
    (options) {
      options.dsn = ''; // TODO: Add DSN
      options.environment = dotenv.env['ENVIRONMENT'] ?? 'development';
      options.release = 'pulse_of_sound@1.0.0';
      options.tracesSampleRate = 1.0;
      options.attachScreenshot = true;
      options.attachViewHierarchy = true;
      options.beforeSend = (event, hint) {
        event.request?.headers?.remove('X-Parse-Session-Token');
        event.request?.headers?.remove('Authorization');
        return event;
      };
    },
    appRunner: () async {
      WidgetsFlutterBinding.ensureInitialized();
      await SharedPrefsHelper.init();

      // Initialize date formatting for Arabic
      await initializeDateFormatting('ar', null);
      Intl.defaultLocale = 'ar';

      // Use ApiConfig which will read from .env (with fallback)
      await Parse().initialize(
        ApiConfig.appId,
        ApiConfig.parseApiUrl,
        clientKey: null,
        autoSendSessionId: true,
        debug: true,
      );

      runApp(const MyApp());
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            home: const SplashScreen(),
            routes: {
              '/test': (context) => const APITestScreen(),
              '/superadmin-test': (context) =>
                  const SuperAdminPermissionsTest(),
            });
      },
    );
  }
}

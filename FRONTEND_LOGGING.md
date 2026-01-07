# Frontend Logging & Error Tracking Guide

## 📋 Overview

This guide explains how to implement error tracking and logging in the Flutter frontend using **Sentry**.

## 🎯 Why Sentry?

- ✅ **Real-time error tracking**: Get notified immediately when users encounter errors
- ✅ **Stack traces**: See exactly where errors occur
- ✅ **User context**: Know which users are affected
- ✅ **Performance monitoring**: Track app performance
- ✅ **Release tracking**: Compare error rates across versions

## 🛠️ Installation

### Step 1: Add Dependency

Add to `pubspec.yaml`:

```yaml
dependencies:
  sentry_flutter: ^7.14.0
```

Then run:
```bash
flutter pub get
```

### Step 2: Get Sentry DSN

1. Go to [sentry.io](https://sentry.io)
2. Create a free account
3. Create a new Flutter project
4. Copy your DSN (looks like: `https://xxx@xxx.ingest.sentry.io/xxx`)

## 📝 Implementation

### Step 1: Initialize Sentry

Update `main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = 'YOUR_SENTRY_DSN_HERE';
      // Set environment
      options.environment = 'production'; // or 'development'
      // Set release version
      options.release = 'pulse_of_sound@1.0.0';
      // Enable performance monitoring
      options.tracesSampleRate = 1.0;
      // Attach screenshots on errors
      options.attachScreenshot = true;
      // Attach view hierarchy
      options.attachViewHierarchy = true;
    },
    appRunner: () => runApp(const MyApp()),
  );
}
```

### Step 2: Wrap App with Error Boundary

```dart
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ... your app configuration
      
      // Add navigation observer for breadcrumbs
      navigatorObservers: [
        SentryNavigatorObserver(),
      ],
    );
  }
}
```

### Step 3: Create Logging Utility

Create `lib/utils/error_logger.dart`:

```dart
import 'package:sentry_flutter/sentry_flutter.dart';

class ErrorLogger {
  /// Log an error to Sentry
  static Future<void> logError(
    dynamic error,
    StackTrace? stackTrace, {
    String? context,
    Map<String, dynamic>? extra,
  }) async {
    await Sentry.captureException(
      error,
      stackTrace: stackTrace,
      hint: Hint.withMap({
        'context': context ?? 'Unknown',
        ...?extra,
      }),
    );
  }

  /// Log a message to Sentry
  static Future<void> logMessage(
    String message, {
    SentryLevel level = SentryLevel.info,
    Map<String, dynamic>? extra,
  }) async {
    await Sentry.captureMessage(
      message,
      level: level,
      hint: extra != null ? Hint.withMap(extra) : null,
    );
  }

  /// Set user context
  static Future<void> setUser({
    required String id,
    String? username,
    String? email,
  }) async {
    await Sentry.configureScope((scope) {
      scope.setUser(SentryUser(
        id: id,
        username: username,
        email: email,
      ));
    });
  }

  /// Clear user context (on logout)
  static Future<void> clearUser() async {
    await Sentry.configureScope((scope) {
      scope.setUser(null);
    });
  }

  /// Add breadcrumb (for tracking user actions)
  static void addBreadcrumb({
    required String message,
    String? category,
    Map<String, dynamic>? data,
  }) {
    Sentry.addBreadcrumb(Breadcrumb(
      message: message,
      category: category,
      data: data,
      timestamp: DateTime.now(),
    ));
  }
}
```

## 🎯 Usage Examples

### 1. Catching API Errors

```dart
// In user_api.dart
try {
  final response = await http.post(url, headers: headers, body: body);
  
  if (response.statusCode != 200) {
    await ErrorLogger.logError(
      'API Error: ${response.statusCode}',
      StackTrace.current,
      context: 'loginUser',
      extra: {
        'url': url.toString(),
        'statusCode': response.statusCode,
        'response': response.body,
      },
    );
  }
  
  return jsonDecode(response.body);
} catch (e, stackTrace) {
  await ErrorLogger.logError(
    e,
    stackTrace,
    context: 'loginUser',
    extra: {'username': username},
  );
  rethrow;
}
```

### 2. Tracking User Sessions

```dart
// After successful login
await ErrorLogger.setUser(
  id: result['id'],
  username: result['username'],
  email: result['email'],
);

// On logout
await ErrorLogger.clearUser();
```

### 3. Adding Breadcrumbs

```dart
// Track user navigation
ErrorLogger.addBreadcrumb(
  message: 'User navigated to Booking screen',
  category: 'navigation',
  data: {'screen': 'BookingScreen'},
);

// Track user actions
ErrorLogger.addBreadcrumb(
  message: 'User clicked charge wallet button',
  category: 'user_action',
  data: {'amount': 1000},
);
```

### 4. Logging Important Events

```dart
// Successful payment
await ErrorLogger.logMessage(
  'Wallet charged successfully',
  level: SentryLevel.info,
  extra: {
    'userId': userId,
    'amount': amount,
    'newBalance': newBalance,
  },
);

// Warning
await ErrorLogger.logMessage(
  'Low wallet balance',
  level: SentryLevel.warning,
  extra: {
    'userId': userId,
    'balance': balance,
  },
);
```

### 5. Catching Widget Errors

```dart
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    try {
      return YourWidget();
    } catch (e, stackTrace) {
      ErrorLogger.logError(
        e,
        stackTrace,
        context: 'MyWidget.build',
      );
      
      // Show error UI
      return ErrorWidget(e);
    }
  }
}
```

## 🔒 Privacy & Security

### Don't Log Sensitive Data

```dart
// ❌ BAD - Logging password
await ErrorLogger.logError(
  error,
  stackTrace,
  extra: {'password': password}, // DON'T DO THIS!
);

// ✅ GOOD - Sanitize sensitive data
await ErrorLogger.logError(
  error,
  stackTrace,
  extra: {'username': username}, // OK
);
```

### Filter Sensitive Information

In `main.dart`:

```dart
await SentryFlutter.init(
  (options) {
    options.dsn = 'YOUR_DSN';
    
    // Filter sensitive data
    options.beforeSend = (event, hint) {
      // Remove sensitive headers
      event.request?.headers?.remove('X-Parse-Session-Token');
      event.request?.headers?.remove('Authorization');
      
      return event;
    };
  },
  appRunner: () => runApp(const MyApp()),
);
```

## 📊 Monitoring Dashboard

### Key Metrics to Track

1. **Error Rate**: Errors per user session
2. **Crash-Free Sessions**: Percentage of sessions without crashes
3. **Most Common Errors**: Top errors by frequency
4. **Affected Users**: Number of users experiencing errors
5. **Performance**: App startup time, screen load times

### Setting Up Alerts

1. Go to Sentry dashboard
2. Navigate to **Alerts** → **Create Alert Rule**
3. Set conditions:
   - Error rate > 5% in 5 minutes
   - New error type detected
   - Specific error pattern

## 🚀 Best Practices

### 1. Use Error Boundaries

Wrap critical sections with try-catch:

```dart
Future<void> criticalOperation() async {
  try {
    await riskyOperation();
  } catch (e, stackTrace) {
    await ErrorLogger.logError(e, stackTrace, context: 'criticalOperation');
    // Show user-friendly error message
    showErrorDialog();
  }
}
```

### 2. Add Context

Always provide context for errors:

```dart
await ErrorLogger.logError(
  error,
  stackTrace,
  context: 'BookingFlow.confirmBooking',
  extra: {
    'doctorId': doctorId,
    'appointmentTime': time,
    'userId': userId,
  },
);
```

### 3. Track User Journey

Use breadcrumbs to understand what led to an error:

```dart
ErrorLogger.addBreadcrumb(message: 'Opened booking screen');
ErrorLogger.addBreadcrumb(message: 'Selected doctor');
ErrorLogger.addBreadcrumb(message: 'Chose time slot');
ErrorLogger.addBreadcrumb(message: 'Confirmed booking'); // Error might occur here
```

### 4. Monitor Performance

```dart
final transaction = Sentry.startTransaction(
  'load_doctors',
  'http',
);

try {
  final doctors = await fetchDoctors();
  transaction.status = const SpanStatus.ok();
} catch (e) {
  transaction.status = const SpanStatus.internalError();
  rethrow;
} finally {
  await transaction.finish();
}
```

## 📝 Testing

### Test Sentry Integration

```dart
// Add a test button in debug mode
if (kDebugMode) {
  ElevatedButton(
    onPressed: () async {
      try {
        throw Exception('Test error for Sentry');
      } catch (e, stackTrace) {
        await ErrorLogger.logError(
          e,
          stackTrace,
          context: 'Sentry Test',
        );
      }
    },
    child: Text('Test Sentry'),
  );
}
```

## 🔗 Resources

- [Sentry Flutter Documentation](https://docs.sentry.io/platforms/flutter/)
- [Sentry Dashboard](https://sentry.io)
- [Best Practices](https://docs.sentry.io/platforms/flutter/best-practices/)

## 📈 Next Steps

1. ✅ Install Sentry
2. ✅ Initialize in main.dart
3. ✅ Create ErrorLogger utility
4. ✅ Add error tracking to critical flows
5. ✅ Set up alerts
6. ✅ Monitor dashboard regularly

---

**Last Updated**: 2026-01-07
**Status**: Ready for implementation

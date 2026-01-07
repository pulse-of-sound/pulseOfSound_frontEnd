import 'package:sentry_flutter/sentry_flutter.dart';

/// Error logging utility using Sentry
/// 
/// This class provides methods to log errors, messages, and user context
/// to Sentry for real-time error tracking and monitoring.
class ErrorLogger {
  /// Log an error to Sentry
  /// 
  /// [error] - The error object to log
  /// [stackTrace] - The stack trace (optional)
  /// [context] - Context string describing where the error occurred
  /// [extra] - Additional data to attach to the error
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
  /// 
  /// [message] - The message to log
  /// [level] - Severity level (info, warning, error, etc.)
  /// [extra] - Additional data to attach
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

  /// Set user context for error tracking
  /// 
  /// Call this after successful login to associate errors with specific users
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

  /// Clear user context
  /// 
  /// Call this on logout to stop associating errors with the user
  static Future<void> clearUser() async {
    await Sentry.configureScope((scope) {
      scope.setUser(null);
    });
  }

  /// Add breadcrumb for tracking user actions
  /// 
  /// Breadcrumbs help understand the sequence of events leading to an error
  /// 
  /// [message] - Description of the action
  /// [category] - Category (navigation, user_action, api_call, etc.)
  /// [data] - Additional data
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

  /// Log API error with full context
  /// 
  /// [endpoint] - API endpoint that failed
  /// [statusCode] - HTTP status code
  /// [error] - Error object
  /// [stackTrace] - Stack trace
  /// [requestData] - Request data (sanitized)
  static Future<void> logApiError({
    required String endpoint,
    required int statusCode,
    required dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? requestData,
  }) async {
    await logError(
      error,
      stackTrace,
      context: 'API Error',
      extra: {
        'endpoint': endpoint,
        'statusCode': statusCode,
        'requestData': requestData,
      },
    );
  }

  /// Log navigation event
  static void logNavigation(String screenName) {
    addBreadcrumb(
      message: 'Navigated to $screenName',
      category: 'navigation',
      data: {'screen': screenName},
    );
  }

  /// Log user action
  static void logUserAction(String action, {Map<String, dynamic>? data}) {
    addBreadcrumb(
      message: action,
      category: 'user_action',
      data: data,
    );
  }
}

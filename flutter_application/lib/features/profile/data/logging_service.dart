import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warn, error }

/// Structured logger singleton.
///
/// In debug builds all levels are printed. In release builds only
/// [LogLevel.info] and above are emitted to avoid leaking sensitive data.
///
/// Usage:
/// ```dart
/// log.info('Auth', 'User logged in', extra: {'uid': uid});
/// log.error('Weather', 'API call failed', error: e, stack: st);
/// ```
class LoggingService {
  LoggingService._();
  static final LoggingService instance = LoggingService._();

  LogLevel minLevel = kDebugMode ? LogLevel.debug : LogLevel.info;

  void debug(String tag, String message, {Map<String, dynamic>? extra}) =>
      _emit(LogLevel.debug, tag, message, extra: extra);

  void info(String tag, String message, {Map<String, dynamic>? extra}) =>
      _emit(LogLevel.info, tag, message, extra: extra);

  void warn(String tag, String message,
      {Object? error, Map<String, dynamic>? extra}) =>
      _emit(LogLevel.warn, tag, message, error: error, extra: extra);

  void error(String tag, String message,
      {Object? error, StackTrace? stack, Map<String, dynamic>? extra}) =>
      _emit(LogLevel.error, tag, message,
          error: error, stack: stack, extra: extra);

  void _emit(
    LogLevel level,
    String tag,
    String message, {
    Object? error,
    StackTrace? stack,
    Map<String, dynamic>? extra,
  }) {
    if (level.index < minLevel.index) return;

    final ts = DateTime.now().toIso8601String();
    final prefix = _levelLabel(level);
    final extraStr = extra != null && extra.isNotEmpty ? ' $extra' : '';
    final line = '$ts $prefix [$tag] $message$extraStr';

    debugPrint(line);
    if (error != null) debugPrint('  error: $error');
    if (stack != null && kDebugMode) debugPrint('  stack: $stack');
  }

  String _levelLabel(LogLevel l) => switch (l) {
        LogLevel.debug => 'DEBUG',
        LogLevel.info  => 'INFO ',
        LogLevel.warn  => 'WARN ',
        LogLevel.error => 'ERROR',
      };
}

// Convenience top-level accessor
LoggingService get log => LoggingService.instance;

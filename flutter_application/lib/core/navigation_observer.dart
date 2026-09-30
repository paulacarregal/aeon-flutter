import 'package:flutter/material.dart';

import 'observability/logging_service.dart';
import 'observability/metrics_service.dart';


/// Records a metric and log entry every time the user navigates to a new screen.
class MetricsNavigationObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _track('push', route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) _track('replace', newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) _track('pop_to', previousRoute);
  }

  void _track(String action, Route<dynamic> route) {
    final name = route.settings.name ?? 'unknown';
    // Sanitise key: replace / and - with . to form a valid Zabbix item key
    final safeKey = name.replaceAll('/', '.').replaceAll('-', '_').replaceAll(RegExp(r'^\.'), '');
    metrics.increment('aeon.nav.screen.$safeKey');
    log.info('Navigation', action, extra: {'screen': name});
  }
}

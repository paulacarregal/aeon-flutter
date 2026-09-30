import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:flutter_application/core/app_config.dart';
import 'package:flutter_application/core/zabbix/zabbix_sender.dart';

/// Singleton that collects app metrics and ships them to Zabbix in batches.
///
/// Keys follow the pattern: `aeon.<domain>.<metric>`
/// e.g.: `aeon.auth.login.success`, `aeon.firestore.read.duration_ms`
///
/// All Zabbix items must be created as Trapper type on the host defined by
/// `--dart-define=ZABBIX_HOST` (default: localhost).
class MetricsService {
  MetricsService._();
  static final MetricsService instance = MetricsService._();

  static const _zabbixHost = AppConfig.zabbixAppHost;
  static const _flushInterval = Duration(seconds: 30);
  static const _maxQueueSize = 50;

  final _sender = const ZabbixSender();
  final _queue = <ZabbixItem>[];
  Timer? _flushTimer;

  void init() {
    _flushTimer?.cancel();
    _flushTimer = Timer.periodic(_flushInterval, (_) => _flush());
    if (kDebugMode) debugPrint('[Metrics] initialized (flush every ${_flushInterval.inSeconds}s → Zabbix host: $_zabbixHost)');
  }

  void dispose() {
    _flushTimer?.cancel();
    _flush();
  }

  // ── Public API ───────────────────────────────────────────────────────────

  /// Increment a counter key by [by].
  void increment(String key, {int by = 1}) => _enqueue(key, '$by');

  /// Set a gauge to an absolute [value].
  void gauge(String key, num value) => _enqueue(key, '$value');

  /// Record a duration in milliseconds.
  void timing(String key, Duration duration) =>
      _enqueue(key, '${duration.inMilliseconds}');

  /// Measure an async operation and record its duration under [key].
  Future<T> measureAsync<T>(String key, Future<T> Function() fn) async {
    final sw = Stopwatch()..start();
    try {
      return await fn();
    } finally {
      sw.stop();
      timing(key, sw.elapsed);
    }
  }

  // ── Internals ────────────────────────────────────────────────────────────

  void _enqueue(String key, String value) {
    _queue.add(ZabbixItem(host: _zabbixHost, key: key, value: value));
    if (kDebugMode) debugPrint('[Metrics] $key=$value');
    if (_queue.length >= _maxQueueSize) _flush();
  }

  void _flush() {
    if (_queue.isEmpty) return;
    final batch = List<ZabbixItem>.from(_queue);
    _queue.clear();
    _sender.send(batch).then((ok) {
      if (kDebugMode) {
        final status = ok ? 'OK' : 'FAILED';
        debugPrint('[Metrics] flush ${batch.length} items → Zabbix [$status]');
      }
    });
  }
}

// Convenience top-level accessor
MetricsService get metrics => MetricsService.instance;

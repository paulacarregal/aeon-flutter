import 'dart:async';

import 'package:flutter/material.dart';

import '../domain/alert.dart';
import '../data/alert_service.dart';

class AlertProvider extends ChangeNotifier {
  final AlertService _alertService;
  StreamSubscription<List<Alert>>? _subscription;

  List<Alert> _alerts = [];

  List<Alert> get alerts => _alerts;
  List<Alert> get alertsAtivos => _alerts.where((a) => a.ativo).toList();

  AlertProvider({AlertService? alertService})
      : _alertService = alertService ?? AlertService() {
    _startListening();
  }

  void _startListening() {
    _subscription?.cancel();
    _subscription = _alertService.getAlerts().listen((data) {
      _alerts = data;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

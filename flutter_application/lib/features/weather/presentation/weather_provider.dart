import 'package:flutter/material.dart';

import '../data/weather_service.dart';
import '../domain/weather.dart';

enum WeatherStatus { initial, loading, loaded, error }

class WeatherProvider extends ChangeNotifier {
  final WeatherService _service;

  WeatherStatus _status = WeatherStatus.initial;
  Weather? _weather;
  String? _error;

  WeatherProvider({WeatherService? service})
      : _service = service ?? WeatherService();

  WeatherStatus get status => _status;
  Weather? get weather => _weather;
  String? get error => _error;

  Future<void> fetch() async {
    if (_status == WeatherStatus.loading) return;
    _status = WeatherStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _weather = await _service.getWeather();
      _status = WeatherStatus.loaded;
    } catch (e) {
      _error = e.toString();
      _status = WeatherStatus.error;
    } finally {
      notifyListeners();
    }
  }
}

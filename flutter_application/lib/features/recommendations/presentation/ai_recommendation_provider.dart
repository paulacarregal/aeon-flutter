import 'package:flutter/material.dart';

import '../data/ai_recommendation_service.dart';
import '../../map/domain/place.dart';
import '../../profile/domain/recommendation_profile.dart';
import '../../weather/domain/weather.dart';

class AiRecommendationProvider extends ChangeNotifier {
  final AiRecommendationService _service;

  AiRecommendationResult? _lastResult;
  bool _loading = false;
  String? _error;

  AiRecommendationProvider({AiRecommendationService? service})
      : _service = service ?? AiRecommendationService();

  AiRecommendationResult? get lastResult => _lastResult;
  bool get loading => _loading;
  String? get error => _error;

  Future<AiRecommendationResult?> generateNotification({
    required RecommendationProfile? profile,
    required Weather? weather,
    required List<Place> places,
    String transportMode = 'a pe',
    Map<String, double> preferenceWeights = const {},
  }) async {
    if (_loading) return _lastResult;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _lastResult = await _service.generateNotification(
        profile: profile,
        weather: weather,
        places: places,
        transportMode: transportMode,
        preferenceWeights: preferenceWeights,
      );
      return _lastResult;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}

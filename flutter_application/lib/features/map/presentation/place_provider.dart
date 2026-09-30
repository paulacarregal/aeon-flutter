import 'package:flutter/material.dart';

import '../domain/place.dart';
import '../data/place_repository.dart';
import '../data/place_recommendation_service.dart';
import '../../profile/domain/recommendation_profile.dart';

class PlaceProvider extends ChangeNotifier {
  final PlaceRecommendationService _recommendations =
      PlaceRecommendationService();
  List<Place> _places = [];
  List<Place> _filtered = [];
  RecommendationProfile? _profile;
  bool _loading = false;
  String? _error;

  List<Place> get places => _places;
  List<Place> get filtered => _filtered;
  RecommendationProfile? get profile => _profile;
  bool get loading => _loading;
  String? get error => _error;

  PlaceProvider() {
    _load();
  }

  void _load() {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _places = getAllPlaces();
      _filtered = _rankedPlaces(_places);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void search(String query) {
    if (query.isEmpty) {
      _filtered = _rankedPlaces(_places);
    } else {
      _filtered = _rankedPlaces(_places
          .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
          .toList());
    }
    notifyListeners();
  }

  void clearSearch() {
    _filtered = _rankedPlaces(_places);
    notifyListeners();
  }

  void applyProfile(RecommendationProfile profile) {
    _profile = profile;
    _filtered = _rankedPlaces(_filtered.isEmpty ? _places : _filtered);
    notifyListeners();
  }

  List<Place> _rankedPlaces(List<Place> source) {
    final profile = _profile;
    if (profile == null) return List.from(source);
    return _recommendations.rankPlaces(places: source, profile: profile);
  }
}

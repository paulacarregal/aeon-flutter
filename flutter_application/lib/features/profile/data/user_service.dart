import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_paths.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createUser({
    required String uid,
    required String nome,
    required String email,
  }) async {
    await _db.collection(FirestorePaths.users).doc(uid).set({
      'uid': uid,
      'nome': nome,
      'email': email,
      'createdAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  Future<void> updateRecommendationProfile({
    required String uid,
    required String profileName,
    required List<String> preferredTags,
  }) async {
    await _db.collection(FirestorePaths.users).doc(uid).set({
      'profileName': profileName,
      'preferredTags': preferredTags,
      'quizCompleted': true,
      'quizCompletedAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  Future<void> updateRecommendationPreferences({
    required String uid,
    required Map<String, dynamic> preferences,
  }) async {
    await _db.collection(FirestorePaths.users).doc(uid).set({
      'recommendationPreferences': preferences,
      if (preferences['outdoor'] != null) 'radarOutdoor': preferences['outdoor'],
      if (preferences['active'] != null) 'radarActive': preferences['active'],
      if (preferences['night'] != null) 'radarNight': preferences['night'],
      if (preferences['social'] != null) 'radarSocial': preferences['social'],
      if (preferences['novelty'] != null) 'radarNovelty': preferences['novelty'],
      if (preferences['profileMapped'] != null)
        'profileMapped': preferences['profileMapped'],
      if (preferences['maxDistanceKm'] != null)
        'maxDistanceKm': preferences['maxDistanceKm'],
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }
}

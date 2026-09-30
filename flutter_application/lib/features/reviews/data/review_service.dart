import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/backend/backend_api_service.dart';
import '../../../core/constants/firestore_paths.dart';
import '../domain/review.dart';

class ReviewService {
  ReviewService({
    BackendApiService? backend,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _backend = backend ?? BackendApiService(),
        _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final BackendApiService _backend;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<void> publishReview({
    String? placeId,
    required String placeName,
    required String address,
    required int rating,
    required String comment,
    required List<String> tags,
    String? spendRange,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Usuario nao autenticado.');
    }
    final userName = await _resolveUserName(user);

    final payload = {
      'userId': user.uid,
      'placeId': placeId,
      'placeName': placeName,
      'address': address,
      'rating': rating,
      'comment': comment,
      'tags': tags,
      'spendRange': spendRange,
    };

    final validated = _backend.isConfigured
        ? await _backend.post('reviews/validate', payload)
        : _validateLocally(payload);

    await _firestore.collection(FirestorePaths.reviews).add({
      ...validated,
      'userId': user.uid,
      'userEmail': user.email,
      'userName': userName,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> _resolveUserName(User user) async {
    try {
      final doc = await _firestore
          .collection(FirestorePaths.users)
          .doc(user.uid)
          .get();
      final firestoreName = doc.data()?['nome']?.toString().trim();
      if (firestoreName != null && firestoreName.isNotEmpty) {
        return firestoreName;
      }
    } catch (_) {
      // Auth displayName is enough as a fallback if the profile document fails.
    }

    final authName = user.displayName?.trim();
    if (authName != null && authName.isNotEmpty) return authName;

    final email = user.email?.trim() ?? '';
    return email.isNotEmpty ? email.split('@').first : 'Explorador AEON';
  }

  Future<List<Review>> getRecentReviews({int limit = 20}) async {
    final snapshot = await _firestore
        .collection(FirestorePaths.reviews)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => Review.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<List<Review>> getReviewsByUser(String userId) async {
    final user = _auth.currentUser;
    final byUserId = await _firestore
        .collection(FirestorePaths.reviews)
        .where('userId', isEqualTo: userId)
        .get();

    var reviews = byUserId.docs
        .map((doc) => Review.fromMap(doc.id, doc.data()))
        .toList();

    if (reviews.isEmpty && user?.email != null) {
      final byEmail = await _firestore
          .collection(FirestorePaths.reviews)
          .where('userEmail', isEqualTo: user!.email)
          .get();
      reviews = byEmail.docs
          .map((doc) => Review.fromMap(doc.id, doc.data()))
          .toList();
    }

    reviews.sort((a, b) {
      final aDate = a.createdAt?.toDate();
      final bDate = b.createdAt?.toDate();
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return bDate.compareTo(aDate);
    });

    return reviews;
  }

  Future<void> deleteReview(String reviewId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Usuario nao autenticado.');
    }

    final doc =
        _firestore.collection(FirestorePaths.reviews).doc(reviewId);
    final snapshot = await doc.get();
    final data = snapshot.data();
    if (data == null) return;

    final ownerId = data['userId']?.toString();
    final ownerEmail = data['userEmail']?.toString();
    final isOwner = ownerId == user.uid || ownerEmail == user.email;
    if (!isOwner) {
      throw StateError('Voce so pode deletar suas proprias reviews.');
    }

    await doc.delete();
  }

  Map<String, dynamic> _validateLocally(Map<String, dynamic> payload) {
    final rawTags = payload['tags'] as List<dynamic>? ?? const [];
    return {
      ...payload,
      'tags': rawTags.map((tag) => tag.toString().trim()).where(
            (tag) => tag.isNotEmpty,
          ).toList(),
      'spendRange': payload['spendRange']?.toString().trim(),
      'profileHints': const [],
      'reviewPrompts': const [],
      'source': 'flutter-local',
      'status': 'validated',
    };
  }
}

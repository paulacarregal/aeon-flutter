import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/notification_model.dart';
import '../../../core/constants/firestore_paths.dart';

class NotificationRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<NotificationModel>> streamForUser(String uid) {
    return _db
        .collection(FirestorePaths.users)
        .doc(uid)
        .collection(FirestorePaths.notifications)
        .orderBy('criadoEm', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => NotificationModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> markAsRead(String uid, String notificationId) async {
    await _db
        .collection(FirestorePaths.users)
        .doc(uid)
        .collection(FirestorePaths.notifications)
        .doc(notificationId)
        .update({'lida': true});
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/observability/logging_service.dart';
import '../../core/observability/metrics_service.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> collection(String path) =>
      _db.collection(path);

  Future<DocumentReference<Map<String, dynamic>>> add(
    String collectionPath,
    Map<String, dynamic> data,
  ) async {
    metrics.increment('aeon.firestore.write.count');
    final sw = Stopwatch()..start();
    try {
      final ref = await _db.collection(collectionPath).add(data);
      sw.stop();
      metrics.timing('aeon.firestore.write.duration_ms', sw.elapsed);
      log.debug('Firestore', 'add', extra: {'col': collectionPath});
      return ref;
    } catch (e, st) {
      metrics.increment('aeon.firestore.error.count');
      log.error('Firestore', 'add failed',
          error: e, stack: st, extra: {'col': collectionPath});
      rethrow;
    }
  }

  Future<void> set(
    String collectionPath,
    String docId,
    Map<String, dynamic> data, {
    bool merge = false,
  }) async {
    metrics.increment('aeon.firestore.write.count');
    final sw = Stopwatch()..start();
    try {
      await _db.collection(collectionPath).doc(docId).set(
            data,
            merge ? SetOptions(merge: true) : null,
          );
      sw.stop();
      metrics.timing('aeon.firestore.write.duration_ms', sw.elapsed);
      log.debug('Firestore', 'set',
          extra: {'col': collectionPath, 'doc': docId});
    } catch (e, st) {
      metrics.increment('aeon.firestore.error.count');
      log.error('Firestore', 'set failed',
          error: e, stack: st, extra: {'col': collectionPath, 'doc': docId});
      rethrow;
    }
  }

  Future<void> update(
    String collectionPath,
    String docId,
    Map<String, dynamic> data,
  ) async {
    metrics.increment('aeon.firestore.write.count');
    final sw = Stopwatch()..start();
    try {
      await _db.collection(collectionPath).doc(docId).update(data);
      sw.stop();
      metrics.timing('aeon.firestore.write.duration_ms', sw.elapsed);
      log.debug('Firestore', 'update',
          extra: {'col': collectionPath, 'doc': docId});
    } catch (e, st) {
      metrics.increment('aeon.firestore.error.count');
      log.error('Firestore', 'update failed',
          error: e, stack: st, extra: {'col': collectionPath, 'doc': docId});
      rethrow;
    }
  }

  Future<void> delete(String collectionPath, String docId) async {
    metrics.increment('aeon.firestore.delete.count');
    try {
      await _db.collection(collectionPath).doc(docId).delete();
      log.debug('Firestore', 'delete',
          extra: {'col': collectionPath, 'doc': docId});
    } catch (e, st) {
      metrics.increment('aeon.firestore.error.count');
      log.error('Firestore', 'delete failed',
          error: e, stack: st, extra: {'col': collectionPath, 'doc': docId});
      rethrow;
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> get(
    String collectionPath,
    String docId,
  ) async {
    metrics.increment('aeon.firestore.read.count');
    final sw = Stopwatch()..start();
    try {
      final snap = await _db.collection(collectionPath).doc(docId).get();
      sw.stop();
      metrics.timing('aeon.firestore.read.duration_ms', sw.elapsed);
      log.debug('Firestore', 'get',
          extra: {'col': collectionPath, 'doc': docId, 'exists': snap.exists});
      return snap;
    } catch (e, st) {
      metrics.increment('aeon.firestore.error.count');
      log.error('Firestore', 'get failed',
          error: e, stack: st, extra: {'col': collectionPath, 'doc': docId});
      rethrow;
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> stream(String collectionPath) {
    metrics.increment('aeon.firestore.stream.subscriptions');
    log.debug('Firestore', 'stream opened', extra: {'col': collectionPath});
    return _db.collection(collectionPath).snapshots();
  }
}

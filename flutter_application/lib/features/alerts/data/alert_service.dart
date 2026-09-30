import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/alert.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../core/observability/logging_service.dart';
import '../../../core/observability/metrics_service.dart';

class AlertService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Alert>> getAlerts() {
    log.info('Alerts', 'stream subscribed');
    metrics.increment('aeon.alerts.stream.subscriptions');

    return _db.collection(FirestorePaths.alerts).snapshots().map((snapshot) {
      final all = snapshot.docs
          .map((doc) => Alert.fromMap(doc.id, doc.data()))
          .toList();

      final active = all.where((a) => a.ativo).length;
      metrics.gauge('aeon.alerts.active.count', active);
      metrics.gauge('aeon.alerts.total.count', all.length);
      log.debug('Alerts', 'snapshot received',
          extra: {'total': all.length, 'active': active});

      return all;
    });
  }
}

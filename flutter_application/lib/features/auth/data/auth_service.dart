import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/observability/logging_service.dart';
import '../../../core/observability/metrics_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmail(String email, String password) async {
    log.info('Auth', 'signIn attempt', extra: {'email': email});
    metrics.increment('aeon.auth.login.attempts');
    final sw = Stopwatch()..start();
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      sw.stop();
      metrics.increment('aeon.auth.login.success');
      metrics.timing('aeon.auth.login.duration_ms', sw.elapsed);
      log.info('Auth', 'signIn success', extra: {'uid': cred.user?.uid});
      return cred;
    } catch (e, st) {
      sw.stop();
      metrics.increment('aeon.auth.login.failure');
      log.error('Auth', 'signIn failed', error: e, stack: st);
      rethrow;
    }
  }

  Future<UserCredential> signUpWithEmail(String email, String password) async {
    log.info('Auth', 'signUp attempt', extra: {'email': email});
    metrics.increment('aeon.auth.register.attempts');
    final sw = Stopwatch()..start();
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      sw.stop();
      metrics.increment('aeon.auth.register.success');
      metrics.timing('aeon.auth.register.duration_ms', sw.elapsed);
      log.info('Auth', 'signUp success', extra: {'uid': cred.user?.uid});
      return cred;
    } catch (e, st) {
      sw.stop();
      metrics.increment('aeon.auth.register.failure');
      log.error('Auth', 'signUp failed', error: e, stack: st);
      rethrow;
    }
  }

  Future<void> signOut() async {
    log.info('Auth', 'signOut');
    metrics.increment('aeon.auth.logout.count');
    await _auth.signOut();
  }

  Future<void> sendPasswordReset(String email) {
    log.info('Auth', 'passwordReset requested', extra: {'email': email});
    metrics.increment('aeon.auth.password_reset.count');
    return _auth.sendPasswordResetEmail(email: email);
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './auth_service.dart';
import '../../profile/data/user_service.dart';

class AuthRepository {
  final AuthService _authService;
  final UserService _userService;

  AuthRepository({
    AuthService? authService,
    UserService? userService,
  })  : _authService = authService ?? AuthService(),
        _userService = userService ?? UserService();

  Stream<User?> get authStateChanges => _authService.authStateChanges;

  User? get currentUser => _authService.currentUser;

  Future<void> login(String email, String password) async {
    await _authService.signInWithEmail(email, password);
  }

  Future<void> register({
    required String email,
    required String password,
    required String nome,
  }) async {
    final credential = await _authService.signUpWithEmail(email, password);
    final user = credential.user!;
    await user.updateDisplayName(nome);
    final uid = user.uid;
    try {
      await _userService.createUser(uid: uid, nome: nome, email: email);
    } on FirebaseException {
      // The Auth account already exists; do not block the onboarding quiz if
      // Firestore rules/network fail during the optional profile document write.
    }
  }

  Future<void> logout() => _authService.signOut();
}

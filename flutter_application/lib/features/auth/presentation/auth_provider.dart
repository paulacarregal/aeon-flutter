import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../data/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  AuthStatus _status = AuthStatus.unknown;
  User? _user;
  String? _error;
  bool _loading = false;
  StreamSubscription<User?>? _authSub;

  AuthProvider({AuthRepository? repository})
      : _repository = repository ?? AuthRepository() {
    _authSub = _repository.authStateChanges.listen((user) {
      _user = user;
      _status = user != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
      notifyListeners();
    });
  }

  AuthStatus get status => _status;
  User? get user => _user;
  String? get error => _error;
  bool get loading => _loading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Future<bool> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.login(email, password);
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _mapAuthError(e.code);
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String nome,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.register(email: email, password: password, nome: nome);
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _mapAuthError(e.code);
      return false;
    } catch (_) {
      _error = 'Cadastro criado, mas nao foi possivel sincronizar o perfil.';
      return isAuthenticated || FirebaseAuth.instance.currentUser != null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _repository.logout();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Usuário não encontrado.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'invalid-credential':
        return 'E-mail ou senha inválidos.';
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'email-already-in-use':
        return 'Este e-mail já está cadastrado.';
      case 'weak-password':
        return 'A senha deve ter ao menos 6 caracteres.';
      default:
        return 'Falha na autenticação.';
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}

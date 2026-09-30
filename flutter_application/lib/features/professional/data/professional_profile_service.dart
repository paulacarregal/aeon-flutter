import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/professional_profile.dart';
import '../../../core/observability/logging_service.dart';

class ProfessionalProfileService {
  ProfessionalProfileService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('professionalProfiles');

  Future<ProfessionalProfile?> getCurrentProfile() async {
    final user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    try {
      final document = await _collection.doc(user.uid).get();

      if (!document.exists || document.data() == null) {
        return null;
      }

      return ProfessionalProfile.fromFirestore(
        document.data()!,
      );
    } catch (error, stackTrace) {
      log.error(
        'ProfessionalProfile',
        'Failed to load professional profile',
        error: error,
        stack: stackTrace,
      );

      rethrow;
    }
  }

  Future<bool> existsForCurrentUser() async {
    final user = _auth.currentUser;

    if (user == null) {
      return false;
    }

    final document = await _collection.doc(user.uid).get();

    return document.exists;
  }

  Future<void> saveCurrentProfile(
    ProfessionalProfile profile,
  ) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('Usuário não autenticado.');
    }

    if (profile.ownerUid != user.uid) {
      throw StateError('Usuário inválido para este perfil.');
    }

    try {
      final documentReference = _collection.doc(user.uid);
      final existingDocument = await documentReference.get();

      final data = profile.toFirestore();

      if (existingDocument.exists) {
        final existingData = existingDocument.data();

        data['createdAt'] = existingData?['createdAt'];
      } else {
        data['createdAt'] = FieldValue.serverTimestamp();
      }

      data['updatedAt'] = FieldValue.serverTimestamp();

      // O status não deve ser controlado pelo formulário.
      // Um novo cadastro começa como pending.
      data['status'] =
          existingDocument.data()?['status'] ?? 'pending';

      await documentReference.set(data);

      log.info(
        'ProfessionalProfile',
        'Professional profile saved',
        extra: {
          'type': profile.type.value,
        },
      );
    } catch (error, stackTrace) {
      log.error(
        'ProfessionalProfile',
        'Failed to save professional profile',
        error: error,
        stack: stackTrace,
      );

      rethrow;
    }
  }
}
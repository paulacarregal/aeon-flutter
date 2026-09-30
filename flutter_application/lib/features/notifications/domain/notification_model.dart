import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String titulo;
  final String corpo;
  final DateTime criadoEm;
  final bool lida;

  NotificationModel({
    required this.id,
    required this.titulo,
    required this.corpo,
    required this.criadoEm,
    this.lida = false,
  });

  factory NotificationModel.fromMap(String id, Map<String, dynamic> map) {
    return NotificationModel(
      id: id,
      titulo: map['titulo'] as String? ?? '',
      corpo: map['corpo'] as String? ?? '',
      criadoEm: map['criadoEm'] != null
          ? (map['criadoEm'] as Timestamp).toDate()
          : DateTime.now(),
      lida: map['lida'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'corpo': corpo,
      'criadoEm': Timestamp.fromDate(criadoEm),
      'lida': lida,
    };
  }

  NotificationModel copyWith({bool? lida}) {
    return NotificationModel(
      id: id,
      titulo: titulo,
      corpo: corpo,
      criadoEm: criadoEm,
      lida: lida ?? this.lida,
    );
  }
}

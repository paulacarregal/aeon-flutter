class Alert {
  final String id;
  final String titulo;
  final String descricao;
  final String nivel;
  final double latitude;
  final double longitude;
  final bool ativo;

  Alert({
    this.id = '',
    required this.titulo,
    required this.descricao,
    required this.nivel,
    required this.latitude,
    required this.longitude,
    required this.ativo,
  });

  factory Alert.fromMap(String id, Map<String, dynamic> map) {
    return Alert(
      id: id,
      titulo: map['titulo'] as String? ?? '',
      descricao: map['descricao'] as String? ?? '',
      nivel: map['nivel'] as String? ?? 'baixo',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      ativo: map['ativo'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descricao': descricao,
      'nivel': nivel,
      'latitude': latitude,
      'longitude': longitude,
      'ativo': ativo,
    };
  }
}

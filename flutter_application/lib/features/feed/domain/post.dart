class Post {
  final String id;
  final String nome;
  final String info;
  final String texto;
  final int rating;
  final int likes;
  final List<String> imagens;

  Post({
    this.id = '',
    required this.nome,
    required this.info,
    required this.texto,
    required this.rating,
    required this.likes,
    required this.imagens,
  });

  factory Post.fromMap(String id, Map<String, dynamic> map) {
    return Post(
      id: id,
      nome: map['nome'] as String? ?? '',
      info: map['info'] as String? ?? '',
      texto: map['texto'] as String? ?? '',
      rating: (map['rating'] as num?)?.toInt() ?? 0,
      likes: (map['likes'] as num?)?.toInt() ?? 0,
      imagens: List<String>.from(map['imagens'] as List? ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'info': info,
      'texto': texto,
      'rating': rating,
      'likes': likes,
      'imagens': imagens,
    };
  }
}

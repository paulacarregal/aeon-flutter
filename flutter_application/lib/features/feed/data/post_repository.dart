import '../domain/post.dart';

List<Post> getAllPosts() {
  return [
    Post(
      id: 'draculaura-catedral-se',
      nome: 'Draculaura',
      info: '6 Avaliacoes . 13 Fotos',
      texto:
          'Hoje fui conhecer um dos marcos historicos de Sao Paulo, uma experiencia cultural incrivel.\nLocal: Catedral da Se',
      rating: 4,
      likes: 45,
      imagens: [
        'assets/images/places/catedral_se_1.jpg',
        'assets/images/places/catedral_se_2.jpg',
        'assets/images/places/catedral_se_3.jpg',
      ],
    ),
    Post(
      id: 'ken-vista-rooftop',
      nome: 'Ken Fashionista',
      info: '8 Avaliacoes . 15 Fotos',
      texto:
          'Esse rooftop e simplesmente incrivel, com uma vista absurda da cidade.\nLocal: Vista Rooftop Bar',
      rating: 5,
      likes: 12,
      imagens: [
        'assets/images/places/vista_rooftop_1.jpg',
        'assets/images/places/vista_rooftop_2.jpg',
        'assets/images/places/vista_rooftop_3.jpg',
      ],
    ),
  ];
}

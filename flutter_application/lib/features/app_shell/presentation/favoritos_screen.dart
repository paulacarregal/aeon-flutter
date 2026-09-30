import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../feed/domain/post.dart';
import '../../feed/presentation/post_provider.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/widgets/favorite_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final savedPosts = context.watch<PostProvider>().savedPosts;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Favoritos',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: savedPosts.isEmpty
          ? const Center(child: Text('Nenhum favorito ainda.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: savedPosts.length,
              separatorBuilder: (context, i) => const SizedBox(height: 16),
              itemBuilder: (_, index) {
                final post = savedPosts[index];
                return FavoriteCard(
                  nome: _placeName(post),
                  rating: post.rating.toDouble(),
                  reviews: post.likes,
                  preco: post.info,
                  horario: '9h',
                  image: post.imagens.isNotEmpty ? post.imagens.first : '',
                );
              },
            ),
    );
  }

  String _placeName(Post post) {
    final marker = 'Local: ';
    final markerIndex = post.texto.lastIndexOf(marker);
    if (markerIndex >= 0) {
      return post.texto.substring(markerIndex + marker.length).trim();
    }
    return post.nome;
  }
}

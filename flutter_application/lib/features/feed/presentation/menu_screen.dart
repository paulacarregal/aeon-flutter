import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import './post_provider.dart';
import './post_detail_screen.dart';
import '../../auth/presentation/auth_provider.dart' as app;
import '../../../core/constants/firestore_paths.dart';
import '../../../shared/routes/route_names.dart';
import '../../../shared/widgets/post_card.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  String _fallbackNomeUsuario() {
    final user = FirebaseAuth.instance.currentUser;
    final authName = user?.displayName?.trim();
    if (authName != null && authName.isNotEmpty) return authName;

    final emailName = user?.email?.split('@').first.trim();
    if (emailName != null && emailName.isNotEmpty) return emailName;

    return 'Explorador';
  }

  Future<String> _getNomeUsuario() async {
    const fallbackName = 'Explorador';

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return fallbackName;
      final doc = await FirebaseFirestore.instance
          .collection(FirestorePaths.users)
          .doc(user.uid)
          .get();

      final firestoreName = doc.data()?['nome']?.toString().trim();
      if (firestoreName != null && firestoreName.isNotEmpty) {
        return firestoreName;
      }

      final authName = user.displayName?.trim();
      if (authName != null && authName.isNotEmpty) return authName;

      final emailName = user.email?.split('@').first.trim();
      if (emailName != null && emailName.isNotEmpty) return emailName;

      return fallbackName;
    } catch (_) {
      final authName = FirebaseAuth.instance.currentUser?.displayName?.trim();
      return authName != null && authName.isNotEmpty
          ? authName
          : fallbackName;
    }
  }

  Future<void> _logout(BuildContext context) async {
    await context.read<app.AuthProvider>().logout();
    if (!context.mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      RouteNames.login,
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = context.watch<PostProvider>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: false,
        title: FutureBuilder<String>(
          future: _getNomeUsuario(),
          builder: (context, snapshot) {
            return Text(
              'Olá, ${snapshot.data ?? _fallbackNomeUsuario()}!',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white54),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: postProvider.loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF750D8F)))
          : postProvider.error != null
              ? Center(
                  child: Text(postProvider.error!,
                      style: const TextStyle(color: Colors.white)))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: postProvider.posts.length,
                  itemBuilder: (_, index) {
                    final post = postProvider.posts[index];
                    return PostCard(
                      post: post,
                      liked: postProvider.isLiked(post),
                      saved: postProvider.isSaved(post),
                      displayLikes: postProvider.displayLikes(post),
                      onLike: () => postProvider.toggleLike(post),
                      onSave: () => postProvider.toggleSaved(post),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PostDetailScreen()),
                      ),
                    );
                  },
                ),
    );
  }
}

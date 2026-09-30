import 'package:flutter/material.dart';

import '../domain/post.dart';
import '../data/post_repository.dart';
import '../../reviews/data/review_service.dart';
import '../../reviews/domain/review.dart';

class PostProvider extends ChangeNotifier {
  final ReviewService _reviewService;

  List<Post> _posts = [];
  final Set<String> _likedPostIds = {};
  final Set<String> _savedPostIds = {
    'draculaura-catedral-se',
    'ken-vista-rooftop',
  };
  bool _loading = false;
  String? _error;

  List<Post> get posts => _posts;
  List<Post> get savedPosts =>
      _posts.where((post) => _savedPostIds.contains(_postKey(post))).toList();
  bool get loading => _loading;
  String? get error => _error;

  PostProvider({ReviewService? reviewService})
      : _reviewService = reviewService ?? ReviewService() {
    _load();
  }

  Future<void> refresh() => _load();

  Future<void> _load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final staticPosts = getAllPosts();
      final reviews = await _reviewService.getRecentReviews();
      _posts = [
        ...reviews.map(_postFromReview),
        ...staticPosts,
      ];
    } catch (e) {
      _error = e.toString();
      _posts = getAllPosts();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Post? getById(int index) {
    if (index < 0 || index >= _posts.length) return null;
    return _posts[index];
  }

  bool isLiked(Post post) => _likedPostIds.contains(_postKey(post));

  bool isSaved(Post post) => _savedPostIds.contains(_postKey(post));

  int displayLikes(Post post) {
    final key = _postKey(post);
    return post.likes + (_likedPostIds.contains(key) ? 1 : 0);
  }

  void toggleLike(Post post) {
    final key = _postKey(post);
    if (_likedPostIds.contains(key)) {
      _likedPostIds.remove(key);
    } else {
      _likedPostIds.add(key);
    }
    notifyListeners();
  }

  void toggleSaved(Post post) {
    final key = _postKey(post);
    if (_savedPostIds.contains(key)) {
      _savedPostIds.remove(key);
    } else {
      _savedPostIds.add(key);
    }
    notifyListeners();
  }

  Post _postFromReview(Review review) {
    final author = _authorName(review);
    final tags = review.tags.take(3).join(' | ');
    final details = [
      if (tags.isNotEmpty) tags,
      if (review.spendRange.isNotEmpty) 'Gasto ${review.spendRange}',
    ].join(' | ');
    final info = details.isNotEmpty ? details : review.address;
    final comment = review.comment.isNotEmpty
        ? review.comment
        : 'Publicou uma avaliacao para ${review.placeName}.';

    return Post(
      id: review.id,
      nome: author,
      info: info,
      texto: '$comment\nLocal: ${review.placeName}',
      rating: review.rating,
      likes: 0,
      imagens: const ['assets/images/places/bar_tan_tan_1.jpg'],
    );
  }

  String _authorName(Review review) {
    if (review.userName.isNotEmpty) return review.userName;
    if (review.userEmail.isNotEmpty) return review.userEmail.split('@').first;
    return 'Explorador AEON';
  }

  String _postKey(Post post) {
    if (post.id.isNotEmpty) return post.id;
    return '${post.nome}-${post.texto}'.hashCode.toString();
  }
}

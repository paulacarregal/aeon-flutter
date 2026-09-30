import 'package:flutter/material.dart';

import '../domain/quiz_question.dart';
import '../domain/recommendation_profile.dart';
import '../data/quiz_repository.dart';

class QuizProvider extends ChangeNotifier {
  final List<QuizQuestion> _questions = getQuizQuestions();
  int _currentIndex = 0;
  final List<int> _answers = [];

  List<QuizQuestion> get questions => _questions;
  int get currentIndex => _currentIndex;
  QuizQuestion get currentQuestion => _questions[_currentIndex];
  bool get isLastQuestion => _currentIndex >= _questions.length - 1;
  bool get isComplete => _answers.length >= _questions.length;
  double get progress => (_currentIndex + 1) / _questions.length;

  void answer(int opcao) {
    if (isComplete) return;

    _answers.add(opcao);
    if (!isLastQuestion) {
      _currentIndex++;
      notifyListeners();
    } else {
      notifyListeners();
    }
  }

  bool advance() {
    if (isLastQuestion) return false;
    _currentIndex++;
    notifyListeners();
    return true;
  }

  void reset() {
    _currentIndex = 0;
    _answers.clear();
    notifyListeners();
  }

  String get perfil {
    bool answerIs(int index, int value) =>
        _answers.length > index && _answers[index] == value;

    if ((answerIs(2, 1) || answerIs(8, 1)) &&
        answerIs(3, 2) &&
        answerIs(4, 2)) {
      return 'Noturno Social';
    }
    if (answerIs(5, 1) && (answerIs(2, 1) || answerIs(8, 1))) {
      return 'Livre em Movimento';
    }
    if ((answerIs(1, 2) || answerIs(6, 2)) && answerIs(0, 1)) {
      return 'Cacador de Novidades';
    }
    if (answerIs(2, 2) && answerIs(5, 2)) {
      return 'Refugio Calmo';
    }
    if (answerIs(3, 1) && answerIs(4, 1)) {
      return 'Roteiro Leve';
    }
    return 'Explorador Equilibrado';
  }

  RecommendationProfile get recommendationProfile {
    bool answerIs(int index, int value) =>
        _answers.length > index && _answers[index] == value;

    final preferredTags = <String>{};
    if (answerIs(0, 1)) preferredTags.addAll({'discover', 'culture'});
    if (answerIs(0, 2)) preferredTags.addAll({'comfort', 'local'});
    if (answerIs(1, 1)) preferredTags.addAll({'premium', 'rated'});
    if (answerIs(1, 2)) preferredTags.addAll({'new', 'discover'});
    if (answerIs(2, 1)) preferredTags.addAll({'active', 'social'});
    if (answerIs(2, 2)) preferredTags.addAll({'calm', 'comfort'});
    if (answerIs(3, 1)) preferredTags.add('day');
    if (answerIs(3, 2)) preferredTags.add('night');
    if (answerIs(4, 1)) preferredTags.add('solo');
    if (answerIs(4, 2)) preferredTags.add('social');
    if (answerIs(5, 1)) preferredTags.add('outdoor');
    if (answerIs(5, 2)) preferredTags.add('urban');
    if (answerIs(6, 1)) preferredTags.add('rated');
    if (answerIs(6, 2)) preferredTags.add('new');
    if (answerIs(8, 1)) preferredTags.addAll({'active', 'night'});
    if (answerIs(8, 2)) preferredTags.addAll({'calm', 'coffee'});
    if (answerIs(9, 1)) preferredTags.add('experience');
    if (answerIs(9, 2)) preferredTags.add('relax');

    return RecommendationProfile(
      name: perfil,
      preferredTags: preferredTags,
      prefersPremium: answerIs(1, 1),
      prefersNovelty: answerIs(1, 2) || answerIs(6, 2),
      prefersActive: answerIs(2, 1) || answerIs(8, 1),
      prefersDaytime: answerIs(3, 1),
      prefersSocial: answerIs(4, 2),
      prefersOutdoor: answerIs(5, 1),
      spontaneous: answerIs(7, 2),
    );
  }
}

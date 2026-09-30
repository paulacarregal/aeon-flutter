import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import './quiz_provider.dart';
import '../data/user_service.dart';
import '../../app_shell/presentation/navigation_screen.dart';
import '../../map/presentation/place_provider.dart';

class ProfileQuizScreen extends StatelessWidget {
  const ProfileQuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final pergunta = quiz.currentQuestion;

    return Scaffold(
      backgroundColor: const Color(0xFFF0FFF5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: quiz.progress,
                  minHeight: 6,
                  backgroundColor: Colors.black12,
                  color: const Color(0xFF750D8F),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${quiz.currentIndex + 1} / ${quiz.questions.length}',
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 32),
              Text(
                pergunta.pergunta,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 28),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final cardHeight = (constraints.maxHeight * 0.82)
                        .clamp(300.0, 430.0)
                        .toDouble();
                    final cardWidth = ((constraints.maxWidth - 10) / 2)
                        .clamp(140.0, 230.0)
                        .toDouble();

                    return Center(
                      child: SizedBox(
                        height: cardHeight + 20,
                        width: constraints.maxWidth,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                              left: 0,
                              top: 6,
                              child: _QuizOptionCard(
                                label: pergunta.opcao1,
                                emoji: pergunta.emoji1,
                                width: cardWidth,
                                height: cardHeight,
                                color: const Color(0xFF7B1FA2),
                                textColor: Colors.white,
                                angle: -0.025,
                                onTap: () => _responder(context, quiz, 1),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 6,
                              child: _QuizOptionCard(
                                label: pergunta.opcao2,
                                emoji: pergunta.emoji2,
                                width: cardWidth,
                                height: cardHeight,
                                color: const Color(0xFFEFF59E),
                                textColor: Colors.black,
                                angle: 0.025,
                                onTap: () => _responder(context, quiz, 2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }

  void _responder(BuildContext context, QuizProvider quiz, int opcao) {
    quiz.answer(opcao);

    if (!quiz.isComplete) return;

    final recommendationProfile = quiz.recommendationProfile;
    context.read<PlaceProvider>().applyProfile(recommendationProfile);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      UserService().updateRecommendationProfile(
        uid: uid,
        profileName: recommendationProfile.name,
        preferredTags: recommendationProfile.preferredTags.toList(),
      ).catchError((_) {});
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: _QuizCompleteSplash(quiz: quiz),
        ),
      ),
    );
  }
}

class _QuizOptionCard extends StatelessWidget {
  final String label;
  final String emoji;
  final double width;
  final double height;
  final Color color;
  final Color textColor;
  final double angle;
  final VoidCallback onTap;

  const _QuizOptionCard({
    required this.label,
    required this.emoji,
    required this.width,
    required this.height,
    required this.color,
    required this.textColor,
    required this.angle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(32),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(18, 26, 18, 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 88)),
              const SizedBox(height: 28),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textColor,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuizCompleteSplash extends StatefulWidget {
  final QuizProvider quiz;

  const _QuizCompleteSplash({required this.quiz});

  @override
  State<_QuizCompleteSplash> createState() => _QuizCompleteSplashState();
}

class _QuizCompleteSplashState extends State<_QuizCompleteSplash> {
  double _opacity = 1;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() => _opacity = 0);
    });
    Future.delayed(const Duration(milliseconds: 1450), () {
      if (!mounted) return;
      widget.quiz.reset();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const NavigationScreen(initialIndex: 1),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'AEON',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFBFF31),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Preparando suas recomendacoes',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'route_names.dart';
import '../../features/app_shell/presentation/splash_screen.dart';
import '../../features/app_shell/presentation/navigation_screen.dart';
import '../../features/app_shell/presentation/review_screen.dart';
import '../../features/app_shell/presentation/favoritos_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/cadastro_screen.dart';
import '../../features/profile/presentation/perfil_screen.dart';
import '../../features/profile/presentation/profile_quiz_screen.dart';
import '../../features/feed/presentation/post_detail_screen.dart';
import '../../features/map/presentation/maps_screen.dart';
import '../../features/professional/presentation/professional_account_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    RouteNames.splash:     (_) => const SplashScreen(),
    RouteNames.login:      (_) => const LoginScreen(),
    RouteNames.cadastro:   (_) => const CadastroScreen(),
    RouteNames.quiz:       (_) => const ProfileQuizScreen(),
    RouteNames.review:     (_) => const ReviewScreen(),
    RouteNames.navigation: (_) => const NavigationScreen(),
    RouteNames.favorites:  (_) => const FavoritesScreen(),
    RouteNames.profile:    (_) => const ProfileScreen(),
    RouteNames.maps:       (_) => const MapsScreen(),
    RouteNames.postDetail: (_) => const PostDetailScreen(),
    RouteNames.professionalAccount: (_) => const ProfessionalAccountScreen(),
  };
}

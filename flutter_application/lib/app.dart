import 'package:flutter/material.dart';

import 'core/navigation_observer.dart';
import 'shared/routes/app_routes.dart';
import 'shared/routes/route_names.dart';

class AeonApp extends StatelessWidget {
  const AeonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AEON',
      initialRoute: RouteNames.splash,
      routes: AppRoutes.routes,
      navigatorObservers: [MetricsNavigationObserver()],
    );
  }
}

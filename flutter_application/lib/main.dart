import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';


import 'app.dart';
import 'firebase_options.dart';
import 'core/observability/logging_service.dart';
import 'core/observability/metrics_service.dart';
import 'features/alerts/presentation/alert_provider.dart';
import 'features/auth/presentation/auth_provider.dart';
import 'features/feed/presentation/post_provider.dart';
import 'features/map/presentation/place_provider.dart';
import 'features/notifications/notification_service.dart';
import 'features/profile/presentation/quiz_provider.dart';
import 'features/recommendations/presentation/ai_recommendation_provider.dart';
import 'features/weather/presentation/weather_provider.dart';
import 'core/backend/backend_api_service.dart';


void main() async {
  final appStarted = Stopwatch()..start();
  WidgetsFlutterBinding.ensureInitialized();

  metrics.init();
  log.info('App', 'starting');

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    log.info('App', 'Firebase initialized');

  await _activateAppCheck();

  try {
    final health = await BackendApiService().getHealth();
    log.info('Backend', 'Health check successful', extra: health);
  } catch (error, stackTrace) {
    log.error(
      'Backend',
      'Health check failed',
      error: error,
      stack: stackTrace,
    );
  }
  final bool supportsPush = !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  if (supportsPush) {
    await NotificationService.initialize();
    await FirebaseMessaging.instance.requestPermission();
    final token = await FirebaseMessaging.instance.getToken();
    log.info('App', 'FCM token obtained', extra: {'token': token});
    metrics.increment('aeon.app.session.start');
  }

  appStarted.stop();
  metrics.timing('aeon.app.start.duration_ms', appStarted.elapsed);
  log.info('App', 'boot complete',
      extra: {'duration_ms': appStarted.elapsedMilliseconds});

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AlertProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => PlaceProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => AiRecommendationProvider()),
      ],
      child: const AeonApp(),
    ),
  );
}

Future<void> _activateAppCheck() async {
  const recaptchaSiteKey =
      String.fromEnvironment('RECAPTCHA_V3_SITE_KEY', defaultValue: '');

  try {
    if (kIsWeb) {
      if (recaptchaSiteKey.isEmpty) {
        log.warn(
          'AppCheck',
          'RECAPTCHA_V3_SITE_KEY not configured for web',
        );
        return;
      }

      await FirebaseAppCheck.instance.activate(
        providerWeb: ReCaptchaV3Provider(recaptchaSiteKey),
      );

      log.info('AppCheck', 'activated for web');
      return;
    }

    final supportsAppCheck =
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;

    if (!supportsAppCheck) {
      log.warn(
        'AppCheck',
        'platform not supported for App Check activation',
      );
      return;
    }

    await FirebaseAppCheck.instance.activate(
      providerAndroid: kDebugMode
          ? const AndroidDebugProvider()
          : const AndroidPlayIntegrityProvider(),
      providerApple: kDebugMode
          ? const AppleDeviceCheckProvider()
          : const AppleAppAttestWithDeviceCheckFallbackProvider(),
    );

    log.info('AppCheck', 'activated');
  } catch (e, st) {
    log.error(
      'AppCheck',
      'activation failed',
      error: e,
      stack: st,
    );
  }
}
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';
import 'utils/app_colors.dart';
import 'screens/splash_screen.dart';
import 'ui/home/widgets/home_screen_provider.dart';
import 'data/repositories/cafe_repository.dart';
// Push Notifications
import 'data/repositories/push_notification_repository.dart';
import 'utils/push_notification_handler.dart';
// NOVO - Analytics
import 'data/services/firebase_analytics_service.dart';
import 'data/repositories/analytics_repository.dart';
import 'utils/analytics_navigation_observer.dart';

// Global Navigator Key para navegação via push notifications
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// NOVO - Instância global do Analytics Repository
late AnalyticsRepository analyticsRepository;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase inicializado com sucesso!');
  } catch (e) {
    print('❌ Erro ao inicializar Firebase: $e');
  }

  await Supabase.initialize(
    url: 'https://mroljkgkiseuqlwlaibu.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1yb2xqa2draXNldXFsd2xhaWJ1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY3MDc3NzQsImV4cCI6MjA2MjI4Mzc3NH0.umy8tSCMmO1_goqX0TpO-coC2K6FXnwwZVQpqDDMrmw',
  );

  // NOVO - Inicializar Analytics
  await _initializeAnalytics();

  // Inicializar Push Notifications
  await _initializePushNotifications();

  print('🔍 Diagnóstico - kIsWeb: $kIsWeb');

  runApp(KafexApp());
}

// NOVO - Função para inicializar analytics
Future<void> _initializeAnalytics() async {
  try {
    print('📊 Inicializando Firebase Analytics...');

    // Criar instância do service
    final analyticsService = FirebaseAnalyticsService();

    // Criar instância do repository
    analyticsRepository = AnalyticsRepository(
      analyticsService: analyticsService,
    );

    // Inicializar
    await analyticsRepository.initialize();

    print('✅ Firebase Analytics inicializado com sucesso!');
  } catch (e) {
    print('❌ Erro ao inicializar Analytics: $e');
    // Não bloqueia a execução do app se analytics falharem
  }
}

// Função para inicializar push notifications
Future<void> _initializePushNotifications() async {
  try {
    print('🔔 Inicializando sistema de Push Notifications...');

    final repository = PushNotificationRepositoryImpl();
    final handler = PushNotificationHandler(
      repository: repository,
      navigatorKey: navigatorKey,
    );

    await handler.initialize();

    print('✅ Push Notifications inicializadas com sucesso!');
  } catch (e) {
    print('❌ Erro ao inicializar Push Notifications: $e');
    // Não bloqueia a execução do app se push notifications falharem
  }
}

class KafexApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget app = MultiProvider(
      providers: [
        Provider<CafeRepository>(
          create: (_) => CafeRepositoryImpl(),
        ),
        Provider<PushNotificationRepository>(
          create: (_) => PushNotificationRepositoryImpl(),
        ),
        // NOVO - Adicionar Analytics Repository ao Provider
        Provider<AnalyticsRepository>(
          create: (_) => analyticsRepository,
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Kafex',
        theme: AppTheme.lightTheme,
        home: SplashScreen(),
        debugShowCheckedModeBanner: false,
        routes: {
          '/home-test': (context) => const HomeScreenProvider(),
        },
        // NOVO - Adicionar Analytics Navigation Observer
        navigatorObservers: [
          AnalyticsNavigationObserver(
            analyticsRepository: analyticsRepository,
          ),
        ],
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                print('📏 Largura detectada: $width');

                if (kIsWeb && width > 600) {
                  print('✅ Aplicando centralização - Desktop detectado');
                  return Container(
                    color: const Color(0xFF333333),
                    child: Center(
                      child: Container(
                        width: 480,
                        constraints: BoxConstraints(
                          maxHeight: constraints.maxHeight,
                        ),
                        child: ClipRect(
                          child: child ?? const SizedBox(),
                        ),
                      ),
                    ),
                  );
                }

                print('📱 Layout mobile mantido');
                return child ?? const SizedBox();
              },
            ),
          );
        },
      ),
    );

    return app;
  }
}
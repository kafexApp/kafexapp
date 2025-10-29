// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uni_links/uni_links.dart'; // ✅ NOVO
import 'dart:async'; // ✅ NOVO
import 'firebase_options.dart';
import 'utils/app_colors.dart';
import 'config/app_routes.dart';

// Screens
import 'screens/splash_screen.dart';

// Repositories
import 'data/repositories/cafe_repository.dart';
import 'data/repositories/push_notification_repository.dart';
import 'data/repositories/analytics_repository.dart';

// Services
import 'data/services/firebase_analytics_service.dart';

// Utils
import 'utils/push_notification_handler.dart';
import 'utils/analytics_navigation_observer.dart';

// Global Navigator Key para navegação via push notifications
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Instância global do Analytics Repository
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

  // Inicializar Analytics
  await _initializeAnalytics();

  // Inicializar Push Notifications
  await _initializePushNotifications();

  print('🔍 Diagnóstico - kIsWeb: $kIsWeb');

  runApp(KafexApp());
}

/// Função para inicializar analytics
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

/// Função para inicializar push notifications
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

class KafexApp extends StatefulWidget {
  @override
  State<KafexApp> createState() => _KafexAppState();
}

class _KafexAppState extends State<KafexApp> {
  StreamSubscription? _deepLinkSubscription; // ✅ NOVO

  @override
  void initState() {
    super.initState();
    _initDeepLinks(); // ✅ NOVO
  }

  @override
  void dispose() {
    _deepLinkSubscription?.cancel(); // ✅ NOVO
    super.dispose();
  }

  // ✅ NOVO: Inicializar Deep Links
  Future<void> _initDeepLinks() async {
    // Tratar link inicial (app foi aberto por um deep link)
    try {
      final initialLink = await getInitialLink();
      if (initialLink != null) {
        print('🔗 Deep Link inicial: $initialLink');
        _handleDeepLink(initialLink);
      }
    } catch (e) {
      print('❌ Erro ao obter deep link inicial: $e');
    }

    // Escutar novos deep links (app já está aberto)
    _deepLinkSubscription = linkStream.listen((String? link) {
      if (link != null) {
        print('🔗 Deep Link recebido: $link');
        _handleDeepLink(link);
      }
    }, onError: (err) {
      print('❌ Erro no stream de deep links: $err');
    });
  }

  // ✅ NOVO: Processar Deep Link
  void _handleDeepLink(String link) {
    final uri = Uri.parse(link);
    
    print('📍 Path: ${uri.path}');
    print('📍 Query params: ${uri.queryParameters}');

    // Verificar se é link de verificação de email
    if (uri.path.contains('/verify-email')) {
      final token = uri.queryParameters['token'];
      
      if (token != null) {
        print('✅ Token de verificação encontrado: $token');
        
        // Navegar para página de verificação
        Future.delayed(const Duration(milliseconds: 500), () {
          navigatorKey.currentState?.pushNamed(
            AppRoutes.emailVerification,
            arguments: {'token': token},
          );
        });
      } else {
        print('⚠️ Token não encontrado no deep link');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<CafeRepository>(
          create: (_) => CafeRepositoryImpl(),
        ),
        Provider<PushNotificationRepository>(
          create: (_) => PushNotificationRepositoryImpl(),
        ),
        Provider<AnalyticsRepository>(
          create: (_) => analyticsRepository,
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Kafex',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        
        // ============================================
        // 📊 ANALYTICS OBSERVER
        // ============================================
        // Rastreia automaticamente TODAS as navegações
        navigatorObservers: [
          AnalyticsNavigationObserver(
            analyticsRepository: analyticsRepository,
          ),
        ],
        
        // ============================================
        // 🗺️ SISTEMA DE ROTAS CENTRALIZADO
        // ============================================
        // Rota inicial
        initialRoute: AppRoutes.splash,
        
        // Gerador de rotas centralizado
        onGenerateRoute: (settings) {
          print('🗺️ onGenerateRoute chamado para: ${settings.name}');
          
          // Tratamento especial para splash (rota inicial)
          if (settings.name == AppRoutes.splash || settings.name == '/') {
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => SplashScreen(),
            );
          }
          
          // Para todas as outras rotas, usa o AppRoutes
          return AppRoutes.onGenerateRoute(settings);
        },
        
        // ============================================
        // 📱 LAYOUT RESPONSIVO
        // ============================================
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                print('📏 Largura detectada: $width');

                // Layout desktop (Web)
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

                // Layout mobile
                print('📱 Layout mobile mantido');
                return child ?? const SizedBox();
              },
            ),
          );
        },
      ),
    );
  }
}
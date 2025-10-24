// lib/config/app_routes.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Screens - Authentication
import '../screens/welcome_screen.dart';
import '../screens/login_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../ui/create_account/widgets/create_account.dart';

// Screens - Main
import '../ui/home/widgets/home_screen_provider.dart';
import '../ui/cafe_explorer/widgets/cafe_explorer_screen.dart';
import '../ui/add_cafe/widgets/add_cafe_screen.dart';

// Screens - Profile & Settings
import '../ui/user_profile/widgets/user_profile_screen.dart';
import '../ui/user_profile/widgets/user_profile_provider.dart';
import '../ui/profile_settings/widgets/profile_settings_screen.dart';
import '../ui/profile_settings/viewmodel/profile_settings_viewmodel.dart';
import '../data/repositories/profile_settings_repository.dart';

// Screens - Notifications
import '../ui/notifications/widgets/notifications_screen.dart';

/// Configuração centralizada de todas as rotas do aplicativo Kafex
/// 
/// Este arquivo define:
/// - Nomes de rotas como constantes
/// - Gerador de rotas com validação de arguments
/// - Facilita navegação e tracking de analytics
class AppRoutes {
  // Impede instanciação desta classe
  AppRoutes._();

  // ==================== NOMES DAS ROTAS ====================
  
  // Autenticação
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String createAccount = '/create-account';
  static const String forgotPassword = '/forgot-password';
  static const String emailVerification = '/email-verification';
  static const String completeProfile = '/complete-profile';
  
  // Telas Principais (Bottom Navigation)
  static const String home = '/home';
  static const String homeFeed = '/home-feed';
  static const String cafeExplorer = '/cafe-explorer';
  static const String notifications = '/notifications';
  static const String userProfile = '/user-profile';
  
  // Configurações e Perfil
  static const String profileSettings = '/profile-settings';
  static const String editProfile = '/edit-profile';
  
  // Cafeterias
  static const String addCafe = '/add-cafe';
  static const String cafeDetails = '/cafe-details';
  
  // Posts
  static const String createPost = '/create-post';
  static const String postDetails = '/post-details';
  static const String postDetail = '/post-detail'; // Alias para compatibilidade
  
  // Outras
  static const String homeTest = '/home-test';

  // ==================== GERADOR DE ROTAS ====================
  
  /// Gerador de rotas centralizado
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    // Log da navegação para debug
    print('🗺️ Navegando para: ${settings.name}');
    if (settings.arguments != null) {
      print('   Arguments: ${settings.arguments}');
    }

    switch (settings.name) {
      // ===== AUTENTICAÇÃO =====
      case welcome:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => WelcomeScreen(),
        );

      case login:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => LoginScreen(),
        );

      case createAccount:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => CreateAccountScreen(),
        );

      case forgotPassword:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ForgotPasswordScreen(),
        );

      // ===== TELAS PRINCIPAIS =====
      case home:
      case homeFeed:
      case homeTest:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const HomeScreenProvider(),
        );

      case cafeExplorer:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => CafeExplorerScreen(),
        );

      case addCafe:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => AddCafeScreen(),
        );

      // ===== PERFIL E CONFIGURAÇÕES =====
      case userProfile:
        final args = settings.arguments as Map<String, dynamic>?;
        final userId = args?['userId'] as String?;
        final userName = args?['userName'] as String?;
        final userAvatar = args?['userAvatar'] as String?;

        if (userId == null || userId.isEmpty) {
          print('❌ userId não fornecido para userProfile');
          return _errorRoute(settings, 'userId obrigatório');
        }

        return MaterialPageRoute(
          settings: settings,
          builder: (_) => UserProfileProvider(
            userId: userId,
            userName: userName ?? '',
            userAvatar: userAvatar,
          ),
        );

      case profileSettings:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ChangeNotifierProvider(
            create: (_) => ProfileSettingsViewModel(
              repository: ProfileSettingsRepositoryImpl(),
            ),
            child: ProfileSettingsScreen(),
          ),
        );

      // ===== NOTIFICAÇÕES =====
      case notifications:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => NotificationsScreen(),
        );

      // ===== ROTA NÃO ENCONTRADA =====
      default:
        return _errorRoute(settings, 'Rota não encontrada: ${settings.name}');
    }
  }

  /// Rota de erro quando algo dá errado
  static MaterialPageRoute _errorRoute(RouteSettings settings, String message) {
    print('❌ Erro de navegação: $message');
    return MaterialPageRoute(
      settings: settings,
      builder: (context) => Scaffold(
        appBar: AppBar(title: Text('Erro')),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'Erro de Navegação',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Voltar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
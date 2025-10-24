// lib/utils/navigation_helper.dart
import 'package:flutter/material.dart';
import '../config/app_routes.dart';

/// Helper para facilitar navegação usando rotas nomeadas
/// 
/// Uso:
/// ```dart
/// NavigationHelper.navigateToHomeFeed(context);
/// NavigationHelper.navigateToNotifications(context);
/// ```
class NavigationHelper {
  // Impede instanciação
  NavigationHelper._();

  // ==================== MÉTODOS DE NAVEGAÇÃO ====================

  /// Navega para o Home Feed
  static Future<void> navigateToHomeFeed(BuildContext context) {
    return Navigator.pushNamed(context, AppRoutes.homeFeed);
  }

  /// Navega para Notificações
  static Future<void> navigateToNotifications(BuildContext context) {
    return Navigator.pushNamed(context, AppRoutes.notifications);
  }

  /// Navega para Explorador de Cafeterias
  static Future<void> navigateToCafeExplorer(BuildContext context) {
    return Navigator.pushNamed(context, AppRoutes.cafeExplorer);
  }

  /// Navega para Perfil do Usuário
  static Future<void> navigateToUserProfile(BuildContext context) {
    return Navigator.pushNamed(context, AppRoutes.userProfile);
  }

  /// Navega para Configurações de Perfil
  static Future<void> navigateToProfileSettings(BuildContext context) {
    return Navigator.pushNamed(context, AppRoutes.profileSettings);
  }

  /// Navega para Adicionar Cafeteria
  static Future<void> navigateToAddCafe(BuildContext context) {
    return Navigator.pushNamed(context, AppRoutes.addCafe);
  }

  /// Navega para Login
  static Future<void> navigateToLogin(BuildContext context) {
    return Navigator.pushNamed(context, AppRoutes.login);
  }

  /// Navega para Criar Conta
  static Future<void> navigateToCreateAccount(BuildContext context) {
    return Navigator.pushNamed(context, AppRoutes.createAccount);
  }

  /// Navega para Recuperar Senha
  static Future<void> navigateToForgotPassword(BuildContext context) {
    return Navigator.pushNamed(context, AppRoutes.forgotPassword);
  }

  /// Navega para Welcome Screen
  static Future<void> navigateToWelcome(BuildContext context) {
    return Navigator.pushNamed(context, AppRoutes.welcome);
  }

  // ==================== NAVEGAÇÃO COM REPLACE ====================

  /// Substitui a tela atual por Home Feed (sem volta)
  static Future<void> navigateToHomeFeedAndReplace(BuildContext context) {
    return Navigator.pushReplacementNamed(context, AppRoutes.homeFeed);
  }

  /// Substitui a tela atual por Login (sem volta)
  static Future<void> navigateToLoginAndReplace(BuildContext context) {
    return Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  /// Substitui a tela atual por Welcome (sem volta)
  static Future<void> navigateToWelcomeAndReplace(BuildContext context) {
    return Navigator.pushReplacementNamed(context, AppRoutes.welcome);
  }

  // ==================== NAVEGAÇÃO COM CLEAR ====================

  /// Remove todas as telas e vai para Home Feed
  static Future<void> navigateToHomeFeedAndClearStack(BuildContext context) {
    return Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.homeFeed,
      (route) => false,
    );
  }

  /// Remove todas as telas e vai para Login
  static Future<void> navigateToLoginAndClearStack(BuildContext context) {
    return Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  // ==================== NAVEGAÇÃO GENÉRICA ====================

  /// Navega para qualquer rota (use as constantes de AppRoutes)
  static Future<void> navigateTo(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed(
      context,
      routeName,
      arguments: arguments,
    );
  }

  /// Volta para a tela anterior
  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }

  /// Verifica se pode voltar
  static bool canGoBack(BuildContext context) {
    return Navigator.canPop(context);
  }
}
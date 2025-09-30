// lib/utils/user_manager.dart
// Classe simples para gerenciar dados do usuário logado

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_location.dart';
import 'dart:convert';

class UserManager extends ChangeNotifier {
  static UserManager? _instance;
  UserManager._internal();
  
  static UserManager get instance {
    _instance ??= UserManager._internal();
    return _instance!;
  }

  // Dados do usuário atual
  String? _userName;
  String? _userEmail;
  String? _userPhotoUrl;
  UserLocation? _userLocation;

  // Getters
  String get userName => _userName ?? 'Usuário Kafex';
  String get userEmail => _userEmail ?? 'usuario@kafex.com';
  String? get userPhotoUrl => _userPhotoUrl;
  UserLocation? get userLocation => _userLocation;

  // Setter para salvar dados do usuário
  void setUserData({
    required String name,
    required String email,
    String? photoUrl,
  }) {
    _userName = name;
    _userEmail = email;
    _userPhotoUrl = photoUrl;
    
    _saveUserToPrefs();
    notifyListeners();
    
    print('✅ Dados do usuário salvos: $name - $email');
    if (photoUrl != null) {
      print('📷 Foto do usuário: ${photoUrl.substring(0, photoUrl.length > 50 ? 50 : photoUrl.length)}...');
    }
  }

  // Setter para salvar localização do usuário
  void setUserLocation(UserLocation location) {
    _userLocation = location;
    _saveLocationToPrefs(location);
    notifyListeners();
    
    print('📍 Localização salva: ${location.displayLocation}');
  }

  // Carregar dados do usuário
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString('user_name');
    _userEmail = prefs.getString('user_email');
    _userPhotoUrl = prefs.getString('user_photo_url');
    
    // Carregar localização
    await loadUserLocation();
    
    notifyListeners();
  }

  // Carregar localização do usuário
  Future<void> loadUserLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final locationData = prefs.getString('user_location');
    
    if (locationData != null) {
      try {
        final locationJson = json.decode(locationData);
        _userLocation = UserLocation.fromJson(locationJson);
      } catch (e) {
        print('Erro ao carregar localização: $e');
      }
    }
  }

  // Salvar dados do usuário no SharedPreferences
  Future<void> _saveUserToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (_userName != null) await prefs.setString('user_name', _userName!);
    if (_userEmail != null) await prefs.setString('user_email', _userEmail!);
    if (_userPhotoUrl != null) await prefs.setString('user_photo_url', _userPhotoUrl!);
  }

  // Salvar localização no SharedPreferences
  Future<void> _saveLocationToPrefs(UserLocation location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_location', json.encode(location.toJson()));
  }

  // Remover dados do usuário do SharedPreferences
  Future<void> _removeUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_photo_url');
  }

  // Remover localização do SharedPreferences
  Future<void> _removeLocationFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_location');
  }

  // Método para extrair nome do email
  String extractNameFromEmail(String email) {
    if (email.contains('@')) {
      String emailPrefix = email.split('@')[0];
      
      // Se tem pontos ou underscores, separa e capitaliza
      if (emailPrefix.contains('.') || emailPrefix.contains('_')) {
        return emailPrefix
            .replaceAll('_', '.')
            .split('.')
            .map((word) => word.isNotEmpty 
                ? word[0].toUpperCase() + word.substring(1).toLowerCase() 
                : '')
            .join(' ')
            .trim();
      } else {
        // Apenas capitaliza a primeira letra
        return emailPrefix.isNotEmpty 
            ? emailPrefix[0].toUpperCase() + emailPrefix.substring(1).toLowerCase()
            : 'Usuário Kafex';
      }
    }
    return 'Usuário Kafex';
  }

  // Limpar dados do usuário (logout)
  void clearUserData() {
    _userName = null;
    _userEmail = null;
    _userPhotoUrl = null;
    _userLocation = null;
    
    _removeUserFromPrefs();
    _removeLocationFromPrefs();
    notifyListeners();
    
    print('🚪 Dados do usuário limpos');
  }

  // Limpar apenas localização
  void clearUserLocation() {
    _userLocation = null;
    _removeLocationFromPrefs();
    notifyListeners();
    
    print('📍 Localização removida');
  }

  // Verificar se há usuário logado
  bool get hasUser => _userName != null && _userEmail != null;

  // Verificar se há localização
  bool get hasLocation => _userLocation != null;

  // Obter localização formatada
  String get locationDisplay {
    return _userLocation?.displayLocation ?? 'Localização não disponível';
  }
}
// lib/services/username_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';

class UsernameService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Verificar se username está disponível
  static Future<bool> isUsernameAvailable(String username) async {
    try {
      final response = await _supabase
          .from('usuario_perfil')
          .select('nome_usuario')
          .eq('nome_usuario', username.toLowerCase())
          .maybeSingle();

      print('🔍 Verificando username: ${username.toLowerCase()}');
      print('📊 Resultado da busca: $response');

      return response == null; // Retorna true se não encontrou (disponível)
    } catch (e) {
      print('❌ Erro ao verificar username: $e');
      return false;
    }
  }

  // Gerar username base a partir do nome
  static String generateBaseUsername(String fullName) {
    // Remove acentos e caracteres especiais
    String normalized = _removeAccents(fullName.toLowerCase());
    
    // Remove espaços e caracteres não alfanuméricos
    String username = normalized.replaceAll(RegExp(r'[^a-z0-9]'), '');
    
    // Limita a 20 caracteres
    if (username.length > 20) {
      username = username.substring(0, 20);
    }
    
    return username;
  }

  // Gerar 5 sugestões de username disponíveis
  static Future<List<String>> generateUsernameSuggestions(String fullName) async {
    if (fullName.trim().isEmpty) return [];

    List<String> suggestions = [];
    String baseUsername = generateBaseUsername(fullName);

    // Tenta o username base primeiro
    if (await isUsernameAvailable(baseUsername)) {
      suggestions.add(baseUsername);
    }

    // Gera variações até ter 5 sugestões
    int attempts = 0;
    while (suggestions.length < 5 && attempts < 20) {
      String variant = _generateVariant(baseUsername, attempts);
      
      if (!suggestions.contains(variant) && await isUsernameAvailable(variant)) {
        suggestions.add(variant);
      }
      
      attempts++;
    }

    return suggestions;
  }

  // Gerar variação de username
  static String _generateVariant(String base, int attempt) {
    Random random = Random();
    
    switch (attempt % 4) {
      case 0:
        // Adiciona números aleatórios
        int number = random.nextInt(9999);
        return '$base$number';
      
      case 1:
        // Adiciona underscore e números
        int number = random.nextInt(999);
        return '${base}_$number';
      
      case 2:
        // Adiciona palavras curtas
        List<String> words = ['app', 'user', 'pro', 'oficial', 'real'];
        String word = words[random.nextInt(words.length)];
        return '$base$word';
      
      case 3:
        // Combina letras do nome de forma diferente
        if (base.length > 3) {
          int number = random.nextInt(99);
          return '${base.substring(0, 3)}$number${base.substring(3)}';
        }
        return '${base}${random.nextInt(999)}';
      
      default:
        return '$base${random.nextInt(9999)}';
    }
  }

  // Remove acentos
  static String _removeAccents(String text) {
    const withAccents = 'áàãâäéèêëíìîïóòõôöúùûüçñÁÀÃÂÄÉÈÊËÍÌÎÏÓÒÕÔÖÚÙÛÜÇÑ';
    const withoutAccents = 'aaaaaeeeeiiiiooooouuuucnAAAAAEEEEIIIIOOOOOUUUUCN';
    
    String result = text;
    for (int i = 0; i < withAccents.length; i++) {
      result = result.replaceAll(withAccents[i], withoutAccents[i]);
    }
    return result;
  }
}
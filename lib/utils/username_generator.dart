// lib/utils/username_generator.dart

import '../backend/supabase/supabase.dart';

class UsernameGenerator {
  static final _supabase = SupaClient.client;

  /// Gera um username único baseado no nome do usuário
  /// Retorna um username válido e disponível no Supabase
  static Future<String> generateUniqueUsername(String fullName) async {
    try {
      // 1. Sanitizar e gerar username base
      String baseUsername = _sanitizeName(fullName);
      
      if (baseUsername.isEmpty) {
        baseUsername = 'usuario';
      }

      print('🔍 Gerando username a partir de: $fullName -> $baseUsername');

      // 2. Verificar se o username base está disponível
      bool isAvailable = await _checkUsernameAvailability(baseUsername);
      
      if (isAvailable) {
        print('✅ Username disponível: $baseUsername');
        return baseUsername;
      }

      // 3. Se não estiver disponível, adicionar números sequenciais
      String finalUsername = await _generateWithNumber(baseUsername);
      print('✅ Username gerado com sucesso: $finalUsername');
      
      return finalUsername;
    } catch (e) {
      print('❌ Erro ao gerar username: $e');
      // Fallback: gerar username aleatório
      return _generateRandomUsername();
    }
  }

  /// Sanitiza o nome removendo caracteres especiais e espaços
  static String _sanitizeName(String name) {
    // Remover acentos e caracteres especiais
    String sanitized = name.toLowerCase().trim();
    
    // Mapa de caracteres acentuados para não acentuados
    const Map<String, String> accentMap = {
      'á': 'a', 'à': 'a', 'ã': 'a', 'â': 'a', 'ä': 'a',
      'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
      'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
      'ó': 'o', 'ò': 'o', 'õ': 'o', 'ô': 'o', 'ö': 'o',
      'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
      'ç': 'c', 'ñ': 'n',
    };

    accentMap.forEach((key, value) {
      sanitized = sanitized.replaceAll(key, value);
    });

    // Remover espaços e caracteres especiais, manter apenas letras e números
    sanitized = sanitized.replaceAll(RegExp(r'[^a-z0-9]'), '');

    // Pegar apenas o primeiro nome se tiver múltiplas palavras
    if (sanitized.length > 15) {
      sanitized = sanitized.substring(0, 15);
    }

    return sanitized;
  }

  /// Verifica se o username está disponível no Supabase
  static Future<bool> _checkUsernameAvailability(String username) async {
    try {
      final response = await _supabase
          .from('usuario_perfil')
          .select('nome_usuario')
          .eq('nome_usuario', username)
          .maybeSingle();

      // Se não encontrou nenhum registro, o username está disponível
      return response == null;
    } catch (e) {
      print('❌ Erro ao verificar disponibilidade do username: $e');
      return false;
    }
  }

  /// Gera username com número sequencial até encontrar um disponível
  static Future<String> _generateWithNumber(String baseUsername) async {
    int counter = 1;
    String candidateUsername = baseUsername;

    // Tentar até 100 variações
    while (counter <= 100) {
      candidateUsername = '$baseUsername$counter';
      
      bool isAvailable = await _checkUsernameAvailability(candidateUsername);
      
      if (isAvailable) {
        return candidateUsername;
      }
      
      counter++;
    }

    // Se não encontrou em 100 tentativas, gerar username aleatório
    return _generateRandomUsername();
  }

  /// Gera um username aleatório como último recurso
  static String _generateRandomUsername() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'usuario_$timestamp';
  }

  /// Valida se um username tem formato válido
  static bool isValidUsername(String username) {
    // Username deve ter entre 3 e 20 caracteres
    if (username.length < 3 || username.length > 20) {
      return false;
    }

    // Deve conter apenas letras minúsculas, números e underscore
    final validFormat = RegExp(r'^[a-z0-9_]+$');
    if (!validFormat.hasMatch(username)) {
      return false;
    }

    // Não pode começar com número
    if (RegExp(r'^[0-9]').hasMatch(username)) {
      return false;
    }

    return true;
  }

  /// Sugere usernames alternativos baseados no nome
  static Future<List<String>> suggestAlternativeUsernames(String fullName) async {
    List<String> suggestions = [];
    String baseName = _sanitizeName(fullName);

    try {
      // Sugestão 1: Nome completo sanitizado
      if (baseName.isNotEmpty && await _checkUsernameAvailability(baseName)) {
        suggestions.add(baseName);
      }

      // Sugestão 2: Nome + número aleatório
      final random = DateTime.now().millisecondsSinceEpoch % 1000;
      String suggestion2 = '$baseName$random';
      if (await _checkUsernameAvailability(suggestion2)) {
        suggestions.add(suggestion2);
      }

      // Sugestão 3: Nome + "kafex"
      String suggestion3 = '${baseName}kafex';
      if (await _checkUsernameAvailability(suggestion3)) {
        suggestions.add(suggestion3);
      }

      // Sugestão 4: Primeiras letras + número
      if (baseName.length >= 3) {
        String suggestion4 = '${baseName.substring(0, 3)}${random}';
        if (await _checkUsernameAvailability(suggestion4)) {
          suggestions.add(suggestion4);
        }
      }

      return suggestions.take(3).toList(); // Retornar no máximo 3 sugestões
    } catch (e) {
      print('❌ Erro ao gerar sugestões: $e');
      return suggestions;
    }
  }
}
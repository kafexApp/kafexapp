// ============================================
// KAFEX ANALYTICS - Helper Functions
// Caminho: lib/utils/analytics_helper.dart
// Data: 18/10/2025
// ============================================

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Classe com funções auxiliares para analytics.
class AnalyticsHelper {
  
  /// Retorna o nome da plataforma atual.
  /// 
  /// Retorna: 'android', 'ios' ou 'web'
  static String getCurrentPlatform() {
    if (kIsWeb) {
      return 'web';
    } else if (Platform.isAndroid) {
      return 'android';
    } else if (Platform.isIOS) {
      return 'ios';
    } else {
      return 'unknown';
    }
  }
  
  /// Sanitiza o nome de um evento para ser aceito pelo Firebase Analytics.
  /// 
  /// Firebase tem regras:
  /// - Máximo 40 caracteres
  /// - Apenas letras, números e underscore
  /// - Não pode começar com número
  /// 
  /// Exemplo: "Café Detail!" -> "cafe_detail"
  static String sanitizeEventName(String eventName) {
    // Remove acentos e caracteres especiais
    String sanitized = _removeAccents(eventName);
    
    // Converte para lowercase
    sanitized = sanitized.toLowerCase();
    
    // Remove caracteres não permitidos
    sanitized = sanitized.replaceAll(RegExp(r'[^a-z0-9_]'), '_');
    
    // Remove underscores consecutivos
    sanitized = sanitized.replaceAll(RegExp(r'_+'), '_');
    
    // Remove underscore do início e fim
    sanitized = sanitized.replaceAll(RegExp(r'^_+|_+$'), '');
    
    // Se começar com número, adiciona underscore
    if (RegExp(r'^\d').hasMatch(sanitized)) {
      sanitized = '_$sanitized';
    }
    
    // Limita a 40 caracteres
    if (sanitized.length > 40) {
      sanitized = sanitized.substring(0, 40);
    }
    
    return sanitized;
  }
  
  /// Sanitiza o nome de um parâmetro.
  /// 
  /// Mesmas regras do evento, mas máximo 40 caracteres.
  static String sanitizeParameterName(String paramName) {
    return sanitizeEventName(paramName);
  }
  
  /// Remove acentos de uma string.
  static String _removeAccents(String text) {
    const withAccents = 'àáâãäåèéêëìíîïòóôõöùúûüçñÀÁÂÃÄÅÈÉÊËÌÍÎÏÒÓÔÕÖÙÚÛÜÇÑ';
    const withoutAccents = 'aaaaaaeeeeiiiiooooouuuucnAAAAAEEEEIIIIOOOOOUUUUCN';
    
    String result = text;
    for (int i = 0; i < withAccents.length; i++) {
      result = result.replaceAll(withAccents[i], withoutAccents[i]);
    }
    return result;
  }
  
  /// Trunca uma string para o tamanho máximo permitido pelo Firebase.
  /// 
  /// Firebase Analytics: máximo 100 caracteres por valor de parâmetro
  static String truncateValue(String value, {int maxLength = 100}) {
    if (value.length <= maxLength) {
      return value;
    }
    return value.substring(0, maxLength);
  }
  
  /// Converte uma lista em string CSV para analytics.
  /// 
  /// Firebase não aceita List diretamente, então convertemos para String.
  static String listToString(List<dynamic> list) {
    return list.join(',');
  }
  
  /// Converte bool para int (Firebase não aceita bool diretamente).
  static int boolToInt(bool value) {
    return value ? 1 : 0;
  }
  
  /// Valida se um mapa de parâmetros é válido para Firebase Analytics.
  /// 
  /// Regras:
  /// - Máximo 25 parâmetros por evento
  /// - Chaves: máximo 40 caracteres
  /// - Valores string: máximo 100 caracteres
  /// 
  /// Retorna: Map com apenas os parâmetros válidos
  static Map<String, dynamic> validateParameters(Map<String, dynamic> parameters) {
    final validated = <String, dynamic>{};
    int count = 0;
    
    for (var entry in parameters.entries) {
      // Máximo 25 parâmetros
      if (count >= 25) break;
      
      // Sanitiza o nome do parâmetro
      final key = sanitizeParameterName(entry.key);
      
      // Valida o valor
      final value = entry.value;
      if (value == null) continue;
      
      if (value is String) {
        validated[key] = truncateValue(value);
      } else if (value is int || value is double) {
        validated[key] = value;
      } else if (value is bool) {
        validated[key] = boolToInt(value);
      } else if (value is List) {
        validated[key] = listToString(value);
      } else {
        // Para outros tipos, converte para string
        validated[key] = truncateValue(value.toString());
      }
      
      count++;
    }
    
    return validated;
  }
  
  /// Formata um timestamp para analytics.
  static String formatTimestamp(DateTime dateTime) {
    return dateTime.toIso8601String();
  }
  
  /// Gera um ID de sessão único.
  /// 
  /// Útil para agrupar eventos da mesma sessão.
  static String generateSessionId() {
    final now = DateTime.now();
    return '${now.millisecondsSinceEpoch}_${now.hashCode}';
  }
}
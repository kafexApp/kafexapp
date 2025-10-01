// lib/ui/cafe_detail/services/cafe_actions_service.dart

import 'package:url_launcher/url_launcher.dart';
import '../models/cafe_detail_model.dart';

class CafeActionsService {
  
  /// Abre o Instagram da cafeteria
  static Future<void> openInstagram(String instagramHandle) async {
    try {
      final String instagramUrl = 'https://instagram.com/${instagramHandle.replaceAll('@', '')}';
      await launchUrl(Uri.parse(instagramUrl));
    } catch (e) {
      print('Erro ao abrir Instagram: $e');
    }
  }

  /// Abre o mapa com a localização da cafeteria
  static Future<void> openInMaps(double latitude, double longitude) async {
    try {
      final String googleMapsUrl = 
          'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
      await launchUrl(Uri.parse(googleMapsUrl));
    } catch (e) {
      print('Erro ao abrir mapa: $e');
    }
  }

  /// Compartilha informações da cafeteria
  static String generateShareText(CafeDetailModel cafe) {
    return 'Olá, segue o endereço da cafeteria ${cafe.name}, ${cafe.address}. '
           'Quer conhecer mais cafeterias? Baixe o Kafex em kafex.com.br.';
  }

  /// Valida se pode abrir URLs externas
  static Future<bool> canLaunchExternalUrl(String url) async {
    try {
      return await canLaunchUrl(Uri.parse(url));
    } catch (e) {
      return false;
    }
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'dart:io';

class AvatarService {
  static final _storage = FirebaseStorage.instance;

  /// Faz upload do avatar para o Firebase Storage
  static Future<String?> uploadAvatar({
    required String userId,
    required String imagePath,
    List<int>? imageBytes,
  }) async {
    try {
      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = _storage.ref().child('avatars/$fileName');

      print('📸 Iniciando upload do avatar...');

      UploadTask uploadTask;

      if (kIsWeb) {
        // Web: usar bytes
        if (imageBytes == null) {
          print('❌ Bytes da imagem não fornecidos para web');
          return null;
        }
        uploadTask = storageRef.putData(
          Uint8List.fromList(imageBytes),
          SettableMetadata(contentType: 'image/jpeg'),
        );
      } else {
        // Mobile/Desktop: usar arquivo
        final file = File(imagePath);
        uploadTask = storageRef.putFile(file);
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      print('✅ Upload concluído: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('❌ Erro ao fazer upload do avatar: $e');
      return null;
    }
  }

  /// Deleta o avatar antigo do Firebase Storage
  static Future<void> deleteAvatar(String photoUrl) async {
    try {
      if (photoUrl.isEmpty || !photoUrl.contains('firebase')) return;
      
      final ref = _storage.refFromURL(photoUrl);
      await ref.delete();
      
      print('🗑️ Avatar antigo deletado');
    } catch (e) {
      print('⚠️ Erro ao deletar avatar antigo: $e');
    }
  }

  /// Otimiza URLs de avatar baseado no provider
  static String? optimizePhotoUrl(String? url, {int size = 200}) {
    if (url == null || url.isEmpty) return null;
    
    // Google Photos/Drive
    if (url.contains('googleusercontent.com')) {
      final baseUrl = url.split('=')[0];
      return '$baseUrl=s$size-c';
    }
    
    // Facebook/Meta
    if (url.contains('facebook.com') || url.contains('fbcdn.net')) {
      return '$url?width=$size&height=$size';
    }
    
    // GitHub
    if (url.contains('avatars.githubusercontent.com')) {
      return '$url?s=$size';
    }
    
    // URL genérica - retorna como está
    return url;
  }

  /// Gera iniciais do nome do usuário
  static String generateInitials(String? fullName) {
    if (fullName == null || fullName.isEmpty) return 'U';
    
    final nameParts = fullName.trim().split(' ');
    if (nameParts.length == 1) {
      return nameParts[0].substring(0, 1).toUpperCase();
    }
    
    final firstInitial = nameParts.first.substring(0, 1);
    final lastInitial = nameParts.last.substring(0, 1);
    return (firstInitial + lastInitial).toUpperCase();
  }

  /// Gera cor do avatar baseada no nome
  static Color generateAvatarColor(String? name) {
    if (name == null || name.isEmpty) return const Color(0xFFE57373);
    
    const colors = [
      Color(0xFFE57373), // Red
      Color(0xFF81C784), // Green  
      Color(0xFF64B5F6), // Blue
      Color(0xFFBA68C8), // Purple
      Color(0xFFFFB74D), // Orange
      Color(0xFF4DD0E1), // Cyan
      Color(0xFFF06292), // Pink
      Color(0xFFAED581), // Light Green
    ];
    
    final index = name.codeUnitAt(0) % colors.length;
    return colors[index];
  }
}
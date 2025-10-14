// lib/services/firebase_storage_service.dart
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import '../utils/user_manager.dart';

class FirebaseStorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload de imagem para o Firebase Storage
  static Future<String?> uploadImageFromXFile(XFile imageFile) async {
    try {
      print('📷 Iniciando upload de imagem...');
      
      // Verifica se o Firebase está inicializado
      if (!Firebase.apps.isNotEmpty) {
        print('❌ Firebase não está inicializado');
        return null;
      }
      
      final userManager = UserManager.instance;
      final userUid = userManager.userEmail ?? 'anonymous';
      
      print('👤 Usuário: $userUid');
      
      // Gera nome único para o arquivo
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'posts/images/${userUid.replaceAll('@', '_').replaceAll('.', '_')}_${timestamp}.jpg';
      
      print('📁 Nome do arquivo: $fileName');
      
      // Referência no Firebase Storage
      final ref = _storage.ref().child(fileName);
      
      // Executa upload baseado na plataforma
      UploadTask uploadTask;
      
      if (kIsWeb) {
        print('🌐 Upload Web iniciado...');
        // Upload para Web
        final bytes = await imageFile.readAsBytes();
        print('📏 Tamanho do arquivo: ${bytes.length} bytes');
        
        uploadTask = ref.putData(
          bytes,
          SettableMetadata(
            contentType: 'image/jpeg',
            customMetadata: {
              'uploadedBy': userUid,
              'uploadTimestamp': timestamp.toString(),
            },
          ),
        );
      } else {
        print('📱 Upload Mobile iniciado...');
        // Upload para Mobile
        final file = File(imageFile.path);
        print('📏 Arquivo: ${file.path}');
        
        uploadTask = ref.putFile(
          file,
          SettableMetadata(
            contentType: 'image/jpeg',
            customMetadata: {
              'uploadedBy': userUid,
              'uploadTimestamp': timestamp.toString(),
            },
          ),
        );
      }
      
      print('⏳ Aguardando conclusão do upload...');
      
      // Aguarda conclusão do upload
      final snapshot = await uploadTask;
      
      print('📊 Estado do upload: ${snapshot.state}');
      
      if (snapshot.state == TaskState.success) {
        // Obtém URL de download
        final downloadUrl = await snapshot.ref.getDownloadURL();
        print('✅ Upload de imagem concluído: $downloadUrl');
        return downloadUrl;
      } else {
        print('❌ Erro no upload da imagem: ${snapshot.state}');
        return null;
      }
      
    } catch (e, stackTrace) {
      print('❌ Erro ao fazer upload da imagem: $e');
      print('📍 Stack trace: $stackTrace');
      return null;
    }
  }

  /// Upload de vídeo para o Firebase Storage
  static Future<String?> uploadVideoFromXFile(XFile videoFile) async {
    try {
      print('🎥 Iniciando upload de vídeo...');
      
      final userManager = UserManager.instance;
      final userUid = userManager.userEmail ?? 'anonymous';
      
      // Gera nome único para o arquivo
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'posts/videos/${userUid}_${timestamp}.mp4';
      
      // Referência no Firebase Storage
      final ref = _storage.ref().child(fileName);
      
      // Executa upload baseado na plataforma
      UploadTask uploadTask;
      
      if (kIsWeb) {
        // Upload para Web
        final bytes = await videoFile.readAsBytes();
        uploadTask = ref.putData(
          bytes,
          SettableMetadata(
            contentType: 'video/mp4',
            customMetadata: {
              'uploadedBy': userUid,
              'uploadTimestamp': timestamp.toString(),
            },
          ),
        );
      } else {
        // Upload para Mobile
        final file = File(videoFile.path);
        uploadTask = ref.putFile(
          file,
          SettableMetadata(
            contentType: 'video/mp4',
            customMetadata: {
              'uploadedBy': userUid,
              'uploadTimestamp': timestamp.toString(),
            },
          ),
        );
      }
      
      // Aguarda conclusão do upload
      final snapshot = await uploadTask;
      
      if (snapshot.state == TaskState.success) {
        // Obtém URL de download
        final downloadUrl = await snapshot.ref.getDownloadURL();
        print('✅ Upload de vídeo concluído: $downloadUrl');
        return downloadUrl;
      } else {
        print('❌ Erro no upload do vídeo: ${snapshot.state}');
        return null;
      }
      
    } catch (e) {
      print('❌ Erro ao fazer upload do vídeo: $e');
      return null;
    }
  }

  /// Deleta um arquivo do Firebase Storage (para cleanup)
  static Future<bool> deleteFile(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
      print('🗑️ Arquivo deletado com sucesso: $downloadUrl');
      return true;
    } catch (e) {
      print('❌ Erro ao deletar arquivo: $e');
      return false;
    }
  }

  /// Verifica se um arquivo existe no Storage
  static Future<bool> fileExists(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.getMetadata();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Obtém metadados de um arquivo
  static Future<FullMetadata?> getFileMetadata(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      return await ref.getMetadata();
    } catch (e) {
      print('❌ Erro ao obter metadados: $e');
      return null;
    }
  }
}
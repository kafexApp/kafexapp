// lib/data/repositories/cafe_submission_repository.dart
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../models/domain/cafe_submission.dart';
import '../services/supabase_cafeteria_service.dart';
import '../../services/user_profile_service.dart';
import '../../utils/result.dart';

/// Interface abstrata para submissão de cafeterias
abstract class CafeSubmissionRepository {
  Future<Result<int>> submitCafe(CafeSubmission submission, dynamic customPhoto);
}

/// Implementação REAL do repositório de submissão usando Supabase + Firebase
class CafeSubmissionRepositoryImpl implements CafeSubmissionRepository {
  final SupabaseCafeteriaService _cafeteriaService;
  final FirebaseAuth _firebaseAuth;
  final FirebaseStorage _firebaseStorage;

  CafeSubmissionRepositoryImpl({
    SupabaseCafeteriaService? cafeteriaService,
    FirebaseAuth? firebaseAuth,
    FirebaseStorage? firebaseStorage,
  })  : _cafeteriaService = cafeteriaService ?? SupabaseCafeteriaService(),
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firebaseStorage = firebaseStorage ?? FirebaseStorage.instance;

  @override
  Future<Result<int>> submitCafe(
    CafeSubmission submission,
    dynamic customPhoto,
  ) async {
    try {
      print('📤 Iniciando submissão de cafeteria: ${submission.name}');

      // 1. Verificar se usuário está autenticado
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        return Result.error(
          Exception('Usuário não autenticado'),
        );
      }

      final usuarioUid = currentUser.uid;
      print('👤 Usuário autenticado: $usuarioUid');

      // 2. Obter user_id do Supabase
      final userId = await _getUserIdFromSupabase(usuarioUid);

      // 3. Upload da foto (se fornecida)
      String? urlFoto = submission.photoUrl;
      if (customPhoto != null) {
        print('📸 Fazendo upload da foto...');
        
        if (customPhoto is XFile) {
          final uploadResult = await _uploadPhotoFromXFile(
            customPhoto,
            usuarioUid,
            submission.name,
          );

          if (uploadResult.isError) {
            return Result.error(uploadResult.asError.error);
          }

          urlFoto = uploadResult.asOk.value;
        } else if (customPhoto is File) {
          final uploadResult = await _uploadPhoto(
            customPhoto,
            usuarioUid,
            submission.name,
          );

          if (uploadResult.isError) {
            return Result.error(uploadResult.asError.error);
          }

          urlFoto = uploadResult.asOk.value;
        }
        
        print('✅ Foto enviada: $urlFoto');
      }

      // 4. Usar componentes segmentados do endereço (vindos do Google Places)
      print('📍 Componentes do endereço:');
      print('   Rua: ${submission.street}');
      print('   Número: ${submission.streetNumber}');
      print('   Bairro: ${submission.neighborhood}');
      print('   Cidade: ${submission.city}');
      print('   Estado: ${submission.state}');
      print('   País: ${submission.country}');

      // Montar endereço completo se não vier preenchido
      String fullAddress = submission.address;
      if (fullAddress.isEmpty && submission.street != null) {
        final parts = <String>[];
        
        if (submission.street != null) {
          String streetPart = submission.street!;
          if (submission.streetNumber != null) {
            streetPart += ', ${submission.streetNumber}';
          }
          parts.add(streetPart);
        }
        
        if (submission.neighborhood != null) {
          parts.add(submission.neighborhood!);
        }
        
        if (submission.city != null) {
          if (submission.state != null) {
            parts.add('${submission.city} - ${submission.state}');
          } else {
            parts.add(submission.city!);
          }
        }
        
        if (submission.country != null) {
          parts.add(submission.country!);
        }
        
        fullAddress = parts.join(', ');
      }

      // 5. Criar cafeteria no Supabase
      print('💾 Salvando cafeteria no Supabase...');
      final cafeteriaId = await _cafeteriaService.createCafeteria(
        nome: submission.name,
        endereco: fullAddress,
        latitude: submission.latitude ?? 0.0,
        longitude: submission.longitude ?? 0.0,
        usuarioUid: usuarioUid,
        userId: userId,
        telefone: submission.phone,
        instagram: submission.website,
        urlFoto: urlFoto,
        bairro: submission.neighborhood,
        cidade: submission.city,
        estado: submission.state,
        pais: submission.country,
        petFriendly: submission.isPetFriendly,
        opcaoVegana: submission.isVegFriendly,
        officeFriendly: submission.isOfficeFriendly,
      );

      if (cafeteriaId == null) {
        return Result.error(
          Exception('Falha ao criar cafeteria - ID não retornado'),
        );
      }

      print('✅ Cafeteria criada com sucesso! ID: $cafeteriaId');
      return Result.ok(cafeteriaId);
    } catch (e, stackTrace) {
      print('❌ Erro ao submeter cafeteria: $e');
      print('Stack trace: $stackTrace');
      return Result.error(Exception('Erro ao enviar cafeteria: $e'));
    }
  }

  /// Upload de foto a partir de XFile (funciona em web e mobile)
  Future<Result<String>> _uploadPhotoFromXFile(
    XFile photo,
    String usuarioUid,
    String cafeName,
  ) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName =
          'cafeterias/$usuarioUid/${timestamp}_${_sanitizeFileName(cafeName)}.jpg';

      print('📤 Fazendo upload: $fileName');

      final storageRef = _firebaseStorage.ref().child(fileName);

      if (kIsWeb) {
        final bytes = await photo.readAsBytes();
        final uploadTask = await storageRef.putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        final downloadUrl = await uploadTask.ref.getDownloadURL();
        print('✅ Upload concluído (web): $downloadUrl');
        return Result.ok(downloadUrl);
      } else {
        final file = File(photo.path);
        final uploadTask = await storageRef.putFile(file);
        final downloadUrl = await uploadTask.ref.getDownloadURL();
        print('✅ Upload concluído (mobile): $downloadUrl');
        return Result.ok(downloadUrl);
      }
    } catch (e) {
      print('❌ Erro no upload da foto: $e');
      return Result.error(Exception('Erro ao fazer upload da foto: $e'));
    }
  }

  /// Upload de foto a partir de File (legacy - apenas mobile)
  Future<Result<String>> _uploadPhoto(
    File photo,
    String usuarioUid,
    String cafeName,
  ) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName =
          'cafeterias/$usuarioUid/${timestamp}_${_sanitizeFileName(cafeName)}.jpg';

      print('📤 Fazendo upload: $fileName');

      final storageRef = _firebaseStorage.ref().child(fileName);
      final uploadTask = await storageRef.putFile(photo);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      print('✅ Upload concluído: $downloadUrl');
      return Result.ok(downloadUrl);
    } catch (e) {
      print('❌ Erro no upload da foto: $e');
      return Result.error(Exception('Erro ao fazer upload da foto: $e'));
    }
  }

  /// Busca o ID do usuário no Supabase
  Future<int> _getUserIdFromSupabase(String firebaseUid) async {
    try {
      print('🔍 Buscando user_id do Supabase...');
      
      final profile = await UserProfileService.getUserProfile(firebaseUid);
      
      if (profile == null) {
        print('⚠️ Perfil não encontrado, usando 0 como fallback');
        return 0;
      }
      
      final userId = profile.id;
      print('✅ user_id encontrado: $userId');
      return userId ?? 0;
    } catch (e) {
      print('❌ Erro ao buscar user_id: $e');
      return 0;
    }
  }

  /// Remove caracteres especiais do nome do arquivo
  String _sanitizeFileName(String fileName) {
    return fileName
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
  }
}
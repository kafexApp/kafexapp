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

      // 3. Upload da foto (se fornecida) - suporte para web e mobile
      String? urlFoto = submission.photoUrl;
      if (customPhoto != null) {
        print('📸 Fazendo upload da foto...');
        
        // Aceita tanto File quanto XFile
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

      // 4. Parsear endereço
      final addressParts = _parseAddress(submission.address);

      // 5. Criar cafeteria no Supabase
      print('💾 Salvando cafeteria no Supabase...');
      final cafeteriaId = await _cafeteriaService.createCafeteria(
        nome: submission.name,
        endereco: submission.address,
        latitude: submission.latitude ?? 0.0,
        longitude: submission.longitude ?? 0.0,
        usuarioUid: usuarioUid,
        userId: userId,
        telefone: submission.phone,
        instagram: submission.website,
        urlFoto: urlFoto,
        bairro: addressParts['bairro'],
        cidade: addressParts['cidade'],
        estado: addressParts['estado'],
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

      // Upload diferente para web e mobile
      if (kIsWeb) {
        // WEB: usar putData com bytes
        final bytes = await photo.readAsBytes();
        final uploadTask = await storageRef.putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        final downloadUrl = await uploadTask.ref.getDownloadURL();
        print('✅ Upload concluído (web): $downloadUrl');
        return Result.ok(downloadUrl);
      } else {
        // MOBILE: usar putFile
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

  /// Parse do endereço
  Map<String, String?> _parseAddress(String address) {
    try {
      String? estado;
      String? cidade;
      String? bairro;

      final estadoRegex = RegExp(r',\s*([A-Z]{2})(?:,|\s|$)');
      final estadoMatch = estadoRegex.firstMatch(address);
      if (estadoMatch != null) {
        estado = estadoMatch.group(1);
      }

      final cidadeRegex = RegExp(r',\s*([^,]+?)\s*-\s*[A-Z]{2}');
      final cidadeMatch = cidadeRegex.firstMatch(address);
      if (cidadeMatch != null) {
        cidade = cidadeMatch.group(1)?.trim();
      }

      final bairroRegex = RegExp(r'-\s*([^,]+?)(?:,|$)');
      final bairroMatch = bairroRegex.firstMatch(address);
      if (bairroMatch != null) {
        bairro = bairroMatch.group(1)?.trim();
      }

      return {
        'bairro': bairro,
        'cidade': cidade,
        'estado': estado,
      };
    } catch (e) {
      print('⚠️ Erro ao fazer parse do endereço: $e');
      return {
        'bairro': null,
        'cidade': null,
        'estado': null,
      };
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
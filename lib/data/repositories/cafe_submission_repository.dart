// lib/data/repositories/cafe_submission_repository.dart
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

      // 5. Criar LatLng e converter para string no formato esperado
      final latLng = LatLng(
        submission.latitude ?? 0.0,
        submission.longitude ?? 0.0,
      );
      
      // Formato automático: "LatLng(lat: -3.7327203, lng: -38.5270134)"
      final referenciaMapa = latLng.toString();
      
      print('💾 Salvando cafeteria no Supabase...');
      print('📍 referencia_mapa: $referenciaMapa');
      print('🔑 ref (Place ID): ${submission.placeId}');
      
      final cafeteriaId = await _cafeteriaService.createCafeteria(
        nome: submission.name,
        endereco: fullAddress,
        latitude: submission.latitude ?? 0.0,
        longitude: submission.longitude ?? 0.0,
        usuarioUid: usuarioUid,
        userId: userId,
        referenciaMapa: referenciaMapa, // ✅ "LatLng(lat: X, lng: Y)"
        ref: submission.placeId, // ✅ Place ID do Google (ChIJxxx...)
        telefone: submission.phone,
        instagram: submission.website,
        urlFoto: urlFoto,
        bairro: submission.neighborhood,
        cidade: submission.city,
        estado: submission.state,
        pais: submission.country,
        cep: submission.postalCode,
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
      print('══════════════════════════════');

      return Result.ok(cafeteriaId);
    } catch (e, stackTrace) {
      print('❌ Erro ao submeter cafeteria: $e');
      print('Stack trace: $stackTrace');
      return Result.error(
        Exception('Erro ao enviar cafeteria: ${e.toString()}'),
      );
    }
  }

  Future<int> _getUserIdFromSupabase(String usuarioUid) async {
    try {
      print('🔍 Buscando user_id no Supabase para UID: $usuarioUid');
      
      final userProfile = await UserProfileService.getUserProfile(usuarioUid);

      if (userProfile == null) {
        throw Exception('Perfil de usuário não encontrado no Supabase');
      }

      final userId = userProfile.id;
      
      if (userId == null) {
        throw Exception('user_id não encontrado no perfil');
      }

      print('✅ user_id encontrado: $userId');
      return userId;
    } catch (e) {
      print('❌ Erro ao buscar user_id: $e');
      rethrow;
    }
  }

  Future<Result<String>> _uploadPhoto(
    File photo,
    String usuarioUid,
    String cafeName,
  ) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final sanitizedName = cafeName.replaceAll(RegExp(r'[^\w\s-]'), '').trim();
      final fileName = '${sanitizedName}_$timestamp.jpg';
      final path = 'cafeterias/$usuarioUid/$fileName';

      print('📤 Iniciando upload para: $path');

      final ref = _firebaseStorage.ref().child(path);
      await ref.putFile(photo);

      final downloadUrl = await ref.getDownloadURL();
      
      print('✅ Upload concluído: $downloadUrl');
      return Result.ok(downloadUrl);
    } catch (e) {
      print('❌ Erro no upload: $e');
      return Result.error(
        Exception('Erro ao fazer upload da foto: ${e.toString()}'),
      );
    }
  }

  Future<Result<String>> _uploadPhotoFromXFile(
    XFile photo,
    String usuarioUid,
    String cafeName,
  ) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final sanitizedName = cafeName.replaceAll(RegExp(r'[^\w\s-]'), '').trim();
      final fileName = '${sanitizedName}_$timestamp.jpg';
      final path = 'cafeterias/$usuarioUid/$fileName';

      print('📤 Iniciando upload XFile para: $path');

      final ref = _firebaseStorage.ref().child(path);
      
      if (kIsWeb) {
        final bytes = await photo.readAsBytes();
        await ref.putData(bytes);
      } else {
        await ref.putFile(File(photo.path));
      }

      final downloadUrl = await ref.getDownloadURL();
      
      print('✅ Upload XFile concluído: $downloadUrl');
      return Result.ok(downloadUrl);
    } catch (e) {
      print('❌ Erro no upload XFile: $e');
      return Result.error(
        Exception('Erro ao fazer upload da foto: ${e.toString()}'),
      );
    }
  }
}
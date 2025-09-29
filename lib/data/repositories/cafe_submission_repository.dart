import 'dart:io';
import '../models/domain/cafe_submission.dart';
import '../../utils/result.dart';

/// Interface abstrata para submissão de cafeterias
abstract class CafeSubmissionRepository {
  Future<Result<void>> submitCafe(CafeSubmission submission, File? customPhoto);
}

/// Implementação mock do repositório de submissão
class CafeSubmissionRepositoryImpl implements CafeSubmissionRepository {
  @override
  Future<Result<void>> submitCafe(
    CafeSubmission submission,
    File? customPhoto,
  ) async {
    try {
      // Simular upload de foto
      if (customPhoto != null) {
        await Future.delayed(Duration(milliseconds: 1500));
        print('📸 Upload da foto: ${customPhoto.path}');
      }

      // Simular envio dos dados
      await Future.delayed(Duration(milliseconds: 1000));
      print('📤 Enviando cafeteria: ${submission.name}');
      print('📍 Endereço: ${submission.address}');
      print('✨ Facilities: Office=${submission.isOfficeFriendly}, Pet=${submission.isPetFriendly}, Veg=${submission.isVegFriendly}');

      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Erro ao enviar cafeteria: $e'));
    }
  }
}
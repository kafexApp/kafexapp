// lib/services/user_profile_service.dart
import 'package:image_picker/image_picker.dart';
import 'package:kafex/backend/supabase/supabase.dart';
import '../utils/user_manager.dart';
import 'firebase_storage_service.dart';

class UserProfileService {
  /// Atualiza a foto de perfil do usuário
  static Future<bool> updateUserProfilePhoto(XFile imageFile) async {
    try {
      print('📷 Iniciando atualização da foto de perfil...');
      
      final userManager = UserManager.instance;
      final userEmail = userManager.userEmail;
      final userName = userManager.userName;
      
      // 1. Upload da imagem para o Firebase Storage (pasta específica para perfis)
      final imageUrl = await _uploadProfileImage(imageFile, userEmail);
      if (imageUrl == null) {
        print('❌ Falha no upload da foto de perfil');
        return false;
      }
      
      print('✅ Foto de perfil uploaded: $imageUrl');
      
      // 2. Atualizar na tabela usuario_perfil
      final updated = await _updateUserProfileInDatabase(userEmail, userName, imageUrl);
      if (!updated) {
        print('❌ Falha ao atualizar perfil no banco de dados');
        return false;
      }
      
      // 3. Atualizar UserManager
      userManager.setUserData(
        name: userName,
        email: userEmail,
        photoUrl: imageUrl,
      );
      
      print('✅ Foto de perfil atualizada com sucesso!');
      return true;
      
    } catch (e) {
      print('❌ Erro ao atualizar foto de perfil: $e');
      return false;
    }
  }
  
  /// Upload específico para fotos de perfil (pasta diferente dos posts)
  static Future<String?> _uploadProfileImage(XFile imageFile, String userEmail) async {
    try {
      // Usar Firebase Storage mas numa pasta específica para perfis
      final userUid = userEmail.replaceAll('@', '_').replaceAll('.', '_');
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      // Criar uma cópia temporária com nome específico para perfil
      final tempImageFile = XFile(
        imageFile.path,
        name: 'profiles/avatar_${userUid}_${timestamp}.jpg',
      );
      
      // Usar o serviço existente mas vamos personalizar o caminho
      return await FirebaseStorageService.uploadImageFromXFile(tempImageFile);
      
    } catch (e) {
      print('❌ Erro no upload da foto de perfil: $e');
      return null;
    }
  }
  
  /// Atualiza o perfil do usuário na tabela usuario_perfil
  static Future<bool> _updateUserProfileInDatabase(String userEmail, String userName, String imageUrl) async {
    try {
      // Verificar se o perfil já existe
      final existingUser = await SupaClient.client
          .from('usuario_perfil')
          .select('id')
          .eq('email', userEmail)
          .maybeSingle();

      if (existingUser == null) {
        // Criar novo perfil
        await SupaClient.client
            .from('usuario_perfil')
            .insert({
              'email': userEmail,
              'nome_exibicao': userName,
              'foto_url': imageUrl,
              'created_at': DateTime.now().toIso8601String(),
            });
        print('✅ Novo perfil criado no banco de dados');
      } else {
        // Atualizar perfil existente
        await SupaClient.client
            .from('usuario_perfil')
            .update({
              'nome_exibicao': userName,
              'foto_url': imageUrl,
            })
            .eq('email', userEmail);
        print('✅ Perfil atualizado no banco de dados');
      }
      
      return true;
      
    } catch (e) {
      print('❌ Erro ao atualizar perfil no banco: $e');
      return false;
    }
  }
  
  /// Busca dados completos do perfil do usuário
  static Future<Map<String, dynamic>?> getUserProfile(String userEmail) async {
    try {
      final response = await SupaClient.client
          .from('usuario_perfil')
          .select()
          .eq('email', userEmail)
          .maybeSingle();
          
      return response;
      
    } catch (e) {
      print('❌ Erro ao buscar perfil do usuário: $e');
      return null;
    }
  }
  
  /// Verifica se o usuário tem foto de perfil
  static Future<bool> hasProfilePhoto() async {
    try {
      final userManager = UserManager.instance;
      final userEmail = userManager.userEmail;
      
      // Primeiro verifica no UserManager
      if (userManager.userPhotoUrl != null && userManager.userPhotoUrl!.isNotEmpty) {
        return true;
      }
      
      // Depois verifica no banco de dados
      final profile = await getUserProfile(userEmail);
      final photoUrl = profile?['foto_url'] as String?;
      
      if (photoUrl != null && photoUrl.isNotEmpty) {
        // Atualizar UserManager se encontrou foto no banco
        userManager.setUserData(
          name: userManager.userName,
          email: userEmail,
          photoUrl: photoUrl,
        );
        return true;
      }
      
      return false;
      
    } catch (e) {
      print('❌ Erro ao verificar foto de perfil: $e');
      return false;
    }
  }
  
  /// Sincroniza dados do perfil do banco para o UserManager
  static Future<void> syncUserProfile() async {
    try {
      final userManager = UserManager.instance;
      final userEmail = userManager.userEmail;
      
      final profile = await getUserProfile(userEmail);
      if (profile != null) {
        final nome = profile['nome_exibicao'] as String?;
        final foto = profile['foto_url'] as String?;
        
        // Atualizar UserManager apenas se tiver dados mais completos
        if (nome != null || foto != null) {
          userManager.setUserData(
            name: nome ?? userManager.userName,
            email: userEmail,
            photoUrl: foto,
          );
          print('✅ Perfil sincronizado do banco de dados');
        }
      }
      
    } catch (e) {
      print('❌ Erro ao sincronizar perfil: $e');
    }
  }
}
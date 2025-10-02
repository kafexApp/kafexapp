// lib/utils/sync_user_photo_helper.dart
import 'package:kafex/backend/supabase/supabase.dart';
import 'user_manager.dart';

class SyncUserPhotoHelper {
  /// Sincroniza a foto do UserManager para o banco de dados
  static Future<bool> syncCurrentUserPhoto() async {
    try {
      final userManager = UserManager.instance;
      final userEmail = userManager.userEmail;
      final userName = userManager.userName;
      final userPhoto = userManager.userPhotoUrl;
      
      print('🔄 Sincronizando foto do usuário...');
      print('   Email: $userEmail');
      print('   Nome: $userName');
      print('   Foto: $userPhoto');
      
      if (userPhoto == null || userPhoto.isEmpty) {
        print('⚠️ Usuário não tem foto para sincronizar');
        return false;
      }
      
      // Verificar se o perfil já existe
      final existingUser = await SupaClient.client
          .from('usuario_perfil')
          .select('id, foto_url')
          .eq('email', userEmail)
          .maybeSingle();

      if (existingUser == null) {
        print('👤 Criando novo perfil com foto...');
        
        // Criar novo perfil
        await SupaClient.client
            .from('usuario_perfil')
            .insert({
              'email': userEmail,
              'nome_exibicao': userName,
              'foto_url': userPhoto,
              'created_at': DateTime.now().toIso8601String(),
            });
        
        print('✅ Novo perfil criado com foto');
        return true;
        
      } else {
        print('👤 Atualizando perfil existente...');
        
        // Atualizar perfil existente
        await SupaClient.client
            .from('usuario_perfil')
            .update({
              'nome_exibicao': userName,
              'foto_url': userPhoto,
            })
            .eq('email', userEmail);
        
        print('✅ Perfil atualizado com foto');
        return true;
      }
      
    } catch (e) {
      print('❌ Erro ao sincronizar foto: $e');
      return false;
    }
  }
  
  /// Força a sincronização e mostra resultado para debug
  static Future<void> forceSyncWithDebug() async {
    print('\n🚀 === FORÇANDO SINCRONIZAÇÃO DE FOTO ===');
    
    final userManager = UserManager.instance;
    print('📊 Estado atual do UserManager:');
    print('   Nome: ${userManager.userName}');
    print('   Email: ${userManager.userEmail}');
    print('   Foto: ${userManager.userPhotoUrl}');
    
    final success = await syncCurrentUserPhoto();
    
    if (success) {
      print('🎉 Sincronização bem-sucedida!');
      print('💡 Próximos posts devem mostrar a foto.');
    } else {
      print('💥 Falha na sincronização.');
      print('🔍 Verifique se o usuário tem foto configurada.');
    }
    
    print('=== FIM DA SINCRONIZAÇÃO ===\n');
  }
  
  /// Verifica se a foto está sincronizada
  static Future<bool> isPhotoSynced() async {
    try {
      final userManager = UserManager.instance;
      final userEmail = userManager.userEmail;
      final userPhoto = userManager.userPhotoUrl;
      
      if (userPhoto == null || userPhoto.isEmpty) {
        return false;
      }
      
      final profile = await SupaClient.client
          .from('usuario_perfil')
          .select('foto_url')
          .eq('email', userEmail)
          .maybeSingle();
      
      final dbPhoto = profile?['foto_url'] as String?;
      
      return dbPhoto == userPhoto;
      
    } catch (e) {
      print('❌ Erro ao verificar sincronização: $e');
      return false;
    }
  }
}
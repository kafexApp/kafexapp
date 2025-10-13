import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_settings.freezed.dart';
part 'profile_settings.g.dart';

@freezed
class ProfileSettings with _$ProfileSettings {
  const ProfileSettings._();
  
  const factory ProfileSettings({
    required String nomeExibicao,
    required String nomeUsuario,
    required String email,
    String? telefone,
    String? endereco,
    String? cep,
    String? cidade,
    String? estado,
    String? bairro,
    String? fotoUrl,
    @Default(false) bool hasChanges,
  }) = _ProfileSettings;

  factory ProfileSettings.fromJson(Map<String, dynamic> json) =>
      _$ProfileSettingsFromJson(json);

  // Método auxiliar para converter do formato do Supabase
  factory ProfileSettings.fromSupabase(Map<String, dynamic> data) {
    return ProfileSettings(
      nomeExibicao: data['nome_exibicao'] as String? ?? '',
      nomeUsuario: data['nome_usuario'] as String? ?? '',
      email: data['email'] as String? ?? '',
      telefone: data['telefone']?.toString(),
      endereco: data['endereco'] as String?,
      cep: data['cep']?.toString(),
      cidade: data['cidade'] as String?,
      estado: data['estado']?.toString(),
      bairro: data['bairro']?.toString(),
      fotoUrl: data['foto_url'] as String?,
    );
  }

  // Método auxiliar para converter para o formato do Supabase
  Map<String, dynamic> toSupabase() {
    return {
      'nome_exibicao': nomeExibicao,
      'nome_usuario': nomeUsuario,
      'email': email,
      if (telefone != null) 'telefone': telefone,
      if (endereco != null) 'endereco': endereco,
      if (cep != null) 'cep': cep,
      if (cidade != null) 'cidade': cidade,
      if (estado != null) 'estado': estado,
      if (bairro != null) 'bairro': bairro,
      if (fotoUrl != null) 'foto_url': fotoUrl,
    };
  }
}

@freezed
class ProfileSettingsState with _$ProfileSettingsState {
  const factory ProfileSettingsState({
    ProfileSettings? settings,
    @Default(false) bool isLoading,
    @Default(false) bool isSaving,
    String? selectedImagePath,
    String? errorMessage,
  }) = _ProfileSettingsState;

  factory ProfileSettingsState.fromJson(Map<String, dynamic> json) =>
      _$ProfileSettingsStateFromJson(json);
}
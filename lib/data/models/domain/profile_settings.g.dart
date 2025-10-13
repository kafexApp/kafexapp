// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProfileSettingsImpl _$$ProfileSettingsImplFromJson(
  Map<String, dynamic> json,
) => _$ProfileSettingsImpl(
  nomeExibicao: json['nomeExibicao'] as String,
  nomeUsuario: json['nomeUsuario'] as String,
  email: json['email'] as String,
  telefone: json['telefone'] as String?,
  endereco: json['endereco'] as String?,
  cep: json['cep'] as String?,
  cidade: json['cidade'] as String?,
  estado: json['estado'] as String?,
  bairro: json['bairro'] as String?,
  fotoUrl: json['fotoUrl'] as String?,
  hasChanges: json['hasChanges'] as bool? ?? false,
);

Map<String, dynamic> _$$ProfileSettingsImplToJson(
  _$ProfileSettingsImpl instance,
) => <String, dynamic>{
  'nomeExibicao': instance.nomeExibicao,
  'nomeUsuario': instance.nomeUsuario,
  'email': instance.email,
  'telefone': instance.telefone,
  'endereco': instance.endereco,
  'cep': instance.cep,
  'cidade': instance.cidade,
  'estado': instance.estado,
  'bairro': instance.bairro,
  'fotoUrl': instance.fotoUrl,
  'hasChanges': instance.hasChanges,
};

_$ProfileSettingsStateImpl _$$ProfileSettingsStateImplFromJson(
  Map<String, dynamic> json,
) => _$ProfileSettingsStateImpl(
  settings: json['settings'] == null
      ? null
      : ProfileSettings.fromJson(json['settings'] as Map<String, dynamic>),
  isLoading: json['isLoading'] as bool? ?? false,
  isSaving: json['isSaving'] as bool? ?? false,
  selectedImagePath: json['selectedImagePath'] as String?,
  errorMessage: json['errorMessage'] as String?,
);

Map<String, dynamic> _$$ProfileSettingsStateImplToJson(
  _$ProfileSettingsStateImpl instance,
) => <String, dynamic>{
  'settings': instance.settings,
  'isLoading': instance.isLoading,
  'isSaving': instance.isSaving,
  'selectedImagePath': instance.selectedImagePath,
  'errorMessage': instance.errorMessage,
};

// lib/backend/supabase/tables/usuario_perfil.dart
import '../../database/database.dart';

class UsuarioPerfilTable extends SupabaseTable<UsuarioPerfilRow> {
  @override
  String get tableName => 'usuario_perfil';

  @override
  UsuarioPerfilRow createRow(Map<String, dynamic> data) =>
      UsuarioPerfilRow(data);
}

class UsuarioPerfilRow extends SupabaseDataRow {
  UsuarioPerfilRow(Map<String, dynamic> data) : super(data);

  int? get id => getField<int>('id');
  set id(int? value) => setField<int>('id', value);

  String? get ref => getField<String>('ref');
  set ref(String? value) => setField<String>('ref', value);

  String? get nomeExibicao => getField<String>('nome_exibicao');
  set nomeExibicao(String? value) => setField<String>('nome_exibicao', value);

  String? get nomeUsuario => getField<String>('nome_usuario');
  set nomeUsuario(String? value) => setField<String>('nome_usuario', value);

  String? get email => getField<String>('email');
  set email(String? value) => setField<String>('email', value);

  String? get telefone => getField<String>('telefone');
  set telefone(String? value) => setField<String>('telefone', value);

  String? get fotoUrl => getField<String>('foto_url');
  set fotoUrl(String? value) => setField<String>('foto_url', value);

  String? get endereco => getField<String>('endereco');
  set endereco(String? value) => setField<String>('endereco', value);

  String? get cidade => getField<String>('cidade');
  set cidade(String? value) => setField<String>('cidade', value);

  String? get estado => getField<String>('estado');
  set estado(String? value) => setField<String>('estado', value);

  String? get bairro => getField<String>('bairro');
  set bairro(String? value) => setField<String>('bairro', value);

  String? get cep => getField<String>('cep');
  set cep(String? value) => setField<String>('cep', value);

  String? get cnpj => getField<String>('cnpj');
  set cnpj(String? value) => setField<String>('cnpj', value);

  bool? get profissional => getField<bool>('profissional');
  set profissional(bool? value) => setField<bool>('profissional', value);

  bool? get ativo => getField<bool>('ativo');
  set ativo(bool? value) => setField<bool>('ativo', value);

  bool? get cadastroCompleto => getField<bool>('cadastro_completo');
  set cadastroCompleto(bool? value) =>
      setField<bool>('cadastro_completo', value);

  String? get nivelUsuario => getField<String>('nivel_usuario');
  set nivelUsuario(String? value) => setField<String>('nivel_usuario', value);

  String? get loginSocial => getField<String>('login_social');
  set loginSocial(String? value) => setField<String>('login_social', value);

  DateTime? get criadoEm {
    final value = getField<dynamic>('criado_em');
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  set criadoEm(DateTime? value) => setField<DateTime>('criado_em', value);

  // Redes sociais
  String? get instagram => getField<String>('instagram');
  set instagram(String? value) => setField<String>('instagram', value);

  String? get facebook => getField<String>('facebook');
  set facebook(String? value) => setField<String>('facebook', value);

  String? get twitter => getField<String>('twitter');
  set twitter(String? value) => setField<String>('twitter', value);

  String? get youtube => getField<String>('youtube');
  set youtube(String? value) => setField<String>('youtube', value);

  String? get threads => getField<String>('threads');
  set threads(String? value) => setField<String>('threads', value);
}

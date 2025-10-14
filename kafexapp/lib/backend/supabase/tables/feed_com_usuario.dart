// lib/backend/supabase/tables/feed_com_usuario.dart
import '../../database/database.dart';

class FeedComUsuarioTable extends SupabaseTable<FeedComUsuarioRow> {
  @override
  String get tableName => 'feed_com_usuario';

  @override
  FeedComUsuarioRow createRow(Map<String, dynamic> data) =>
      FeedComUsuarioRow(data);
}

class FeedComUsuarioRow extends SupabaseDataRow {
  FeedComUsuarioRow(Map<String, dynamic> data) : super(data);

  int? get id => getField<int>('id');
  set id(int? value) => setField<int>('id', value);

  /// ✅ Getter para usuario_uid (Firebase UID do autor)
  String? get usuarioUid => getField<String>('usuario_uid');
  set usuarioUid(String? value) => setField<String>('usuario_uid', value);

  /// ✅ NOVO: Getter para id_cafeteria (ID da cafeteria na view)
  int? get cafeteriaId => getField<int>('id_cafeteria');
  set cafeteriaId(int? value) => setField<int>('id_cafeteria', value);

  DateTime? get criadoEm {
    final value = getField<dynamic>('criado_em');
    if (value == null) return null;

    // Se já é DateTime, retorna direto
    if (value is DateTime) {
      print('⏰ criadoEm é DateTime: $value');
      return value;
    }

    // Se é String, tenta fazer parse
    if (value is String) {
      print('⏰ criadoEm é String: $value');

      // Tenta parse com timezone UTC
      DateTime? parsed;

      // Formato 1: Com timezone explícita (2025-10-03 18:52:42.315)
      if (!value.contains('Z') && !value.contains('+')) {
        // Adiciona 'Z' para indicar UTC se não tiver timezone
        parsed = DateTime.tryParse(value + 'Z');
      } else {
        parsed = DateTime.tryParse(value);
      }

      if (parsed != null) {
        // Converte para horário local
        final local = parsed.toLocal();
        print('⏰ Convertido para local: $local');
        return local;
      }
    }

    print(
      '⏰ ERRO: Não conseguiu converter criado_em: $value (tipo: ${value.runtimeType})',
    );
    return null;
  }

  set criadoEm(DateTime? value) => setField<DateTime>('criado_em', value);

  String? get descricao => getField<String>('descricao');
  set descricao(String? value) => setField<String>('descricao', value);

  String? get imagemUrl => getField<String>('imagem_url');
  set imagemUrl(String? value) => setField<String>('imagem_url', value);

  String? get usuario => getField<String>('usuario');
  set usuario(String? value) => setField<String>('usuario', value);

  // Campo adicionado para nome do usuário salvo na tabela feed
  String? get nome_usuario => getField<String>('nome_usuario');
  set nome_usuario(String? value) => setField<String>('nome_usuario', value);

  String? get comentarios {
    final value = getField<dynamic>('comentarios');
    if (value == null) return null;
    if (value is String) return value;
    if (value is int) return value.toString();
    return null;
  }

  set comentarios(String? value) => setField<String>('comentarios', value);

  String? get tipo => getField<String>('tipo');
  set tipo(String? value) => setField<String>('tipo', value);

  String? get tipoCalculado => getField<String>('tipo_calculado');
  set tipoCalculado(String? value) => setField<String>('tipo_calculado', value);

  String? get nomeCafeteria => getField<String>('nome_cafeteria');
  set nomeCafeteria(String? value) => setField<String>('nome_cafeteria', value);

  /// ✅ COMPATIBILIDADE: Alias para nomeCafeteria
  String? get nome => nomeCafeteria;
  set nome(String? value) => nomeCafeteria = value;

  String? get endereco => getField<String>('endereco');
  set endereco(String? value) => setField<String>('endereco', value);

  double? get pontuacao {
    final value = getField<dynamic>('pontuacao');
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  set pontuacao(double? value) => setField<double>('pontuacao', value);

  String? get urlFoto => getField<String>('url_foto');
  set urlFoto(String? value) => setField<String>('url_foto', value);

  String? get urlVideo => getField<String>('url_video');
  set urlVideo(String? value) => setField<String>('url_video', value);

  String? get nomeExibicao => getField<String>('nome_exibicao');
  set nomeExibicao(String? value) => setField<String>('nome_exibicao', value);

  String? get fotoUrl => getField<String>('foto_url');
  set fotoUrl(String? value) => setField<String>('foto_url', value);
}

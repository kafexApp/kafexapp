// lib/backend/supabase/tables/avaliacao_com_cafeteria.dart
import '../../database/database.dart';

class AvaliacaoComCafeteriaTable
    extends SupabaseTable<AvaliacaoComCafeteriaRow> {
  @override
  String get tableName => 'avaliacao_com_cafeteria';

  @override
  AvaliacaoComCafeteriaRow createRow(Map<String, dynamic> data) =>
      AvaliacaoComCafeteriaRow(data);
}

class AvaliacaoComCafeteriaRow extends SupabaseDataRow {
  AvaliacaoComCafeteriaRow(Map<String, dynamic> data) : super(data);

  // Campos da avaliação
  int? get avaliacaoId => getField<int>('avaliacao_id');
  set avaliacaoId(int? value) => setField<int>('avaliacao_id', value);

  DateTime? get avaliacaoCriadaEm {
    final value = getField<dynamic>('avaliacao_criada_em');
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  set avaliacaoCriadaEm(DateTime? value) =>
      setField<DateTime>('avaliacao_criada_em', value);

  int? get userId => getField<int>('user_id');
  set userId(int? value) => setField<int>('user_id', value);

  String? get userRef => getField<String>('user_ref');
  set userRef(String? value) => setField<String>('user_ref', value);

  String? get nomeExibicao => getField<String>('nome_exibicao');
  set nomeExibicao(String? value) => setField<String>('nome_exibicao', value);

  int? get cafeteriaId => getField<int>('cafeteria_id');
  set cafeteriaId(int? value) => setField<int>('cafeteria_id', value);

  String? get cafeteriaRef => getField<String>('cafeteria_ref');
  set cafeteriaRef(String? value) => setField<String>('cafeteria_ref', value);

  String? get fotoUrl => getField<String>('foto_url');
  set fotoUrl(String? value) => setField<String>('foto_url', value);

  String? get descricao => getField<String>('descricao');
  set descricao(String? value) => setField<String>('descricao', value);

  double? get nota {
    final value = getField<dynamic>('nota');
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  set nota(double? value) => setField<double>('nota', value);

  num? get curtidasAvaliacao {
    final value = getField<dynamic>('curtidas_avaliacao');
    if (value == null) return null;
    if (value is num) return value;
    if (value is String) return num.tryParse(value);
    return null;
  }

  set curtidasAvaliacao(num? value) =>
      setField<num>('curtidas_avaliacao', value);

  String? get avaliacaoRef => getField<String>('avaliacao_ref');
  set avaliacaoRef(String? value) => setField<String>('avaliacao_ref', value);

  // Campos da cafeteria
  String? get cafeteriaNome => getField<String>('cafeteria_nome');
  set cafeteriaNome(String? value) => setField<String>('cafeteria_nome', value);

  String? get cafeteriaEndereco => getField<String>('cafeteria_endereco');
  set cafeteriaEndereco(String? value) =>
      setField<String>('cafeteria_endereco', value);

  String? get cafeteriaBairro => getField<String>('cafeteria_bairro');
  set cafeteriaBairro(String? value) =>
      setField<String>('cafeteria_bairro', value);

  String? get cafeteriaCidade => getField<String>('cafeteria_cidade');
  set cafeteriaCidade(String? value) =>
      setField<String>('cafeteria_cidade', value);

  String? get cafeteriaEstado => getField<String>('cafeteria_estado');
  set cafeteriaEstado(String? value) =>
      setField<String>('cafeteria_estado', value);

  String? get cafeteriaFoto => getField<String>('cafeteria_foto');
  set cafeteriaFoto(String? value) => setField<String>('cafeteria_foto', value);

  String? get cafeteriaInstagram => getField<String>('cafeteria_instagram');
  set cafeteriaInstagram(String? value) =>
      setField<String>('cafeteria_instagram', value);

  bool? get petFriendly => getField<bool>('pet_friendly');
  set petFriendly(bool? value) => setField<bool>('pet_friendly', value);

  bool? get opcaoVegana => getField<bool>('opcao_vegana');
  set opcaoVegana(bool? value) => setField<bool>('opcao_vegana', value);

  double? get lat {
    final value = getField<dynamic>('lat');
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  set lat(double? value) => setField<double>('lat', value);

  double? get lng {
    final value = getField<dynamic>('lng');
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  set lng(double? value) => setField<double>('lng', value);

  double? get pontuacao {
    final value = getField<dynamic>('pontuacao');
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  set pontuacao(double? value) => setField<double>('pontuacao', value);

  int? get avaliacoes => getField<int>('avaliacoes');
  set avaliacoes(int? value) => setField<int>('avaliacoes', value);

  bool? get cafeteriaAtiva => getField<bool>('cafeteria_ativa');
  set cafeteriaAtiva(bool? value) => setField<bool>('cafeteria_ativa', value);
}

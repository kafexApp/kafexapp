// lib/data/services/deeplink_service.dart

import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

/// Serviço responsável por gerenciar deeplinks no aplicativo
/// Suporta Custom URL Scheme (kafex://) e Universal Links (https://kafex.app)
class DeeplinkService {
  static final DeeplinkService _instance = DeeplinkService._internal();
  factory DeeplinkService() => _instance;
  DeeplinkService._internal();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  /// Callback para quando um deeplink é recebido
  Function(Uri)? onDeeplinkReceived;

  /// Inicializa o serviço de deeplink
  /// Deve ser chamado no main() ou no initState do widget raiz
  Future<void> initialize() async {
    try {
      // Verifica se o app foi aberto por um deeplink
      final initialUri = await _appLinks.getInitialAppLink();
      if (initialUri != null) {
        debugPrint('🔗 Deeplink inicial detectado: $initialUri');
        _handleDeeplink(initialUri);
      }

      // Escuta novos deeplinks enquanto o app está aberto
      _linkSubscription = _appLinks.uriLinkStream.listen(
        (uri) {
          debugPrint('🔗 Deeplink recebido: $uri');
          _handleDeeplink(uri);
        },
        onError: (err) {
          debugPrint('❌ Erro ao processar deeplink: $err');
        },
      );

      debugPrint('✅ DeeplinkService inicializado com sucesso');
    } catch (e) {
      debugPrint('❌ Erro ao inicializar DeeplinkService: $e');
    }
  }

  /// Processa o deeplink recebido
  void _handleDeeplink(Uri uri) {
    debugPrint('🔔 _handleDeeplink chamado');
    debugPrint('🔔 Callback está null? ${onDeeplinkReceived == null}');

    if (onDeeplinkReceived != null) {
      debugPrint('🔔 Chamando callback...');
      onDeeplinkReceived!(uri);
    } else {
      debugPrint('❌ Callback é null, não pode chamar!');
    }
  }

  /// Analisa a URI e retorna o tipo de deeplink e seus parâmetros
  DeeplinkData parseDeeplink(Uri uri) {
    debugPrint('🔍 Analisando deeplink: $uri');
    debugPrint('  - Scheme: ${uri.scheme}');
    debugPrint('  - Host: ${uri.host}');
    debugPrint('  - Path: ${uri.path}');
    debugPrint('  - Query: ${uri.queryParameters}');

    // Remove a barra inicial do path se existir
    final path = uri.path.startsWith('/') ? uri.path.substring(1) : uri.path;
    final segments = path.split('/').where((s) => s.isNotEmpty).toList();

    if (segments.isEmpty) {
      return DeeplinkData(type: DeeplinkType.home);
    }

    // Analisa o primeiro segmento para determinar o tipo
    switch (segments[0].toLowerCase()) {
      case 'cafeteria':
      case 'cafe':
        if (segments.length > 1) {
          return DeeplinkData(
            type: DeeplinkType.cafeDetail,
            id: segments[1],
            extraParams: uri.queryParameters,
          );
        }
        return DeeplinkData(type: DeeplinkType.cafeList);

      case 'usuario':
      case 'user':
      case 'perfil':
      case 'profile':
        if (segments.length > 1) {
          return DeeplinkData(
            type: DeeplinkType.userProfile,
            id: segments[1],
            extraParams: uri.queryParameters,
          );
        }
        return DeeplinkData(type: DeeplinkType.userProfile);

      case 'explorador':
      case 'explorer':
      case 'buscar':
      case 'search':
        return DeeplinkData(
          type: DeeplinkType.explorer,
          extraParams: uri.queryParameters,
        );

      default:
        debugPrint('⚠️ Tipo de deeplink desconhecido: ${segments[0]}');
        return DeeplinkData(type: DeeplinkType.unknown);
    }
  }

  /// Gera uma URL de deeplink para compartilhamento
  String generateDeeplinkUrl({
    required DeeplinkType type,
    String? id,
    Map<String, String>? params,
    bool useHttps = true,
  }) {
    final scheme = useHttps ? 'https' : 'kafex';
    final host = useHttps ? 'kafex.app' : '';

    String path = '';
    switch (type) {
      case DeeplinkType.cafeDetail:
        path = '/cafeteria/$id';
        break;
      case DeeplinkType.cafeList:
        path = '/cafeteria';
        break;
      case DeeplinkType.userProfile:
        path = id != null ? '/perfil/$id' : '/perfil';
        break;
      case DeeplinkType.explorer:
        path = '/explorador';
        break;
      case DeeplinkType.home:
        path = '/';
        break;
      default:
        path = '/';
    }

    // Adiciona parâmetros de query se existirem
    if (params != null && params.isNotEmpty) {
      final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
      path += '?$query';
    }

    final url = useHttps ? '$scheme://$host$path' : '$scheme:/$path';
    debugPrint('🔗 URL gerada: $url');
    return url;
  }

  /// Libera os recursos do serviço
  void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
    debugPrint('🗑️ DeeplinkService disposed');
  }
}

/// Tipos de deeplink suportados pelo aplicativo
enum DeeplinkType {
  home, // Tela inicial
  cafeDetail, // Detalhes de uma cafeteria
  cafeList, // Lista de cafeterias
  userProfile, // Perfil do usuário
  explorer, // Tela de explorador
  unknown, // Tipo desconhecido
}

/// Classe que encapsula os dados de um deeplink
class DeeplinkData {
  final DeeplinkType type;
  final String? id;
  final Map<String, String>? extraParams;

  DeeplinkData({required this.type, this.id, this.extraParams});

  @override
  String toString() {
    return 'DeeplinkData(type: $type, id: $id, extraParams: $extraParams)';
  }
}

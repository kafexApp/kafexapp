// lib/data/services/push_notification_service.dart

import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/push_notification_model.dart';

/// Handler para push notifications em background (deve ser top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📱 Push Notification recebida em background: ${message.messageId}');
  print('Título: ${message.notification?.title}');
  print('Mensagem: ${message.notification?.body}');
}

/// Service para gerenciar Push Notifications via Firebase Cloud Messaging
class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _initialized = false;
  String? _fcmToken;
  Function(PushNotificationModel)? _onNotificationTap;

  /// Getter para o token FCM atual
  String? get fcmToken => _fcmToken;

  /// Inicializa o serviço de push notifications
  Future<void> initialize({
    Function(PushNotificationModel)? onNotificationTap,
  }) async {
    if (_initialized) {
      print('⚠️ PushNotificationService já foi inicializado');
      return;
    }

    _onNotificationTap = onNotificationTap;

    try {
      print('🚀 Inicializando PushNotificationService...');

      // 1. Solicitar permissões
      await _requestPermissions();

      // 2. Configurar notificações locais
      await _initializeLocalNotifications();

      // 3. Configurar handlers do Firebase
      _setupFirebaseHandlers();

      // 4. Obter e salvar token FCM
      await _getAndSaveToken();

      // 5. Listener para renovação de token
      _firebaseMessaging.onTokenRefresh.listen(_onTokenRefresh);

      _initialized = true;
      print('✅ PushNotificationService inicializado com sucesso!');
    } catch (e) {
      print('❌ Erro ao inicializar PushNotificationService: $e');
    }
  }

  /// Solicita permissões para push notifications
  Future<void> _requestPermissions() async {
    print('📋 Solicitando permissões para push notifications...');

    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ Permissões concedidas!');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('⚠️ Permissões provisórias concedidas');
    } else {
      print('❌ Permissões negadas');
    }
  }

  /// Inicializa as notificações locais (para mostrar quando app está aberto)
  Future<void> _initializeLocalNotifications() async {
    print('📱 Configurando notificações locais...');

    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    // Canal de notificação para Android
    if (Platform.isAndroid) {
      const androidChannel = AndroidNotificationChannel(
        'kafex_push_channel',
        'Kafex Push Notifications',
        description: 'Push notifications do aplicativo Kafex',
        importance: Importance.high,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);
    }

    print('✅ Notificações locais configuradas!');
  }

  /// Configura os handlers do Firebase Messaging
  void _setupFirebaseHandlers() {
    print('🔧 Configurando handlers do Firebase...');

    // Push notification recebida quando app está em FOREGROUND
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Push notification clicada quando app estava em BACKGROUND
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Configurar handler para background
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Verificar se o app foi aberto por uma push notification
    _checkInitialMessage();
  }

  /// Verifica se o app foi aberto através de uma push notification
  Future<void> _checkInitialMessage() async {
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      print('📬 App aberto através de push notification');
      _handleNotificationTap(initialMessage);
    }
  }

  /// Handler para push notifications recebidas em foreground
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('📨 Push Notification recebida em foreground: ${message.messageId}');
    print('Título: ${message.notification?.title}');
    print('Mensagem: ${message.notification?.body}');

    // Mostrar notificação local
    await _showLocalNotification(message);
  }

  /// Mostra uma notificação local (quando app está aberto)
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;

    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'kafex_push_channel',
      'Kafex Push Notifications',
      channelDescription: 'Push notifications do aplicativo Kafex',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: message.data.toString(),
    );
  }

  /// Handler quando usuário clica na push notification
  void _handleNotificationTap(RemoteMessage message) {
    print('👆 Usuário clicou na push notification');

    if (_onNotificationTap != null) {
      final pushNotification = PushNotificationModel.fromFirebaseMessage(
        message.messageId ?? '',
        {
          'title': message.notification?.title,
          'body': message.notification?.body,
          'image_url': message.notification?.android?.imageUrl ??
              message.notification?.apple?.imageUrl,
          ...message.data,
        },
      );

      _onNotificationTap!(pushNotification);
    }
  }

  /// Handler quando usuário clica em notificação local
  void _onLocalNotificationTap(NotificationResponse response) {
    print('👆 Usuário clicou na notificação local');
    // Processar payload se necessário
  }

  /// Obtém o token FCM e salva no Supabase
  Future<String?> _getAndSaveToken() async {
    try {
      print('🔑 Obtendo token FCM...');

      // NOVO: Para iOS, precisamos obter o APNS token primeiro
      if (Platform.isIOS) {
        print('🍎 Obtendo APNS token para iOS...');
        
        // Tentar até 5 vezes com intervalo de 3 segundos
        String? apnsToken;
        for (int i = 0; i < 5; i++) {
          apnsToken = await _firebaseMessaging.getAPNSToken();
          
          if (apnsToken != null) {
            print('✅ APNS token obtido: ${apnsToken.substring(0, 20)}...');
            break;
          }
          
          if (i < 4) {
            print('⚠️ APNS token não disponível, tentativa ${i + 1}/5, aguardando 3s...');
            await Future.delayed(Duration(seconds: 3));
          }
        }
        
        if (apnsToken == null) {
          print('❌ APNS token não disponível após 5 tentativas');
          print('💡 Tente fechar e abrir o app novamente');
          return null;
        }
      }

      _fcmToken = await _firebaseMessaging.getToken();

      if (_fcmToken != null) {
        print('✅ Token FCM obtido: ${_fcmToken!.substring(0, 20)}...');
        await _saveTokenToDatabase(_fcmToken!);
        return _fcmToken;
      } else {
        print('❌ Não foi possível obter token FCM');
        return null;
      }
    } catch (e) {
      print('❌ Erro ao obter token FCM: $e');
      return null;
    }
  }

  /// Salva o token FCM no banco de dados (tabela device_tokens)
  Future<void> _saveTokenToDatabase(String token) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('⚠️ Usuário não autenticado, token não será salvo');
        return;
      }

      print('💾 Salvando token no Supabase...');

      // Detectar plataforma
      String platform = 'web';
      if (Platform.isAndroid) {
        platform = 'android';
      } else if (Platform.isIOS) {
        platform = 'ios';
      }

      // Verificar se token já existe
      final existingToken = await _supabase
          .from('device_tokens')
          .select()
          .eq('token', token)
          .maybeSingle();

      if (existingToken != null) {
        // Atualizar token existente
        await _supabase.from('device_tokens').update({
          'updated_at': DateTime.now().toIso8601String(),
          'active': true,
          'firebase_uid': user.uid,
        }).eq('token', token);

        print('✅ Token atualizado no Supabase');
      } else {
        // Inserir novo token
        await _supabase.from('device_tokens').insert({
          'firebase_uid': user.uid,
          'token': token,
          'platform': platform,
          'active': true,
        });

        print('✅ Token salvo no Supabase');
      }
    } catch (e) {
      print('❌ Erro ao salvar token no Supabase: $e');
    }
  }

  /// Callback quando o token FCM é renovado
  Future<void> _onTokenRefresh(String newToken) async {
    print('🔄 Token FCM renovado');
    _fcmToken = newToken;
    await _saveTokenToDatabase(newToken);
  }

  /// Desativa o token atual (usado no logout)
  Future<void> deactivateToken() async {
    try {
      if (_fcmToken == null) return;

      print('🔒 Desativando token...');

      await _supabase
          .from('device_tokens')
          .update({'active': false}).eq('token', _fcmToken!);

      print('✅ Token desativado');
    } catch (e) {
      print('❌ Erro ao desativar token: $e');
    }
  }

  /// Deleta o token do banco (usado ao desinstalar)
  Future<void> deleteToken() async {
    try {
      if (_fcmToken == null) return;

      print('🗑️ Deletando token...');

      await _supabase.from('device_tokens').delete().eq('token', _fcmToken!);

      await _firebaseMessaging.deleteToken();

      print('✅ Token deletado');
    } catch (e) {
      print('❌ Erro ao deletar token: $e');
    }
  }
}
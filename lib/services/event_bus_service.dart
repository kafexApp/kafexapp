// lib/services/event_bus_service.dart
import 'dart:async';

/// Eventos que podem ser disparados no app
abstract class AppEvent {}

/// Evento disparado quando um novo post é criado
class PostCreatedEvent extends AppEvent {
  final String postId;
  
  PostCreatedEvent(this.postId);
}

/// Evento disparado quando um post é excluído
class PostDeletedEvent extends AppEvent {
  final String postId;
  
  PostDeletedEvent(this.postId);
}

/// Service para comunicação entre ViewModels através de eventos
class EventBusService {
  static final EventBusService _instance = EventBusService._internal();
  factory EventBusService() => _instance;
  EventBusService._internal();

  final StreamController<AppEvent> _eventController = StreamController<AppEvent>.broadcast();

  /// Stream para escutar eventos
  Stream<AppEvent> get events => _eventController.stream;

  /// Dispara um evento
  void emit(AppEvent event) {
    print('🚀 Evento disparado: ${event.runtimeType}');
    _eventController.add(event);
  }

  /// Escuta eventos de um tipo específico
  Stream<T> on<T extends AppEvent>() {
    return events.where((event) => event is T).cast<T>();
  }

  /// Limpa recursos quando não precisar mais
  void dispose() {
    _eventController.close();
  }
}
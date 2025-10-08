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

/// Evento disparado quando uma cafeteria é favoritada/desfavoritada
class FavoriteChangedEvent extends AppEvent {
  final String coffeeId;
  final bool isFavorited;
  
  FavoriteChangedEvent(this.coffeeId, this.isFavorited);
}

/// Evento disparado quando marca/desmarca "Quero Visitar"
class WantToVisitChangedEvent extends AppEvent {
  final String coffeeId;
  final bool wantToVisit;
  
  WantToVisitChangedEvent(this.coffeeId, this.wantToVisit);
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
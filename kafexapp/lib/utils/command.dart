import 'package:flutter/foundation.dart';
import 'result.dart';

/// Classe base para comandos que encapsulam operações assíncronas
/// Gerencia estados: idle, running, completed, error
abstract class Command<T> extends ChangeNotifier {
  Command();

  bool _running = false;
  Result<T>? _result;

  bool get running => _running;
  bool get error => _result is Error;
  bool get completed => _result is Ok;
  Result<T>? get result => _result;

  Future<void> _execute(Future<Result<T>> Function() action) async {
    if (_running) return;

    _running = true;
    _result = null;
    notifyListeners();

    try {
      _result = await action();
    } finally {
      _running = false;
      notifyListeners();
    }
  }
}

/// Comando sem argumentos
class Command0<T> extends Command<T> {
  Command0(this._action);
  
  final Future<Result<T>> Function() _action;
  
  Future<void> execute() async {
    await _execute(() => _action());
  }
}

/// Comando com 1 argumento
class Command1<T, A> extends Command<T> {
  Command1(this._action);
  
  final Future<Result<T>> Function(A) _action;
  
  Future<void> execute(A argument) async {
    await _execute(() => _action(argument));
  }
}
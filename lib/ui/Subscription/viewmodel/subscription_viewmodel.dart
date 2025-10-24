// lib/ui/subscription/viewmodel/subscription_viewmodel.dart

import 'package:flutter/material.dart';

class SubscriptionViewModel extends ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  // Método para processar a assinatura
  Future<void> subscribe(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Aqui você vai integrar com o gateway de pagamento
      // Por enquanto apenas simula um delay
      await Future.delayed(Duration(seconds: 2));
      
      // Após sucesso do pagamento, navegar para tela de confirmação
      // Navigator.pushNamed(context, '/subscription-success');
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      
      // Mostrar erro para o usuário
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao processar assinatura. Tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
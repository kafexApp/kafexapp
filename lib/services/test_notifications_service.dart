// lib/services/test_notifications_service.dart
// ARQUIVO TEMPORÁRIO APENAS PARA TESTES - DELETAR DEPOIS

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'notifications_service.dart';

/// Tela de teste para o NotificationsService
class TestNotificationsScreen extends StatefulWidget {
  const TestNotificationsScreen({Key? key}) : super(key: key);

  @override
  State<TestNotificationsScreen> createState() => _TestNotificationsScreenState();
}

class _TestNotificationsScreenState extends State<TestNotificationsScreen> {
  String _resultado = 'Aguardando teste...';
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teste NotificationsService'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card com o resultado
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resultado do Teste:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      _resultado,
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Botões de teste
            ElevatedButton.icon(
              onPressed: _loading ? null : _testarBuscarNotificacoes,
              icon: Icon(Icons.notifications),
              label: Text('1. Buscar Notificações'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(16),
                backgroundColor: Colors.blue,
              ),
            ),

            SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: _loading ? null : _testarContarNotificacoes,
              icon: Icon(Icons.numbers),
              label: Text('2. Contar Não Lidas'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(16),
                backgroundColor: Colors.green,
              ),
            ),

            SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: _loading ? null : _testarCriarNotificacao,
              icon: Icon(Icons.add_alert),
              label: Text('3. Criar Notificação de Teste'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(16),
                backgroundColor: Colors.orange,
              ),
            ),

            SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: _loading ? null : _testarMarcarComoLida,
              icon: Icon(Icons.done),
              label: Text('4. Marcar Todas Como Lidas'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(16),
                backgroundColor: Colors.purple,
              ),
            ),

            SizedBox(height: 20),

            if (_loading)
              Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  /// Teste 1: Buscar todas as notificações
  Future<void> _testarBuscarNotificacoes() async {
    setState(() {
      _loading = true;
      _resultado = 'Buscando notificações...';
    });

    try {
      // SOLUÇÃO: Buscar diretamente pelo UID usando Supabase.instance
      final response = await Supabase.instance.client
          .from('notificacao')
          .select()
          .eq('user_notificado_ref', 'M2KJy0duZQPfgvEIgPDqqgRv1xu2')
          .order('created_at', ascending: false);
      
      final notificacoes = List<Map<String, dynamic>>.from(response);
      
      setState(() {
        _resultado = '''
✅ SUCESSO!

Total de notificações: ${notificacoes.length}

${notificacoes.isEmpty ? 'Nenhuma notificação encontrada.' : 'Primeiras notificações:'}
${_formatarNotificacoes(notificacoes.take(3).toList())}
        ''';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _resultado = '❌ ERRO ao buscar notificações:\n\n$e';
        _loading = false;
      });
    }
  }

  /// Teste 2: Contar notificações não lidas
  Future<void> _testarContarNotificacoes() async {
    setState(() {
      _loading = true;
      _resultado = 'Contando notificações não lidas...';
    });

    try {
      // SOLUÇÃO: Buscar diretamente pelo UID usando Supabase.instance
      final response = await Supabase.instance.client
          .from('notificacao')
          .select()
          .eq('user_notificado_ref', 'M2KJy0duZQPfgvEIgPDqqgRv1xu2')
          .eq('visivel', true)
          .count();
      
      final count = response.count;
      
      setState(() {
        _resultado = '''
✅ SUCESSO!

Você tem $count notificação(ões) não lida(s).
        ''';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _resultado = '❌ ERRO ao contar notificações:\n\n$e';
        _loading = false;
      });
    }
  }

  /// Teste 3: Criar uma notificação de teste
  Future<void> _testarCriarNotificacao() async {
    setState(() {
      _loading = true;
      _resultado = 'Criando notificação de teste...';
    });

    try {
      // IMPORTANTE: Isso vai criar uma notificação para o usuário logado
      // Você precisa estar logado no Firebase para funcionar
      final sucesso = await NotificationsService.createNotification(
        tipo: 'teste',
        usuarioNotificadoRef: 'M2KJy0duZQPfgvEIgPDqqgRv1xu2',
        feedId: null,
        comentarioId: null,
        cafeteriaId: null,
        previaComentario: 'Esta é uma notificação de teste!',
      );

      setState(() {
        if (sucesso) {
          _resultado = '''
✅ SUCESSO!

Notificação de teste criada!
Agora execute o Teste 1 para ver a notificação.

IMPORTANTE: Se não aparecer, verifique se o usuarioNotificadoRef está correto.
          ''';
        } else {
          _resultado = '''
❌ Falha ao criar notificação.

Verifique:
1. Se você está logado no Firebase
2. Se o usuarioNotificadoRef está correto
3. Se o usuário existe na tabela usuario_perfil
          ''';
        }
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _resultado = '❌ ERRO ao criar notificação:\n\n$e';
        _loading = false;
      });
    }
  }

  /// Teste 4: Marcar todas como lidas
  Future<void> _testarMarcarComoLida() async {
    setState(() {
      _loading = true;
      _resultado = 'Marcando todas como lidas...';
    });

    try {
      // SOLUÇÃO: Marcar diretamente pelo UID usando Supabase.instance
      await Supabase.instance.client
          .from('notificacao')
          .update({'visivel': false})
          .eq('user_notificado_ref', 'M2KJy0duZQPfgvEIgPDqqgRv1xu2');
      
      setState(() {
        _resultado = '''
✅ SUCESSO!

Todas as notificações foram marcadas como lidas.
Execute o Teste 2 para verificar (deve mostrar 0).
        ''';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _resultado = '❌ ERRO ao marcar como lidas:\n\n$e';
        _loading = false;
      });
    }
  }

  /// Formata lista de notificações para exibição
  String _formatarNotificacoes(List<Map<String, dynamic>> notificacoes) {
    if (notificacoes.isEmpty) return '';

    return notificacoes.map((notif) {
      return '''
---
ID: ${notif['id']}
Tipo: ${notif['tipo'] ?? 'N/A'}
Visível: ${notif['visivel'] ?? 'N/A'}
Criada em: ${notif['created_at'] ?? 'N/A'}
      ''';
    }).join('\n');
  }
}
// lib/ui/posts/widgets/create_post_screen.dart
import 'package:flutter/material.dart';
import '../providers/create_post_provider.dart';
import 'create_post_modal.dart';

class CreatePostScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Abre o modal automaticamente quando a tela é carregada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showCreatePostModal(context);
      Navigator.of(context).pop();
    });

    // Retorna uma tela transparente
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(),
    );
  }
}

// Função helper para mostrar o modal
void showCreatePostModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => CreatePostProvider(
      child: CreatePostModal(),
    ),
  );
}
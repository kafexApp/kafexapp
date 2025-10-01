// lib/ui/cafe_detail/widgets/cafe_detail_modal.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cafe_detail_model.dart';
import '../view_model/cafe_detail_view_model.dart';
import 'cafe_header_widget.dart';
import 'cafe_review_widget.dart';
import 'cafe_actions_widget.dart';

class CafeDetailModal extends StatelessWidget {
  final CafeDetailModel cafe;

  const CafeDetailModal({
    Key? key,
    required this.cafe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CafeDetailViewModel(cafe: cafe),
      child: Consumer<CafeDetailViewModel>(
        builder: (context, viewModel, child) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle clean
                Container(
                  margin: EdgeInsets.only(top: 12, bottom: 8),
                  width: 32,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Conteúdo scrollável
                Flexible(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header com imagem, nome, rating, etc.
                          CafeHeaderWidget(),
                          SizedBox(height: 20),
                          
                          // Seção de avaliações
                          CafeReviewWidget(),
                          SizedBox(height: 20),
                          
                          // Botões de ação
                          CafeActionsWidget(),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Mensagem de erro (se houver)
                if (viewModel.errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            viewModel.errorMessage!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onErrorContainer,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => viewModel.clearError(),
                          child: Text(
                            'OK',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onErrorContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Função de compatibilidade para mostrar o modal
void showCafeDetailModal(BuildContext context, dynamic cafeModel) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    enableDrag: true,
    builder: (context) => GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () {},
          child: DraggableScrollableSheet(
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) => Container(
              child: CafeDetailModal(
                cafe: CafeDetailModel.fromCafeModel(cafeModel),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

// Função de compatibilidade com o nome antigo (para não quebrar código existente)
void showCafeModal(BuildContext context, dynamic cafeModel) {
  showCafeDetailModal(context, cafeModel);
}
// lib/ui/cafe_detail/widgets/cafe_detail_modal.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/cafe_detail_model.dart';
import '../view_model/cafe_detail_view_model.dart';
import '../../../data/repositories/cafe_repository.dart';
import 'cafe_header_widget.dart';
import 'cafe_review_widget.dart';
import 'cafe_actions_widget.dart';

/// Modal de detalhes da cafeteria
class CafeDetailModal extends StatefulWidget {
  final CafeDetailModel cafe;

  const CafeDetailModal({Key? key, required this.cafe}) : super(key: key);

  @override
  State<CafeDetailModal> createState() => _CafeDetailModalState();
}

class _CafeDetailModalState extends State<CafeDetailModal> {
  late CafeDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    // Criar o ViewModel
    _viewModel = CafeDetailViewModel(
      cafe: widget.cafe,
      cafeRepository: context.read<CafeRepository>(),
    );

    // Carregar dados reais após o build inicial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadCafeData(widget.cafe.id);
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CafeDetailViewModel>.value(
      value: _viewModel,
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
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Conteúdo scrollável
                Flexible(
                  child: viewModel.isLoading
                      ? _buildLoadingState()
                      : viewModel.errorMessage != null
                      ? _buildErrorState(viewModel)
                      : _buildContent(viewModel),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Carregando dados da cafeteria...',
              style: GoogleFonts.albertSans(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(CafeDetailViewModel viewModel) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            SizedBox(height: 16),
            Text(
              viewModel.errorMessage ?? 'Erro ao carregar dados',
              style: GoogleFonts.albertSans(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                viewModel.loadCafeData(widget.cafe.id);
              },
              child: Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(CafeDetailViewModel viewModel) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com imagem, nome, rating, etc.
            CafeHeaderWidget(),
            SizedBox(height: 20),

            // Seção de avaliações
            if (viewModel.hasReviews) ...[
              CafeReviewWidget(),
              SizedBox(height: 20),
            ],

            // Botões de ação
            CafeActionsWidget(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

/// Função helper para mostrar o modal
void showCafeDetailModal(BuildContext context, dynamic cafe) {
  // Converter CafeModel para CafeDetailModel se necessário
  final CafeDetailModel cafeDetail = cafe is CafeDetailModel
      ? cafe
      : CafeDetailModel.fromCafeModel(cafe);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => CafeDetailModal(cafe: cafeDetail),
    ),
  );
}

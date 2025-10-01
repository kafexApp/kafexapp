// lib/ui/cafe_detail/widgets/cafe_actions_widget.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../view_model/cafe_detail_view_model.dart';

class CafeActionsWidget extends StatelessWidget {
  const CafeActionsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CafeDetailViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Text(
              'O que você gostaria de fazer?',
              style: GoogleFonts.albertSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 16),
            
            // Botões de ação
            _buildActionButtons(context, viewModel),
            SizedBox(height: 16),
            
            // Botão reportar
            _buildReportButton(context, viewModel),
          ],
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context, CafeDetailViewModel viewModel) {
    return Column(
      children: [
        // Botão principal "Avaliar cafeteria"
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: viewModel.isLoading ? null : () => viewModel.openEvaluationModal(context),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: viewModel.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  )
                : Text(
                    'Avaliar cafeteria',
                    style: GoogleFonts.albertSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ),
        
        SizedBox(height: 10),
        
        // Botões secundários (Mapa e Compartilhar)
        Row(
          children: [
            // Botão do mapa
            Expanded(
              child: OutlinedButton.icon(
                onPressed: viewModel.isLoading ? null : () => viewModel.openInMaps(),
                icon: Icon(PhosphorIcons.mapPin(), size: 16),
                label: Text(
                  'Mapa',
                  style: GoogleFonts.albertSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            
            SizedBox(width: 10),
            
            // Botão compartilhar
            Expanded(
              child: OutlinedButton.icon(
                onPressed: viewModel.isLoading ? null : () => viewModel.shareCafe(),
                icon: Icon(PhosphorIcons.shareNetwork(), size: 16),
                label: Text(
                  'Compartilhar',
                  style: GoogleFonts.albertSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReportButton(BuildContext context, CafeDetailViewModel viewModel) {
    return Container(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: viewModel.isLoading ? null : () => viewModel.reportCafeChange(context),
        icon: Icon(
          PhosphorIcons.warning(),
          size: 16,
          color: Theme.of(context).colorScheme.error.withOpacity(0.8),
        ),
        label: Text(
          'Avisar que mudou de endereço ou fechou',
          style: GoogleFonts.albertSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.error.withOpacity(0.8),
          ),
        ),
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 12),
          backgroundColor: Theme.of(context).colorScheme.errorContainer.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
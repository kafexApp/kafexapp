import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_icons.dart';
import '../../viewmodel/add_cafe_viewmodel.dart';
import '../components/info_box.dart';
import '../components/summary_item.dart';

class SubmitStep extends StatelessWidget {
  final AddCafeViewModel viewModel;

  const SubmitStep({
    Key? key,
    required this.viewModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.whiteWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      AppIcons.checkCircle,
                      size: 24,
                      color: AppColors.cyberLime,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Resumo do cadastro',
                      style: GoogleFonts.albertSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.carbon,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                SummaryItem(
                  icon: AppIcons.storefront,
                  title: 'Cafeteria',
                  value: viewModel.selectedPlace?.name ?? 'Não selecionada',
                ),
                SizedBox(height: 16),
                SummaryItem(
                  icon: AppIcons.location,
                  title: 'Endereço',
                  value: viewModel.selectedPlace?.address ?? 'Não informado',
                ),
                SizedBox(height: 16),
                SummaryItem(
                  icon: AppIcons.image,
                  title: 'Foto',
                  value: viewModel.customPhoto != null
                      ? 'Adicionada'
                      : 'Não adicionada',
                ),
                SizedBox(height: 16),
                SummaryItem(
                  icon: AppIcons.star,
                  title: 'Facilidades',
                  value: viewModel.getFacilitiesText(),
                ),
              ],
            ),
          ),
          SizedBox(height: 30),
          InfoBox(
            icon: AppIcons.heart,
            title: 'Obrigado por contribuir!',
            description:
                'Vamos analisar as informações e adicionar a cafeteria ao nosso mapa. Isso pode levar até 24 horas.',
            color: AppColors.cyberLime,
          ),
          SizedBox(height: 180),
        ],
      ),
    );
  }
}
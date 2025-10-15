import 'package:flutter/material.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_icons.dart';
import '../../viewmodel/add_cafe_viewmodel.dart';
import '../components/info_box.dart';
import '../components/facility_switch.dart';

class DetailsStep extends StatelessWidget {
  final AddCafeViewModel viewModel;

  const DetailsStep({
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
          InfoBox(
            icon: AppIcons.heart,
            title: 'Ajude outros coffee lovers!',
            description:
                'Essas informações são opcionais, mas ajudam muito a comunidade a saber o que esperar do local.',
          ),
          SizedBox(height: 30),
          Container(
            decoration: BoxDecoration(
              color: AppColors.whiteWhite,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                FacilitySwitch(
                  title: 'Permite animais de estimação?',
                  value: viewModel.isPetFriendly,
                  onChanged: (value) => viewModel.setPetFriendly(value),
                  iconPath: 'assets/images/icon-pet-friendly.svg',
                ),
                Divider(height: 1, color: AppColors.moonAsh),
                FacilitySwitch(
                  title: 'Oferece opções veganas?',
                  value: viewModel.isVegFriendly,
                  onChanged: (value) => viewModel.setVegFriendly(value),
                  iconPath: 'assets/images/icon-veg-friendly.svg',
                ),
                Divider(height: 1, color: AppColors.moonAsh),
                FacilitySwitch(
                  title: 'Bom para trabalhar?',
                  value: viewModel.isOfficeFriendly,
                  onChanged: (value) => viewModel.setOfficeFriendly(value),
                  iconPath: 'assets/images/icon-office-friendly.svg',
                ),
              ],
            ),
          ),
          SizedBox(height: 180),
        ],
      ),
    );
  }
}
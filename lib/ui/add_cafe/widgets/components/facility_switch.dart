import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../utils/app_colors.dart';

class FacilitySwitch extends StatelessWidget {
  final String title;
  final bool value;
  final Function(bool) onChanged;
  final String iconPath;

  const FacilitySwitch({
    Key? key,
    required this.title,
    required this.value,
    required this.onChanged,
    required this.iconPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          SvgPicture.asset(
            iconPath,
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              AppColors.velvetMerlot,
              BlendMode.srcIn,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.albertSans(
                fontSize: 14,
                color: AppColors.carbon,
                height: 1.3,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.pear,
            activeTrackColor: AppColors.pear.withOpacity(0.3),
            inactiveThumbColor: AppColors.grayScale2,
            inactiveTrackColor: AppColors.moonAsh,
          ),
        ],
      ),
    );
  }
}
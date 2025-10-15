import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../utils/app_colors.dart';

class InfoBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const InfoBox({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
    this.color = AppColors.papayaSensorial,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.albertSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.carbon,
            ),
          ),
          SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.albertSans(
              fontSize: 14,
              color: AppColors.grayScale1,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
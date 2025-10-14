import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';

class CustomMapPin extends StatelessWidget {
  final String cafeName;
  final VoidCallback? onTap;

  const CustomMapPin({
    Key? key,
    required this.cafeName,
    this.onTap,
  }) : super(key: key);

  String _truncateName(String name) {
    if (name.length <= 14) {
      return name;
    }
    return '${name.substring(0, 14)}...';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.velvetMerlot,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ícone do pin
              SvgPicture.asset(
                'assets/images/icon-pin-map.svg',
                width: 16,
                height: 16,
              ),
              SizedBox(width: 8),
              // Nome da cafeteria
              Text(
                _truncateName(cafeName),
                style: GoogleFonts.albertSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.whiteWhite,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
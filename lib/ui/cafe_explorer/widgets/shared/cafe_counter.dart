// lib/ui/cafe_explorer/widgets/shared/cafe_counter.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../utils/app_colors.dart';

class CafeCounter extends StatelessWidget {
  final int count;

  const CafeCounter({
    Key? key,
    required this.count,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.whiteWhite,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/images/icon-pin-map.svg',
            width: 24,
            height: 24,
          ),
          SizedBox(width: 8),
          Text(
            '$count',
            style: GoogleFonts.albertSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.carbon,
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../utils/app_colors.dart';

class InfoBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final double height;

  const InfoBanner({
    Key? key,
    required this.title,
    required this.subtitle,
    this.height = 200,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: AssetImage('assets/images/coffeeshop_banner.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(height == 200 ? 24 : 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.3),
              Colors.black.withOpacity(0.6),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.albertSans(
                fontSize: height == 200 ? 24 : 22,
                fontWeight: FontWeight.w600,
                color: AppColors.whiteWhite,
                height: 1.3,
              ),
            ),
            SizedBox(height: height == 200 ? 12 : 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.albertSans(
                fontSize: height == 200 ? 16 : 14,
                color: AppColors.papayaSensorial,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
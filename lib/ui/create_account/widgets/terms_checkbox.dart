// lib/ui/create_account/widgets/terms_checkbox.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/app_colors.dart';

class TermsCheckbox extends StatelessWidget {
  final bool isChecked;
  final VoidCallback onChanged;

  const TermsCheckbox({
    Key? key,
    required this.isChecked,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged,
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isChecked ? AppColors.papayaSensorial : Colors.transparent,
              border: Border.all(
                color: isChecked 
                    ? AppColors.papayaSensorial 
                    : AppColors.moonAsh.withOpacity(0.3),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: isChecked
                ? Icon(
                    Icons.check,
                    size: 16,
                    color: AppColors.whiteWhite,
                  )
                : null,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 2),
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.albertSans(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(text: 'Aceito os '),
                    TextSpan(
                      text: 'termos de uso',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(text: ' e '),
                    TextSpan(
                      text: 'política de privacidade',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
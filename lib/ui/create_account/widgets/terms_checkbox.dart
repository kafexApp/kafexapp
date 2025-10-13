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
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.whiteWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isChecked 
                ? AppColors.pear.withOpacity(0.3)
                : AppColors.moonAsh.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isChecked ? AppColors.pear : Colors.transparent,
                border: Border.all(
                  color: isChecked 
                      ? AppColors.pear 
                      : AppColors.moonAsh.withOpacity(0.4),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: isChecked
                  ? Icon(
                      Icons.check,
                      size: 14,
                      color: AppColors.carbon,
                      weight: 700,
                    )
                  : null,
            ),
            SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 1),
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
                          color: AppColors.carbon,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.carbon.withOpacity(0.3),
                        ),
                      ),
                      TextSpan(text: ' e '),
                      TextSpan(
                        text: 'política de privacidade',
                        style: TextStyle(
                          color: AppColors.carbon,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.carbon.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
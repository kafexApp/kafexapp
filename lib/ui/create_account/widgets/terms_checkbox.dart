// lib/ui/create_account/widgets/terms_checkbox.dart

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
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
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.papayaSensorial.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.papayaSensorial,
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onChanged,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: AppColors.whiteWhite,
                border: Border.all(
                  color: isChecked 
                      ? AppColors.papayaSensorial 
                      : AppColors.moonAsh.withOpacity(0.4),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: isChecked
                  ? Icon(
                      Icons.check,
                      size: 14,
                      color: AppColors.papayaSensorial,
                      weight: 700,
                    )
                  : null,
            ),
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
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => _launchURL('https://kafex.com.br/termos-de-uso/'),
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
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => _launchURL('https://kafex.com.br/politica-de-privacidade/'),
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

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      print('❌ Não foi possível abrir o link: $url');
    }
  }
}
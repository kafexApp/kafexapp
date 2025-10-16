// lib/screens/welcome_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_buttons.dart';
import 'login_screen.dart';
import '../ui/create_account/widgets/create_account.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.oatWhite,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(56.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SvgPicture.asset(
                          'assets/images/kafex_logo_positive.svg',
                          width: 160,
                          height: 60,
                        ),

                        SizedBox(height: 80),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'UM GUIA',
                              style: TextStyle(
                                fontFamily: 'Monigue',
                                fontSize: 54,
                                fontWeight: FontWeight.w400,
                                color: AppColors.velvetMerlot,
                                height: 0.9,
                              ),
                            ),
                            Text(
                              'CONFIÁVEL',
                              style: TextStyle(
                                fontFamily: 'Monigue',
                                fontSize: 54,
                                fontWeight: FontWeight.w400,
                                color: AppColors.velvetMerlot,
                                height: 0.9,
                              ),
                            ),
                            Text(
                              'PARA QUEM AMA',
                              style: TextStyle(
                                fontFamily: 'Monigue',
                                fontSize: 54,
                                fontWeight: FontWeight.w400,
                                color: AppColors.papayaSensorial,
                                height: 0.9,
                              ),
                            ),
                            Text(
                              'CAFÉ ESPECIAL',
                              style: TextStyle(
                                fontFamily: 'Monigue',
                                fontSize: 54,
                                fontWeight: FontWeight.w400,
                                color: AppColors.papayaSensorial,
                                height: 0.9,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 40),

                        SvgPicture.asset(
                          'assets/images/star.svg',
                          width: 40,
                          height: 40,
                        ),

                        SizedBox(height: 40),

                        Text(
                          'Tem mais cafeteria boa no mundo do que o google é capaz de te mostrar.',
                          textAlign: TextAlign.left,
                          style: GoogleFonts.albertSans(
                            fontSize: 16,
                            color: AppColors.grayScale1,
                            height: 1.4,
                          ),
                        ),

                        Expanded(child: SizedBox()),

                        Column(
                          children: [
                            PrimaryButton(
                              text: 'Já sou membro',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => LoginScreen()),
                                );
                              },
                            ),

                            SizedBox(height: 16),

                            CustomOutlineButton(
                              text: 'Criar conta grátis',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => CreateAccountScreen()),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
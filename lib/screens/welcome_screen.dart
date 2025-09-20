import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_buttons.dart';
import 'login_screen.dart';
import 'create_account_screen.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.oatWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(56.0), // Margem de 56px em volta
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo no topo (alinhado à esquerda)
              SvgPicture.asset(
                'assets/images/kafex_logo_positive.svg',
                width: 160,
                height: 60,
              ),

              SizedBox(height: 80), // Espaço maior após o logo

              // Título principal (alinhado à esquerda)
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

              // Ícone decorativo (alinhado à esquerda)
              SvgPicture.asset(
                'assets/images/star.svg',
                width: 40,
                height: 40,
              ),

              SizedBox(height: 40),

              // Descrição (usando Google Fonts Albert Sans)
              Text(
                'Tem mais cafeteria boa no mundo do\nque o google é capaz de te mostrar.',
                textAlign: TextAlign.left,
                style: GoogleFonts.albertSans(
                  fontSize: 16,
                  color: AppColors.grayScale1,
                  height: 1.4,
                ),
              ),

              // Espaçamento flexível para empurrar botões para baixo
              Expanded(child: SizedBox()),

              // Botões usando componentes padronizados
              Column(
                children: [
                  // Botão "Já sou membro" usando PrimaryButton
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

                  // Botão "Criar conta grátis" usando OutlineButton customizado
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
    );
  }
}
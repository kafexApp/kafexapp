// lib/widgets/custom_bottom_navbar.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../screens/cafe_explorer_screen.dart';
import 'side_menu_overlay.dart';

class CustomBottomNavbar extends StatelessWidget {
  final VoidCallback? onMenuPressed;
  final VoidCallback? onSearchPressed;

  const CustomBottomNavbar({
    Key? key,
    this.onMenuPressed,
    this.onSearchPressed,
  }) : super(key: key);

  void _navigateToCafeExplorer(BuildContext context) {
    print('🚀 Navegando para CafeExplorerScreen...');
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CafeExplorerScreen(),
        ),
      ).then((value) {
        print('✅ Navegação concluída com sucesso!');
      }).catchError((error) {
        print('❌ Erro na navegação: $error');
      });
    } catch (e) {
      print('❌ Erro ao tentar navegar: $e');
    }
  }

  void _openSideMenu(BuildContext context) {
    print('📱 Abrindo sidemenu...');
    showSideMenu(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      color: Colors.transparent, // Fundo transparente
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              // Botão "Encontrar cafeterias"
              Expanded(
                child: Container(
                  height: 70,
                  child: ElevatedButton(
                    onPressed: () {
                      print('🔥 Botão "Encontrar cafeterias" clicado!');
                      print('🔍 onSearchPressed é null? ${onSearchPressed == null}');
                      
                      // Se houver um callback personalizado, usa ele, senão navega para CafeExplorerScreen
                      if (onSearchPressed != null) {
                        print('📞 Executando onSearchPressed personalizado...');
                        onSearchPressed!();
                      } else {
                        print('🎯 Usando navegação padrão para CafeExplorerScreen...');
                        _navigateToCafeExplorer(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.papayaSensorial,
                      foregroundColor: AppColors.velvetMerlot,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                      // Adiciona um efeito visual ao pressionar
                      splashFactory: InkRipple.splashFactory,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/images/search.svg',
                          width: 24,
                          height: 24,
                          colorFilter: ColorFilter.mode(
                            AppColors.velvetMerlot,
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Encontrar cafeterias',
                          style: GoogleFonts.albertSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.velvetMerlot,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),
              
              // Botão Menu
              GestureDetector(
                onTap: () {
                  print('📱 Menu clicado!');
                  
                  // Se houver callback personalizado, usar ele; senão abrir sidemenu
                  if (onMenuPressed != null) {
                    print('📞 Executando onMenuPressed personalizado...');
                    onMenuPressed!();
                  } else {
                    print('🎯 Abrindo sidemenu padrão...');
                    _openSideMenu(context);
                  }
                },
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppColors.velvetMerlot,
                    borderRadius: BorderRadius.circular(16),
                    // Adiciona uma sombra sutil
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.velvetMerlot.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/images/menu.svg',
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        AppColors.papayaSensorial,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
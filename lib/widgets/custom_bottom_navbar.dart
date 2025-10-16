import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../utils/app_icons.dart';
import '../ui/cafe_explorer/widgets/cafe_explorer_provider.dart';
import '../ui/add_cafe/widgets/add_cafe_provider.dart';
import 'side_menu_overlay.dart';

class CustomBottomNavbar extends StatelessWidget {
  final VoidCallback? onMenuPressed;
  final VoidCallback? onSearchPressed;
  final bool isInCafeExplorer;

  const CustomBottomNavbar({
    Key? key,
    this.onMenuPressed,
    this.onSearchPressed,
    this.isInCafeExplorer = false,
  }) : super(key: key);

  void _navigateToCafeExplorer(BuildContext context) {
    print('🚀 Navegando para CafeExplorerProvider...');
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CafeExplorerProvider(),
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

  void _navigateToAddCafe(BuildContext context) {
    print('🚀 Navegando para AddCafeProvider...');
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddCafeProvider(),
        ),
      ).then((value) {
        print('✅ Navegação para cadastro concluída com sucesso!');
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
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: Container(
          height: 90,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              // Botão principal - alterna entre "Encontrar cafeterias" e "Cadastrar cafeteria"
              Expanded(
                child: Container(
                  height: 70,
                  child: ElevatedButton(
                    onPressed: () {
                      if (isInCafeExplorer) {
                        print('🔥 Botão "Cadastrar cafeteria" clicado!');
                        _navigateToAddCafe(context);
                      } else {
                        print('🔥 Botão "Encontrar cafeterias" clicado!');
                        print('🔍 onSearchPressed é null? ${onSearchPressed == null}');
                        
                        if (onSearchPressed != null) {
                          print('📞 Executando onSearchPressed personalizado...');
                          onSearchPressed!();
                        } else {
                          print('🎯 Usando navegação padrão para CafeExplorerProvider...');
                          _navigateToCafeExplorer(context);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isInCafeExplorer ? AppColors.pear : AppColors.papayaSensorial,
                      foregroundColor: AppColors.velvetMerlot,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      splashFactory: InkRipple.splashFactory,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Box com ícone - muda baseado na tela
                        Container(
                          width: 68,
                          height: 68,
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: AppColors.whiteWhite,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Center(
                            child: Icon(
                              isInCafeExplorer 
                                  ? AppIcons.plus
                                  : AppIcons.search,
                              size: 20,
                              color: AppColors.velvetMerlot,
                            ),
                          ),
                        ),
                        
                        // Espaço flexível para centralizar o texto
                        Expanded(
                          child: Center(
                            child: Text(
                              isInCafeExplorer 
                                  ? 'Cadastrar cafeteria'
                                  : 'Encontrar cafeterias',
                              style: GoogleFonts.albertSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.velvetMerlot,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Botão Menu
              GestureDetector(
                onTap: () {
                  print('📱 Menu clicado!');
                  
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
                  ),
                  child: Center(
                    child: Icon(
                      AppIcons.menu,
                      size: 24,
                      color: AppColors.papayaSensorial,
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
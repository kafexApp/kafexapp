import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/app_colors.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Configurar animação de fade
    _animationController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Iniciar animação
    _animationController.forward();

    // Navegar para próxima tela após 3 segundos
    Future.delayed(Duration(seconds: 3), () {
      _animationController.reverse().then((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => WelcomeScreen()),
        );
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.velvetMerlot, // Fundo marrom escuro
      body: SafeArea(
        child: Column(
          children: [
            // Área principal com logo centralizado
            Expanded(
              child: Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SvgPicture.asset(
                    'assets/images/kafex_logo_negative.svg',
                    width: 200,
                    height: 80,
                  ),
                ),
              ),
            ),

            // Versão na parte inferior
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'versão 1.0',
                  style: TextStyle(
                    fontFamily: 'Albert Sans',
                    fontSize: 14,
                    color: AppColors.whiteWhite.withOpacity(0.6),
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
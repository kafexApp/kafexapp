import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/app_colors.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _backgroundController;
  late AnimationController _textController;
  late AnimationController _exitController;

  late Animation<double> _logoOpacity;
  
  late Animation<double> _backgroundGradient;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  
  late Animation<double> _exitFade;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimationSequence();
  }

  void _initAnimations() {
    // Controller para logo (800ms)
    _logoController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    // Controller para background (2 segundos)
    _backgroundController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    // Controller para texto (1 segundo)
    _textController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    // Controller para saída (500ms)
    _exitController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    // Animações do logo
    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut,
    ));

    // Animação do background
    _backgroundGradient = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));

    // Animações do texto
    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeInOut,
    ));

    _textSlide = Tween<Offset>(
      begin: Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutQuart,
    ));

    // Animação de saída
    _exitFade = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _exitController,
      curve: Curves.easeInQuart,
    ));
  }

  void _startAnimationSequence() async {
    // Iniciar background imediatamente
    _backgroundController.forward();
    
    // Aguardar 200ms e iniciar logo
    await Future.delayed(Duration(milliseconds: 200));
    _logoController.forward();
    
    // Aguardar 800ms e iniciar texto
    await Future.delayed(Duration(milliseconds: 800));
    _textController.forward();
    
    // Aguardar mais 1.5 segundos e fazer transição
    await Future.delayed(Duration(milliseconds: 1500));
    
    // Iniciar animação de saída
    _exitController.forward();
    
    // Navegar após animação de saída
    await Future.delayed(Duration(milliseconds: 500));
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => WelcomeScreen(),
          transitionDuration: Duration(milliseconds: 400),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutQuart,
                )),
                child: child,
              ),
            );
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _backgroundController.dispose();
    _textController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _logoController,
          _backgroundController,
          _textController,
          _exitController,
        ]),
        builder: (context, child) {
          return FadeTransition(
            opacity: _exitFade,
            child: Container(
              width: screenWidth,
              height: screenHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.lerp(
                      AppColors.velvetMerlot,
                      AppColors.velvetBourbon,
                      _backgroundGradient.value * 0.3,
                    )!,
                    AppColors.velvetMerlot,
                    Color.lerp(
                      AppColors.velvetMerlot,
                      Colors.black,
                      _backgroundGradient.value * 0.2,
                    )!,
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
              child: Stack(
                children: [
                  // Efeito de partículas de fundo
                  ...List.generate(20, (index) {
                    final delay = index * 0.1;
                    final opacity = (_backgroundGradient.value - delay).clamp(0.0, 1.0);
                    return Positioned(
                      left: (index % 4) * screenWidth / 4 + (screenWidth / 8),
                      top: (index ~/ 4) * screenHeight / 5 + (screenHeight / 10),
                      child: Opacity(
                        opacity: opacity * 0.1,
                        child: Container(
                          width: 2,
                          height: 2,
                          decoration: BoxDecoration(
                            color: AppColors.roseClay,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.roseClay.withOpacity(0.3),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  // Área principal com logo
                  SafeArea(
                    child: Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: FadeTransition(
                              opacity: _logoOpacity,
                              child: SvgPicture.asset(
                                'assets/images/kafex_logo_negative.svg',
                                width: 168,
                                height: 70,
                              ),
                            ),
                          ),
                        ),

                        // Área do texto da versão
                        SlideTransition(
                          position: _textSlide,
                          child: FadeTransition(
                            opacity: _textOpacity,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 60.0),
                              child: Text(
                                'versão 3.0.0',
                                style: TextStyle(
                                  fontFamily: 'Albert Sans',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w200,
                                  color: AppColors.whiteWhite.withOpacity(0.7),
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
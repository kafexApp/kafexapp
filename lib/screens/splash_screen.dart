import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../utils/app_colors.dart';
import '../services/update_service.dart';
import '../services/auth_service.dart';
import '../utils/user_manager.dart';
import 'welcome_screen.dart';
import '../ui/home/widgets/home_screen_provider.dart';

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

  bool _hasCheckedForUpdates = false;
  String _appVersion = '...';
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
    _initAnimations();
    _startAnimationSequence();
  }

  Future<void> _loadAppVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = 'versão ${packageInfo.version}';
      });
    } catch (e) {
      print('Erro ao carregar versão do app: $e');
      setState(() {
        _appVersion = 'versão 3.0.0';
      });
    }
  }

  void _initAnimations() {
    _logoController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _textController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _exitController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut,
    ));

    _backgroundGradient = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));

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

    _exitFade = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _exitController,
      curve: Curves.easeInQuart,
    ));
  }

  void _startAnimationSequence() async {
    _backgroundController.forward();
    
    await Future.delayed(Duration(milliseconds: 200));
    _logoController.forward();
    
    await Future.delayed(Duration(milliseconds: 800));
    _textController.forward();
    
    _checkForUpdatesInBackground();
    
    await Future.delayed(Duration(milliseconds: 1500));
    
    while (!_hasCheckedForUpdates) {
      await Future.delayed(Duration(milliseconds: 100));
    }
    
    _exitController.forward();
    
    await Future.delayed(Duration(milliseconds: 500));
    
    if (mounted) {
      await _checkAuthAndNavigate();
    }
  }

  Future<void> _checkAuthAndNavigate() async {
    try {
      // Verificar se há usuário logado
      final user = _authService.currentUser;
      
      if (user != null) {
        print('✅ Usuário já logado: ${user.email}');
        
        // Restaurar dados do usuário no UserManager
        String email = user.email ?? '';
        String name = user.displayName ?? 
                     UserManager.instance.extractNameFromEmail(email);
        
        UserManager.instance.setUserData(
          uid: user.uid,
          name: name,
          email: email,
          photoUrl: user.photoURL,
        );
        
        // Navegar para tela inicial
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => HomeScreenProvider(),
            transitionDuration: Duration(milliseconds: 400),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      } else {
        print('⚠️ Nenhum usuário logado, indo para Welcome');
        
        // Navegar para tela de boas-vindas
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
    } catch (e) {
      print('❌ Erro ao verificar autenticação: $e');
      
      // Em caso de erro, ir para Welcome
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => WelcomeScreen(),
          transitionDuration: Duration(milliseconds: 400),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    }
  }

  void _checkForUpdatesInBackground() async {
    try {
      final hasUpdate = await KafexUpdateService.checkForUpdates();
      
      if (hasUpdate && mounted) {
        final currentVersion = await KafexUpdateService.getCurrentVersion();
        final newVersion = await KafexUpdateService.getAvailableVersion();
        
        if (newVersion != null) {
          KafexUpdateService.showCustomUpdateDialog(
            context: context,
            currentVersion: currentVersion,
            newVersion: newVersion,
            isRequired: false,
            onUpdate: () {
              Navigator.of(context).pop();
            },
            onLater: () {
              Navigator.of(context).pop();
            },
          );
        }
      }
    } catch (e) {
      print('Erro ao verificar atualizações: $e');
    } finally {
      _hasCheckedForUpdates = true;
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
      body: KafexUpdateService.wrapWithUpdateChecker(
        child: AnimatedBuilder(
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

                          SlideTransition(
                            position: _textSlide,
                            child: FadeTransition(
                              opacity: _textOpacity,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 60.0),
                                child: Column(
                                  children: [
                                    Text(
                                      _appVersion,
                                      style: TextStyle(
                                        fontFamily: 'Albert Sans',
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal,
                                        color: AppColors.whiteWhite.withOpacity(0.7),
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    
                                    SizedBox(height: 12),
                                    
                                    Text(
                                      'Feito com muito ☕️ e IA para amantes de café.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Albert Sans',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w300,
                                        color: AppColors.whiteWhite.withOpacity(0.6),
                                        letterSpacing: 0.5,
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
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
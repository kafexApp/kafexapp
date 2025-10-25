// lib/ui/subscription/widgets/subscription_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../utils/app_colors.dart';
import '../../../widgets/custom_buttons.dart';
import '../../../widgets/custom_app_bar.dart';
import '../viewmodel/subscription_viewmodel.dart';
import 'invitation_box.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> with TickerProviderStateMixin {
  int _currentBenefitPage = 0;
  final PageController _benefitPageController = PageController(
    viewportFraction: 0.85,
    initialPage: 0,
  );
  Timer? _autoPlayTimer;
  bool _isPaused = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // Animação pulsante do botão
    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _pulseController.repeat(reverse: true);
    
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(Duration(seconds: 4), (timer) {
      if (!_isPaused && _benefitPageController.hasClients) {
        final nextPage = (_currentBenefitPage + 1) % 5; // 5 é o total de benefícios
        _benefitPageController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _pauseAutoPlay() {
    setState(() {
      _isPaused = true;
    });
  }

  void _resumeAutoPlay() {
    setState(() {
      _isPaused = false;
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _benefitPageController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SubscriptionViewModel(),
      child: Scaffold(
        backgroundColor: AppColors.whiteWhite,
        appBar: CustomAppBar(
          showBackButton: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Banner com pattern no topo
              _buildTopBanner(),
              
              // Logo do clube
              _buildClubLogo(),
              
              // Título
              _buildTitle(),
                
              // Descrição
              _buildDescription(),
              
              // Benefícios
              _buildBenefitsSection(),
              
              // Preço
              _buildPriceSection(),
              
              // Botão de assinatura
              _buildSubscribeButton(context),
              
              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBanner() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/pattern-kafex-top-banner.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildClubLogo() {
    return Padding(
      padding: EdgeInsets.only(top: 24, bottom: 16),
      child: Image.asset(
        'assets/images/logo-clube-da-xicara-kafex.png',
        width: 240,
        height: 96,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        'O que é o clube?',
        style: GoogleFonts.albertSans(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.carbon,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Text(
        'O Clube da Xícara dá acesso a benefícios exclusivos em cafeterias e marcas parceiras todo mês.',
        style: GoogleFonts.albertSans(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.grayScale2,
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildBenefitsSection() {
    final benefits = [
      'Uma bebida grátis em cada cafeteria todo mês',
      'Um pacote surpresa de 250g de café especial por mês',
      '30 filtros de V60 por mês',
      'Brindes exclusivos de parceiros',
      'Descontos em produtos de marcas parceiras',
    ];
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Quais benefícios você irá receber ao se tornar membro?',
              style: GoogleFonts.albertSans(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.carbon,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 20),
          
          // Carrossel de benefícios
          GestureDetector(
            onPanDown: (_) => _pauseAutoPlay(),
            onPanEnd: (_) => _resumeAutoPlay(),
            onPanCancel: () => _resumeAutoPlay(),
            child: SizedBox(
              height: 120,
              child: PageView.builder(
                controller: _benefitPageController,
                physics: PageScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentBenefitPage = index;
                  });
                },
                itemCount: benefits.length,
                itemBuilder: (context, index) {
                  return AnimatedBuilder(
                    animation: _benefitPageController,
                    builder: (context, child) {
                      double value = 1.0;
                      if (_benefitPageController.position.haveDimensions) {
                        value = _benefitPageController.page! - index;
                        value = (1 - (value.abs() * 0.15)).clamp(0.85, 1.0);
                      }
                      return Center(
                        child: SizedBox(
                          height: Curves.easeInOut.transform(value) * 120,
                          child: child,
                        ),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: _buildBenefitItem(benefits[index]),
                    ),
                  );
                },
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          // Bullets indicadores
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              benefits.length,
              (index) => AnimatedContainer(
                duration: Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: 4),
                width: _currentBenefitPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentBenefitPage == index 
                      ? AppColors.papayaSensorial 
                      : AppColors.grayScale2.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.moonAsh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/check-icon.png',
            width: 40,
            height: 40,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.albertSans(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.carbon,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.oatWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.moonAsh,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Quanto você paga por isso?',
            style: GoogleFonts.albertSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.carbon,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'R\$ 67,90',
            style: GoogleFonts.albertSans(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: AppColors.grayScale2,
              decoration: TextDecoration.lineThrough,
              decorationColor: AppColors.grayScale2,
              decorationThickness: 2,
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'R\$',
                style: GoogleFonts.albertSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.velvetMerlot,
                ),
              ),
              Text(
                '37,90',
                style: GoogleFonts.albertSans(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: AppColors.velvetMerlot,
                  height: 1,
                ),
              ),
            ],
          ),
          Text(
            'por mês',
            style: GoogleFonts.albertSans(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.carbon,
            ),
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.moonAsh,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'cancele quando quiser',
              style: GoogleFonts.albertSans(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.grayScale2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscribeButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Consumer<SubscriptionViewModel>(
        builder: (context, viewModel, _) {
          return ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              width: double.infinity,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.pear.withOpacity(0.4),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => InvitationBox(),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pear,
                  foregroundColor: AppColors.carbon,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                ),
                child: Text(
                  'Quero participar do clube',
                  style: GoogleFonts.albertSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.carbon,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
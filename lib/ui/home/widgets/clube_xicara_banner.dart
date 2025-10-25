import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/app_colors.dart';
import '../../Subscription/widgets/subscription_screen.dart';

class ClubeXicaraBanner extends StatefulWidget {
  const ClubeXicaraBanner({Key? key}) : super(key: key);

  @override
  State<ClubeXicaraBanner> createState() => _ClubeXicaraBannerState();
}

class _ClubeXicaraBannerState extends State<ClubeXicaraBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubscriptionScreen(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.pear,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Image.asset(
              'assets/images/icon-clube-da-xicara.png',
              width: 72,
              height: 72,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 16),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.albertSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.carbon,
                    height: 1.4,
                  ),
                  children: [
                    TextSpan(text: 'Participe do '),
                    TextSpan(
                      text: 'Clube da Xícara',
                      style: GoogleFonts.albertSans(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: ' e ganhe benefícios exclusívos.',
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 12),
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_animation.value, 0),
                  child: Icon(
                    Icons.chevron_right,
                    color: AppColors.carbon,
                    size: 28,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
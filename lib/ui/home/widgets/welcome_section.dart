import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/user_manager.dart';
import '../../../widgets/common/user_avatar.dart';

class WelcomeSection extends StatelessWidget {
  const WelcomeSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final String firstName = _getFirstName(currentUser?.displayName);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      height: 130,
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(top: 25),
            padding: EdgeInsets.only(
              left: 16,
              right: 20,
              top: 16,
              bottom: 16,
            ),
            decoration: BoxDecoration(
              color: AppColors.whiteWhite,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(100),
                bottomLeft: Radius.circular(100),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                  borderRadius: BorderRadius.circular(100),
                  child: UserAvatar(user: currentUser, size: 76),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Olá, ',
                              style: GoogleFonts.albertSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            TextSpan(
                              text: '$firstName!',
                              style: GoogleFonts.albertSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.papayaSensorial,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        UserManager.instance.hasLocation
                            ? 'Em ${UserManager.instance.locationDisplay}'
                            : 'Que tal um cafezinho?',
                        style: GoogleFonts.albertSans(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 95),
              ],
            ),
          ),
          Positioned(
            right: 15,
            bottom: 0,
            child: SvgPicture.asset(
              'assets/images/hand-coffee.svg',
              width: 95.32,
              height: 142.09,
            ),
          ),
        ],
      ),
    );
  }

  String _getFirstName(String? fullName) {
    if (fullName == null || fullName.isEmpty) return 'Usuário';
    return fullName.split(' ').first;
  }
}
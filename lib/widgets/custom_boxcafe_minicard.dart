import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../screens/cafe_explorer_screen.dart';
import 'custom_boxcafe.dart';

class CustomBoxcafeMinicard extends StatelessWidget {
  final CafeModel cafe;
  final VoidCallback? onTap;

  const CustomBoxcafeMinicard({
    Key? key,
    required this.cafe,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showCafeModal(context, cafe);
        if (onTap != null) onTap!();
      },
      child: Container(
        height: 141, // Altura padronizada
        decoration: BoxDecoration(
          color: AppColors.whiteWhite,
          borderRadius: BorderRadius.circular(14), // 14px de radius
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // Imagem da cafeteria com radius de 8px
              Container(
                width: 109,
                height: 109,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8), // 8px de radius na foto
                  image: DecorationImage(
                    image: NetworkImage(cafe.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 16),
              
              // Informações principais
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Nome da cafeteria na cor velvet merlot
                    Text(
                      cafe.name,
                      style: GoogleFonts.albertSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.velvetMerlot, // Cor velvet merlot
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    
                    // Rating com ícone grain_note.svg
                    Row(
                      children: [
                        Text(
                          '${cafe.rating}',
                          style: GoogleFonts.albertSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.grayScale2,
                          ),
                        ),
                        SizedBox(width: 6),
                        // Usando o ícone grain_note.svg
                        ...List.generate(5, (starIndex) {
                          return Padding(
                            padding: EdgeInsets.only(right: 2),
                            child: SvgPicture.asset(
                              'assets/images/grain_note.svg',
                              width: 12,
                              height: 12,
                              colorFilter: ColorFilter.mode(
                                starIndex < cafe.rating.floor() 
                                    ? AppColors.sunsetBlaze 
                                    : AppColors.grayScale2.withOpacity(0.3),
                                BlendMode.srcIn,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                    SizedBox(height: 8),
                    
                    // Endereço na cor Gray Scale 2
                    Text(
                      cafe.address,
                      style: GoogleFonts.albertSans(
                        fontSize: 12,
                        color: AppColors.grayScale2, // Cor Gray Scale 2
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // Seta
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.grayScale2,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
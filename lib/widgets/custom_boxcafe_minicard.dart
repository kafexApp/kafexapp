import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../models/cafe_model.dart';
import '../ui/cafe_detail/widgets/cafe_detail_modal.dart';

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
        showCafeDetailModal(context, cafe);
        if (onTap != null) onTap!();
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.whiteWhite,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.only(left: 16, right: 20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: NetworkImage(cafe.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),
              
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cafe.name,
                      style: GoogleFonts.albertSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.velvetMerlot,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    
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
                    
                    Text(
                      cafe.address,
                      style: GoogleFonts.albertSans(
                        fontSize: 12,
                        color: AppColors.grayScale2,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
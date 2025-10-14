// lib/ui/cafe_detail/widgets/cafe_facility_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/cafe_facility_enum.dart';

class CafeFacilityWidget extends StatelessWidget {
  final CafeFacility facility;

  const CafeFacilityWidget({
    Key? key,
    required this.facility,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 6),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.7),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: SvgPicture.asset(
          facility.iconPath,
          width: 16,
          height: 16,
          colorFilter: ColorFilter.mode(
            Theme.of(context).colorScheme.onSecondaryContainer,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
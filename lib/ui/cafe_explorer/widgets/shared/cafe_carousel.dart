// lib/ui/cafe_explorer/widgets/shared/cafe_carousel.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../data/models/domain/cafe.dart';
import '../../../../models/cafe_model.dart';
import '../../../../widgets/custom_boxcafe_minicard.dart';

class CafeCarousel extends StatefulWidget {
  final List<Cafe> cafes;
  final ScrollController scrollController;
  final Function(LatLng position)? onCafeTap;
  final Function(int index)? onPageChanged;
  final Function(PageController controller)? onPageControllerCreated;

  const CafeCarousel({
    Key? key,
    required this.cafes,
    required this.scrollController,
    this.onCafeTap,
    this.onPageChanged,
    this.onPageControllerCreated,
  }) : super(key: key);

  @override
  State<CafeCarousel> createState() => _CafeCarouselState();
}

class _CafeCarouselState extends State<CafeCarousel> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.92,
    );
    
    // Notifica o controller assim que for criado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onPageControllerCreated?.call(_pageController);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cafes.isEmpty) return SizedBox.shrink();

    return Positioned(
      bottom: 120,
      left: 0,
      right: 0,
      child: SizedBox(
        height: 141,
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.cafes.length,
          onPageChanged: (index) {
            widget.onPageChanged?.call(index);
          },
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: CustomBoxcafeMinicard(
                cafe: _convertToOldModel(widget.cafes[index]),
                onTap: () {
                  widget.onCafeTap?.call(widget.cafes[index].position);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  CafeModel _convertToOldModel(Cafe cafe) {
    return CafeModel(
      id: cafe.id,
      name: cafe.name,
      address: cafe.address,
      rating: cafe.rating,
      distance: cafe.distance,
      imageUrl: cafe.imageUrl,
      isOpen: cafe.isOpen,
      position: cafe.position,
      price: cafe.price,
      specialties: List<String>.from(cafe.specialties),
    );
  }
}
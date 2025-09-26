import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../utils/app_colors.dart';
import '../utils/app_icons.dart';
import 'cafe_evaluation_modal.dart';

// Modelo para avaliação de usuário
class UserReview {
  final String userId;
  final String userName;
  final String userAvatar;
  final double rating;
  final String comment;
  final String date;

  UserReview({
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.comment,
    required this.date,
  });
}

// Enum para facilidades da cafeteria
enum CafeFacility {
  officeFriendly,
  petFriendly,
  vegFriendly,
}

// Modelo estendido da cafeteria para o modal
class CafeDetailModel {
  final String id;
  final String name;
  final String address;
  final double rating;
  final String imageUrl;
  final bool isOpen;
  final String openingHours;
  final String instagramHandle;
  final List<CafeFacility> facilities;
  final List<UserReview> reviews;
  final double latitude;
  final double longitude;

  CafeDetailModel({
    required this.id,
    required this.name,
    required this.address,
    required this.rating,
    required this.imageUrl,
    required this.isOpen,
    required this.openingHours,
    required this.instagramHandle,
    required this.facilities,
    required this.reviews,
    required this.latitude,
    required this.longitude,
  });

  // Conversão do CafeModel para CafeDetailModel (mock)
  static CafeDetailModel fromCafeModel(dynamic cafeModel) {
    return CafeDetailModel(
      id: cafeModel.id,
      name: cafeModel.name,
      address: cafeModel.address,
      rating: cafeModel.rating,
      imageUrl: cafeModel.imageUrl,
      isOpen: cafeModel.isOpen,
      openingHours: cafeModel.isOpen ? 'Abre ter. às 18:00' : 'Fechado',
      instagramHandle: '@${cafeModel.name.toLowerCase().replaceAll(' ', '')}',
      facilities: [
        CafeFacility.officeFriendly,
        CafeFacility.petFriendly,
        CafeFacility.vegFriendly,
      ],
      reviews: [
        UserReview(
          userId: '1',
          userName: 'Amanda Klein',
          userAvatar: 'assets/images/default-avatar.svg',
          rating: 5.0,
          comment: 'A crema realmente faz toda a diferença. É incrível como ela intensifica o sabor e a experiência.',
          date: '03/05/2024',
        ),
      ],
      latitude: cafeModel.position.latitude,
      longitude: cafeModel.position.longitude,
    );
  }
}

// Widget principal do modal com Material 3
class M3CustomBoxcafe extends StatelessWidget {
  final CafeDetailModel cafe;

  const M3CustomBoxcafe({
    Key? key,
    required this.cafe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle clean
          Container(
            margin: EdgeInsets.only(top: 12, bottom: 8),
            width: 32,
            height: 3,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Conteúdo scrollável
          Flexible(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Imagem da cafeteria - mais clean
                    _buildCleanCafeImage(context),
                    SizedBox(height: 16),
                    
                    // Header com nome, rating e Instagram - mais organizado
                    _buildCleanCafeHeader(context),
                    SizedBox(height: 12),
                    
                    // Endereço
                    _buildCleanAddress(context),
                    SizedBox(height: 16),
                    
                    // Status e facilidades - mais clean
                    _buildCleanStatusAndFacilities(context),
                    SizedBox(height: 20),
                    
                    // Última avaliação - mais clean
                    _buildCleanLastReview(context),
                    SizedBox(height: 20),
                    
                    // Título - mais clean
                    Text(
                      'O que você gostaria de fazer?',
                      style: GoogleFonts.albertSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Botões de ação - mais clean
                    _buildCleanActionButtons(context),
                    SizedBox(height: 16),
                    
                    // Botão reportar - mais clean
                    _buildCleanReportButton(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCleanCafeImage(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180, // Ligeiramente menor para ficar mais clean
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12), // Menos arredondado
        image: DecorationImage(
          image: NetworkImage(cafe.imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildCleanCafeHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nome da cafeteria
              Text(
                cafe.name,
                style: GoogleFonts.albertSans(
                  fontSize: 22, // Ligeiramente menor
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 6),
              
              // Rating com estrelas - grain_note.svg
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/grain_note.svg',
                    width: 16,
                    height: 16,
                    colorFilter: ColorFilter.mode(
                      AppColors.sunsetBlaze,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    '${cafe.rating}',
                    style: GoogleFonts.albertSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Ícone do Instagram - Phosphor
        IconButton(
          onPressed: () => _openInstagram(),
          icon: Icon(
            PhosphorIcons.instagramLogo(),
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCleanAddress(BuildContext context) {
    return Text(
      cafe.address,
      style: GoogleFonts.albertSans(
        fontSize: 14,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        height: 1.4,
      ),
    );
  }

  Widget _buildCleanStatusAndFacilities(BuildContext context) {
    return Row(
      children: [
        // Status (Aberto/Fechado) - mais clean
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: cafe.isOpen 
                ? Theme.of(context).colorScheme.primaryContainer 
                : Theme.of(context).colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            cafe.isOpen ? 'Aberto' : 'Fechado',
            style: GoogleFonts.albertSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: cafe.isOpen 
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
        ),
        
        // Horário de abertura (apenas quando fechado)
        if (!cafe.isOpen) ...[
          SizedBox(width: 8),
          Text(
            cafe.openingHours,
            style: GoogleFonts.albertSans(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        
        Spacer(),
        
        // Facilidades com ícones - mais clean e menores
        Row(
          children: cafe.facilities.map((facility) => _buildCleanFacilityIcon(facility, context)).toList(),
        ),
      ],
    );
  }

  Widget _buildCleanFacilityIcon(CafeFacility facility, BuildContext context) {
    String iconPath;
    
    switch (facility) {
      case CafeFacility.officeFriendly:
        iconPath = 'assets/images/icon-office-friendly.svg';
        break;
      case CafeFacility.petFriendly:
        iconPath = 'assets/images/icon-pet-friendly.svg';
        break;
      case CafeFacility.vegFriendly:
        iconPath = 'assets/images/icon-veg-friendly.svg';
        break;
    }
    
    return Container(
      margin: EdgeInsets.only(right: 6),
      width: 28, // Menor
      height: 28,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.7),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: SvgPicture.asset(
          iconPath,
          width: 16, // Menor
          height: 16,
          colorFilter: ColorFilter.mode(
            Theme.of(context).colorScheme.onSecondaryContainer,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }

  Widget _buildCleanLastReview(BuildContext context) {
    if (cafe.reviews.isEmpty) {
      return SizedBox.shrink();
    }
    
    final UserReview lastReview = cafe.reviews.first;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título da seção
        Text(
          'Avaliações',
          style: GoogleFonts.albertSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 12),
        
        // Comment Card M3 - com a nova cor de background
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.lightGray, // Aplicando a nova cor #f5f5f5
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header do comentário M3 - sem menu
              Row(
                children: [
                  // Avatar sem borda
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1494790108755-2616b612b17c?w=150&h=150&fit=crop&crop=face',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            PhosphorIcons.user(),
                            size: 20,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        );
                      },
                    ),
                  ),
                  
                  SizedBox(width: 12),
                  
                  // Info do usuário
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nome + Rating na mesma linha
                        Row(
                          children: [
                            Text(
                              lastReview.userName,
                              style: GoogleFonts.albertSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(width: 8),
                            // Rating com grain_note.svg
                            Row(
                              children: List.generate(5, (starIndex) {
                                return Padding(
                                  padding: EdgeInsets.only(right: 1),
                                  child: SvgPicture.asset(
                                    'assets/images/grain_note.svg',
                                    width: 12,
                                    height: 12,
                                    colorFilter: ColorFilter.mode(
                                      starIndex < lastReview.rating.floor() 
                                          ? AppColors.sunsetBlaze 
                                          : Theme.of(context).colorScheme.outlineVariant,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                        SizedBox(height: 2),
                        Text(
                          lastReview.date,
                          style: GoogleFonts.albertSans(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 12),
              
              // Conteúdo do comentário M3
              Text(
                lastReview.comment,
                style: GoogleFonts.albertSans(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.5,
                ),
              ),
              
              SizedBox(height: 16),
              
              // Ações do comentário M3 - sem responder
              Row(
                children: [
                  // Botão curtir
                  TextButton.icon(
                    onPressed: () {
                      // TODO: Curtir comentário
                    },
                    icon: Icon(
                      PhosphorIcons.heart(),
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    label: Text(
                      'Útil',
                      style: GoogleFonts.albertSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size(0, 0),
                    ),
                  ),
                  
                  Spacer(),
                  
                  // Timestamp relativo
                  Text(
                    '2 semanas atrás',
                    style: GoogleFonts.albertSans(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        SizedBox(height: 12),
        
        // Botão "Ver todas as avaliações" M3 - com grain_note.svg
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _showAllReviews(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/images/grain_note.svg',
                  width: 16,
                  height: 16,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.primary,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Ver todas as avaliações',
                  style: GoogleFonts.albertSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCleanActionButtons(BuildContext context) {
    return Column(
      children: [
        // Botão principal "Avaliar cafeteria" - mais clean
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => _rateCafe(context),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Avaliar cafeteria',
              style: GoogleFonts.albertSans(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        
        SizedBox(height: 10),
        
        // Botões secundários - Phosphor
        Row(
          children: [
            // Botão do mapa
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _openInMaps(),
                icon: Icon(PhosphorIcons.mapPin(), size: 16),
                label: Text(
                  'Mapa',
                  style: GoogleFonts.albertSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            
            SizedBox(width: 10),
            
            // Botão compartilhar
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _shareCafe(),
                icon: Icon(PhosphorIcons.shareNetwork(), size: 16),
                label: Text(
                  'Compartilhar',
                  style: GoogleFonts.albertSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCleanReportButton(BuildContext context) {
    return Container(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: () => _reportCafeChange(context),
        icon: Icon(
          PhosphorIcons.warning(),
          size: 16,
          color: Theme.of(context).colorScheme.error.withOpacity(0.8),
        ),
        label: Text(
          'Avisar que mudou de endereço ou fechou',
          style: GoogleFonts.albertSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.error.withOpacity(0.8),
          ),
        ),
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 12),
          backgroundColor: Theme.of(context).colorScheme.errorContainer.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  // Métodos de ação
  void _openInstagram() {
    print('Abrir Instagram: ${cafe.instagramHandle}');
  }

  void _showAllReviews() {
    print('Mostrar todas as avaliações da cafeteria: ${cafe.name}');
  }

  void _rateCafe(BuildContext context) {
    showCafeEvaluationModal(
      context,
      cafeName: cafe.name,
      cafeId: cafe.id,
    );
  }

  void _openInMaps() async {
    final String googleMapsUrl = 
        'https://www.google.com/maps/search/?api=1&query=${cafe.latitude},${cafe.longitude}';
    
    try {
      await launchUrl(Uri.parse(googleMapsUrl));
    } catch (e) {
      print('Erro ao abrir mapa: $e');
    }
  }

  void _shareCafe() {
    final String shareText = 
        'Olá, segue o endereço da cafeteria ${cafe.name}, ${cafe.address}. Quer conhecer mais cafeterias? Baixe o Kafex em kafex.com.br.';
    
    print('Compartilhar: $shareText');
  }

  void _reportCafeChange(BuildContext context) {
    print('Reportar alteração na cafeteria: ${cafe.name}');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Obrigado pelo aviso! Vamos verificar as informações da cafeteria.',
          style: GoogleFonts.albertSans(),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

// EXPORT da função para compatibilidade - adicione no final do arquivo original
// Para usar em outros arquivos, importe assim:
// import '../widgets/m3_custom_boxcafe.dart' show showM3CafeModal;

// Função de compatibilidade que usa o modal antigo
void showCafeModal(BuildContext context, dynamic cafeModel) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    enableDrag: true,
    builder: (context) => GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () {},
          child: DraggableScrollableSheet(
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) => Container(
              child: AbsorbPointer(
                absorbing: false,
                child: M3CustomBoxcafe(
                  cafe: CafeDetailModel.fromCafeModel(cafeModel),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:share_plus/share_plus.dart'; // Comentado temporariamente
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_colors.dart';

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
      ], // Mock - em produção viria do banco de dados
      reviews: [
        UserReview(
          userId: '1',
          userName: 'Amanda Klein',
          userAvatar: 'assets/images/default-avatar.svg',
          rating: 5.0,
          comment: 'A crema realmente faz toda a diferença. É incrível como ela intensifica o sabor e a experiência.',
          date: '03/05/2024',
        ),
      ], // Mock - em produção viria do banco de dados
      latitude: cafeModel.position.latitude,
      longitude: cafeModel.position.longitude,
    );
  }
}

// Widget principal do modal
class CustomBoxcafe extends StatelessWidget {
  final CafeDetailModel cafe;

  const CustomBoxcafe({
    Key? key,
    required this.cafe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Indicador visual de modal (barrinha no topo)
          Container(
            margin: EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grayScale2,
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
                    // Imagem da cafeteria
                    _buildCafeImage(),
                    SizedBox(height: 16),
                    
                    // Nome e rating da cafeteria + Instagram
                    _buildCafeHeader(),
                    SizedBox(height: 12),
                    
                    // Endereço
                    _buildAddress(),
                    SizedBox(height: 16),
                    
                    // Status e facilidades
                    _buildStatusAndFacilities(),
                    SizedBox(height: 20),
                    
                    // Última avaliação
                    _buildLastReview(),
                    SizedBox(height: 20),
                    
                    // Título "O que você gostaria de fazer?"
                    Text(
                      'O que você gostaria de fazer?',
                      style: GoogleFonts.albertSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.carbon,
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Botão "Avaliar cafeteria"
                    _buildRateButton(),
                    SizedBox(height: 16),
                    
                    // Botão "Avisar que mudou"
                    _buildReportButton(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCafeImage() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage(cafe.imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildCafeHeader() {
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
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.velvetMerlot,
                ),
              ),
              SizedBox(height: 4),
              
              // Rating com estrelas
              Row(
                children: [
                  Text(
                    '${cafe.rating}',
                    style: GoogleFonts.albertSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grayScale2,
                    ),
                  ),
                  SizedBox(width: 8),
                  ...List.generate(5, (starIndex) {
                    return Padding(
                      padding: EdgeInsets.only(right: 2),
                      child: SvgPicture.asset(
                        'assets/images/grain_note.svg',
                        width: 16,
                        height: 16,
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
            ],
          ),
        ),
        
        // Ícone do Instagram
        GestureDetector(
          onTap: () => _openInstagram(),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.whiteWhite,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.oatWhite,
                width: 1,
              ),
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/images/instagram.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  AppColors.papayaSensorial,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddress() {
    return Text(
      cafe.address,
      style: GoogleFonts.albertSans(
        fontSize: 14,
        color: AppColors.grayScale1,
        height: 1.4,
      ),
    );
  }

  Widget _buildStatusAndFacilities() {
    return Row(
      children: [
        // Status (Aberto/Fechado) - apenas a palavra
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: cafe.isOpen ? AppColors.cyberLime : AppColors.spiced,
            borderRadius: BorderRadius.circular(1000),
          ),
          child: Text(
            cafe.isOpen ? 'Aberto' : 'Fechado',
            style: GoogleFonts.albertSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: cafe.isOpen ? AppColors.carbon : AppColors.whiteWhite,
            ),
          ),
        ),
        
        // Horário de abertura (apenas quando fechado)
        if (!cafe.isOpen) ...[
          SizedBox(width: 8),
          Text(
            cafe.openingHours,
            style: GoogleFonts.albertSans(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.grayScale1,
            ),
          ),
        ],
        
        Spacer(),
        
        // Facilidades
        Row(
          children: cafe.facilities.map((facility) => _buildFacilityIcon(facility)).toList(),
        ),
      ],
    );
  }

  Widget _buildFacilityIcon(CafeFacility facility) {
    String iconPath;
    Color iconColor = AppColors.pear;
    
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
      margin: EdgeInsets.only(right: 8),
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: iconColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: SvgPicture.asset(
          iconPath,
          width: 18,
          height: 18,
          colorFilter: ColorFilter.mode(
            AppColors.carbon,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }

  Widget _buildLastReview() {
    if (cafe.reviews.isEmpty) {
      return SizedBox.shrink();
    }
    
    final UserReview lastReview = cafe.reviews.first;
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.moonAsh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar e info do usuário
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.moonAsh,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/images/default-avatar.svg',
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lastReview.userName,
                      style: GoogleFonts.albertSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.carbon,
                      ),
                    ),
                    Text(
                      lastReview.date,
                      style: GoogleFonts.albertSans(
                        fontSize: 12,
                        color: AppColors.grayScale2,
                      ),
                    ),
                  ],
                ),
              ),
              // Rating do usuário
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
                            : AppColors.grayScale2.withOpacity(0.3),
                        BlendMode.srcIn,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          
          SizedBox(height: 12),
          
          // Comentário da avaliação
          Text(
            lastReview.comment,
            style: GoogleFonts.albertSans(
              fontSize: 14,
              color: AppColors.grayScale1,
              height: 1.4,
            ),
          ),
          
          SizedBox(width: 12),
          
          // Botão "Ver todas as avaliações"
          GestureDetector(
            onTap: () => _showAllReviews(),
            child: Container(
              margin: EdgeInsets.only(top: 12),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.oatWhite,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/images/grain_note.svg',
                    width: 16,
                    height: 16,
                    colorFilter: ColorFilter.mode(
                      AppColors.papayaSensorial,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'ver todas as avaliações',
                    style: GoogleFonts.albertSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.carbon,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateButton() {
    return Row(
      children: [
        // Botão "Avaliar cafeteria" - ocupa 3/5 do espaço (60%)
        Expanded(
          flex: 3,
          child: Container(
            height: 56,
            child: ElevatedButton(
              onPressed: () => _rateCafe(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.velvetMerlot,
                foregroundColor: AppColors.papayaSensorial,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Avaliar cafeteria',
                style: GoogleFonts.albertSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.papayaSensorial,
                ),
              ),
            ),
          ),
        ),
        
        SizedBox(width: 12),
        
        // Botão do mapa - ocupa 1/5 do espaço (20%)
        Expanded(
          flex: 1,
          child: Container(
            height: 56,
            child: ElevatedButton(
              onPressed: () => _openInMaps(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.whiteWhite,
                foregroundColor: AppColors.carbon,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppColors.moonAsh, width: 1),
                ),
                elevation: 0,
              ),
              child: SvgPicture.asset(
                'assets/images/map-marker.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  AppColors.carbon,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
        
        SizedBox(width: 12),
        
        // Botão compartilhar - ocupa 1/5 do espaço (20%)
        Expanded(
          flex: 1,
          child: Container(
            height: 56,
            child: ElevatedButton(
              onPressed: () => _shareCafe(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.papayaSensorial,
                foregroundColor: AppColors.whiteWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: SvgPicture.asset(
                'assets/images/share.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  AppColors.whiteWhite,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        // Botão do mapa
        Expanded(
          child: Container(
            height: 56,
            child: ElevatedButton(
              onPressed: () => _openInMaps(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.whiteWhite,
                foregroundColor: AppColors.carbon,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppColors.moonAsh, width: 1),
                ),
                elevation: 0,
              ),
              child: Icon(
                Icons.location_on,
                size: 24,
                color: AppColors.carbon,
              ),
            ),
          ),
        ),
        
        SizedBox(width: 12),
        
        // Botão compartilhar
        Expanded(
          child: Container(
            height: 56,
            child: ElevatedButton(
              onPressed: () => _shareCafe(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.papayaSensorial,
                foregroundColor: AppColors.whiteWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Icon(
                Icons.share,
                size: 24,
                color: AppColors.whiteWhite,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReportButton(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.moonAsh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: GestureDetector(
        onTap: () => _reportCafeChange(context),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/alert.svg',
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                AppColors.spiced,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(width: 8),
            Text(
              'Avisar que mudou de endereço ou fechou',
              style: GoogleFonts.albertSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.carbon,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Métodos de ação
  void _openInstagram() {
    // TODO: Abrir Instagram da cafeteria
    print('Abrir Instagram: ${cafe.instagramHandle}');
  }

  void _showAllReviews() {
    // TODO: Mostrar todas as avaliações em outro modal
    print('Mostrar todas as avaliações da cafeteria: ${cafe.name}');
  }

  void _rateCafe() {
    // TODO: Navegar para tela de avaliação
    print('Avaliar cafeteria: ${cafe.name}');
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
    
    // Por enquanto apenas imprime no console
    // TODO: Implementar compartilhamento quando share_plus estiver funcionando
    print('Compartilhar: $shareText');
  }

  void _reportCafeChange(BuildContext context) {
    // TODO: Marcar cafeteria como "Alteração" no banco de dados
    print('Reportar alteração na cafeteria: ${cafe.name}');
    
    // Mostrar confirmação para o usuário
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Obrigado pelo aviso! Vamos verificar as informações da cafeteria.',
          style: GoogleFonts.albertSans(
            color: AppColors.whiteWhite,
          ),
        ),
        backgroundColor: AppColors.velvetMerlot,
        duration: Duration(seconds: 3),
      ),
    );
  }
}

// Função helper para mostrar o modal
void showCafeModal(BuildContext context, dynamic cafeModel) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: true, // Permite fechar tocando fora
    enableDrag: true, // Permite arrastar para fechar
    builder: (context) => GestureDetector(
      // Detecta toques fora do modal para fechá-lo
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        color: Colors.transparent,
        child: GestureDetector(
          // Impede que toques no modal se propaguem para o GestureDetector pai
          onTap: () {},
          child: DraggableScrollableSheet(
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) => Container(
              // Container que absorve todos os gestos para não interferir no mapa
              child: AbsorbPointer(
                absorbing: false,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.whiteWhite,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: CustomBoxcafe(
                    cafe: CafeDetailModel.fromCafeModel(cafeModel),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
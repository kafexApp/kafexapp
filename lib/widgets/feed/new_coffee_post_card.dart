import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_icons.dart';
import '../../models/post_models.dart';
import '../comments_bottom_sheet.dart';
import '../cafe_evaluation_modal.dart';
import '../custom_toast.dart';
import '../custom_boxcafe.dart';
import '../../screens/user_profile_screen.dart';
import 'base_post_card.dart';

// Classes mock para compatibilidade com o CustomBoxcafe
class MockLatLng {
  final double latitude;
  final double longitude;

  MockLatLng(this.latitude, this.longitude);
}

class MockCafeModel {
  final String id;
  final String name;
  final String address;
  final double rating;
  final String imageUrl;
  final bool isOpen;
  final MockLatLng position;

  MockCafeModel({
    required this.id,
    required this.name,
    required this.address,
    required this.rating,
    required this.imageUrl,
    required this.isOpen,
    required this.position,
  });
}

class NewCoffeePostCard extends BasePostCard {
  final String coffeeName;
  final String coffeeAddress;
  final String coffeeId;
  final VoidCallback? onEvaluateNow;

  const NewCoffeePostCard({
    Key? key,
    required PostData post,
    required this.coffeeName,
    required this.coffeeAddress,
    required this.coffeeId,
    this.onEvaluateNow,
    VoidCallback? onLike,
    VoidCallback? onComment,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) : super(
          key: key,
          post: post,
          onLike: onLike,
          onComment: onComment,
          onEdit: onEdit,
          onDelete: onDelete,
        );

  @override
  State<NewCoffeePostCard> createState() => _NewCoffeePostCardState();
}

class _NewCoffeePostCardState extends BasePostCardState<NewCoffeePostCard> {
  bool _isFavorite = false;
  bool _wantToVisit = false;

  void _openEvaluationModal() {
    showCafeEvaluationModal(
      context,
      cafeName: widget.coffeeName,
      cafeId: widget.coffeeId,
    );
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    
    if (_isFavorite) {
      print('Adicionou ${widget.coffeeName} aos favoritos');
      CustomToast.show(
        context,
        message: 'Essa cafeteria foi adicionada em sua lista de cafeterias favoritas.',
        type: ToastType.success,
        customIcon: Icon(AppIcons.starFill, color: AppColors.cyberLime, size: 20),
      );
    } else {
      print('Removeu ${widget.coffeeName} dos favoritos');
      CustomToast.show(
        context,
        message: 'Essa cafeteria foi removida da sua lista de cafeterias favoritas.',
        type: ToastType.info,
        customIcon: Icon(AppIcons.star, color: AppColors.cyberLime, size: 20),
      );
    }
  }

  void _openCafeModal() {
    final mockCafeModel = MockCafeModel(
      id: widget.coffeeId,
      name: widget.coffeeName,
      address: widget.coffeeAddress,
      rating: 4.5,
      imageUrl: widget.post.imageUrl ?? 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb',
      isOpen: true,
      position: MockLatLng(-23.5505, -46.6333),
    );

    showCafeModal(context, mockCafeModel);
  }

  void _toggleWantToVisit() {
    setState(() {
      _wantToVisit = !_wantToVisit;
    });
    
    if (_wantToVisit) {
      print('Adicionou ${widget.coffeeName} à lista "Quero visitar"');
      CustomToast.show(
        context,
        message: 'Essa cafeteria foi adicionada em sua lista de cafeterias que gostaria de visitar.',
        type: ToastType.success,
        customIcon: Icon(AppIcons.tagFill, color: AppColors.cyberLime, size: 20),
      );
    } else {
      print('Removeu ${widget.coffeeName} da lista "Quero visitar"');
      CustomToast.show(
        context,
        message: 'Essa cafeteria foi removida da sua lista de cafeterias que gostaria de visitar.',
        type: ToastType.info,
        customIcon: Icon(AppIcons.tag, color: AppColors.cyberLime, size: 20),
      );
    }
  }

  // Sobrescrever buildPostContent para não renderizar o conteúdo padrão
  @override
  Widget buildPostContent() {
    return SizedBox.shrink(); // Não renderiza nada
  }

  // Sobrescrever buildPostMedia para adicionar a tag "NOVA CAFETERIA"
  @override
  Widget buildPostMedia() {
    final hasValidImage = widget.post.imageUrl != null && 
                         widget.post.imageUrl!.isNotEmpty && 
                         widget.post.imageUrl!.startsWith('http');
    
    if (!hasValidImage) {
      return SizedBox.shrink();
    }

    return Stack(
      children: [
        // Usar o buildPostMedia da classe base (que já tem duplo clique e animação)
        super.buildPostMedia(),
        
        // Adicionar apenas a tag "NOVA CAFETERIA"
        Positioned(
          top: 16,
          left: 32,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.pear,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  AppIcons.fire,
                  color: AppColors.carbon,
                  size: 14,
                ),
                SizedBox(width: 6),
                Text(
                  'NOVA CAFETERIA',
                  style: GoogleFonts.albertSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.carbon,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget? buildAdditionalContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // DESCRIÇÃO
        Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.albertSans(
                fontSize: 14,
                color: AppColors.carbon,
                height: 1.4,
              ),
              children: [
                TextSpan(
                  text: widget.post.authorName,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: ' '),
                TextSpan(
                  text: 'Acabei de cadastrar uma nova cafeteria. Já conhece a ${widget.coffeeName}? Então deixe a sua avaliação.',
                ),
              ],
            ),
          ),
        ),
        
        // BOX COM INFORMAÇÕES DA CAFETERIA
        Container(
          margin: EdgeInsets.fromLTRB(16, 12, 16, 0),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.moonAsh,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nome da cafeteria
              Row(
                children: [
                  Icon(
                    AppIcons.coffee,
                    color: AppColors.papayaSensorial,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _openCafeModal(),
                      child: Text(
                        widget.coffeeName,
                        style: GoogleFonts.albertSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.carbon,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 8),
              
              // Endereço
              Row(
                children: [
                  Icon(
                    AppIcons.location,
                    color: AppColors.grayScale2,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.coffeeAddress,
                      style: GoogleFonts.albertSans(
                        fontSize: 14,
                        color: AppColors.grayScale1,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // BOTÕES DE AÇÃO (FAVORITO E QUERO VISITAR)
        Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              // Botão Favorito
              Expanded(
                child: GestureDetector(
                  onTap: _toggleFavorite,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: _isFavorite ? AppColors.papayaSensorial : AppColors.moonAsh,
                      borderRadius: BorderRadius.circular(12),
                      border: _isFavorite 
                        ? Border.all(color: AppColors.papayaSensorial, width: 1)
                        : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isFavorite ? AppIcons.starFill : AppIcons.star,
                          color: _isFavorite ? AppColors.whiteWhite : AppColors.carbon,
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Text(
                          _isFavorite ? 'Favoritado' : 'Favoritar',
                          style: GoogleFonts.albertSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _isFavorite ? AppColors.whiteWhite : AppColors.carbon,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              SizedBox(width: 12),
              
              // Botão Quero Visitar
              Expanded(
                child: GestureDetector(
                  onTap: _toggleWantToVisit,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: _wantToVisit ? AppColors.pear : AppColors.moonAsh,
                      borderRadius: BorderRadius.circular(12),
                      border: _wantToVisit 
                        ? Border.all(color: AppColors.pear, width: 1)
                        : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _wantToVisit ? AppIcons.tagFill : AppIcons.tag,
                          color: _wantToVisit ? AppColors.velvetMerlot : AppColors.carbon,
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Text(
                          _wantToVisit ? 'Na lista!' : 'Quero visitar',
                          style: GoogleFonts.albertSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _wantToVisit ? AppColors.velvetMerlot : AppColors.carbon,
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
        
        // BOTÃO AVALIAR CAFETERIA
        Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: GestureDetector(
            onTap: _openEvaluationModal,
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.velvetMerlot,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  'Avaliar cafeteria',
                  style: GoogleFonts.albertSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.papayaSensorial,
                  ),
                ),
              ),
            ),
          ),
        ),
        
        // CONTADOR DE COMENTÁRIOS
        if (widget.post.comments > 0)
          Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: GestureDetector(
              onTap: () {
                widget.onComment?.call();
                showCommentsModal(
                  context,
                  postId: widget.post.id,
                  comments: [],
                  onCommentAdded: (newComment) {
                    print('Novo comentário adicionado: $newComment');
                  },
                );
              },
              child: Text(
                'Ver ${widget.post.comments == 1 ? '1 comentário' : 'todos os ${widget.post.comments} comentários'}',
                style: GoogleFonts.albertSans(
                  fontSize: 14,
                  color: AppColors.grayScale1,
                ),
              ),
            ),
          )
        else
          SizedBox(height: 16),
      ],
    );
  }
}
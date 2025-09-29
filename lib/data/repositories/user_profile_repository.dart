import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kafex/data/models/domain/user_profile.dart';
import 'package:kafex/data/models/domain/profile_tab_data.dart';
import 'package:kafex/models/cafe_model.dart';
import 'package:kafex/utils/result.dart';
import 'package:kafex/backend/supabase/tables/feed_com_usuario.dart';

abstract class UserProfileRepository {
  Future<Result<UserProfile>> getUserProfile(String userId);
  Future<Result<ProfileTabData>> getProfileTabData(String userId);
}

class UserProfileRepositoryImpl implements UserProfileRepository {
  @override
  Future<Result<UserProfile>> getUserProfile(String userId) async {
    try {
      await Future.delayed(Duration(milliseconds: 500));
      
      final profile = UserProfile(
        id: userId,
        name: _extractNameFromUserId(userId),
        avatar: null,
        bio: 'Coffeelover ☕️',
        postsCount: 2,
        favoritesCount: 2,
        wantToVisitCount: 1,
      );
      
      return Result.ok(profile);
    } catch (e) {
      return Result.error(Exception('Erro ao carregar perfil do usuário: $e'));
    }
  }

  @override
  Future<Result<ProfileTabData>> getProfileTabData(String userId) async {
    try {
      await Future.delayed(Duration(milliseconds: 800));
      
      final userName = _extractNameFromUserId(userId);
      
      final userPosts = [
        Post(
          id: '1',
          authorName: userName,
          authorAvatar: null,
          content: 'Descobri um café incrível hoje! O ambiente é aconchegante e o espresso é excepcional.',
          imageUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=400',
          createdAt: DateTime.now().subtract(Duration(hours: 2)),
          likes: 12,
          commentsCount: 8,
          isLiked: false,
        ),
        Post(
          id: '2',
          authorName: userName,
          authorAvatar: null,
          content: 'Domingo perfeito experimentando diferentes métodos de preparo de café.',
          imageUrl: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400',
          createdAt: DateTime.now().subtract(Duration(days: 1)),
          likes: 24,
          commentsCount: 3,
          isLiked: false,
        ),
      ];

      final favoriteCafes = [
        CafeModel(
          id: '1',
          name: 'Coffee Lab',
          address: 'Vila Madalena, São Paulo - SP, 05416-001',
          rating: 4.8,
          distance: '0.8 km',
          imageUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=300',
          isOpen: true,
          position: LatLng(-23.5505, -46.6333),
          price: 'R\$ 15-25',
          specialties: ['Espresso', 'V60', 'Chemex', 'Cold Brew'],
        ),
        CafeModel(
          id: '2',
          name: 'Café Girondino',
          address: 'Centro, São Paulo - SP, 01310-100',
          rating: 4.5,
          distance: '1.2 km',
          imageUrl: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=300',
          isOpen: true,
          position: LatLng(-23.5611, -46.6564),
          price: 'R\$ 8-25',
          specialties: ['Café Tradicional', 'Doces Caseiros', 'Pão de Açúcar'],
        ),
      ];

      final wantToVisitCafes = [
        CafeModel(
          id: '3',
          name: 'Bourbon Coffee',
          address: 'Jardins, São Paulo - SP, 01401-001',
          rating: 4.6,
          distance: '2.1 km',
          imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300',
          isOpen: true,
          position: LatLng(-23.5729, -46.6520),
          price: 'R\$ 20-45',
          specialties: ['Bourbon Santos', 'Cappuccino Artesanal', 'French Press'],
        ),
      ];
      
      final tabData = ProfileTabData(
        userPosts: userPosts,
        favoriteCafes: favoriteCafes,
        wantToVisitCafes: wantToVisitCafes,
      );
      
      return Result.ok(tabData);
    } catch (e) {
      return Result.error(Exception('Erro ao carregar dados das abas: $e'));
    }
  }

  String _extractNameFromUserId(String userId) {
    if (userId.contains('@')) {
      return userId.split('@')[0].replaceAll('.', ' ').split(' ')
          .map((word) => word.isNotEmpty ? 
               '${word[0].toUpperCase()}${word.substring(1)}' : word)
          .join(' ');
    }
    return userId;
  }
}
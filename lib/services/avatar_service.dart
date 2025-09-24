// lib/services/avatar_service.dart
class AvatarService {
  /// Otimiza URLs de avatar baseado no provider
  static String? optimizePhotoUrl(String? url, {int size = 200}) {
    if (url == null || url.isEmpty) return null;
    
    // Google Photos/Drive
    if (url.contains('googleusercontent.com')) {
      final baseUrl = url.split('=')[0];
      return '$baseUrl=s$size-c';
    }
    
    // Facebook/Meta
    if (url.contains('facebook.com') || url.contains('fbcdn.net')) {
      return '$url?width=$size&height=$size';
    }
    
    // GitHub
    if (url.contains('avatars.githubusercontent.com')) {
      return '$url?s=$size';
    }
    
    // URL genérica - retorna como está
    return url;
  }

  /// Gera iniciais do nome do usuário
  static String generateInitials(String? fullName) {
    if (fullName == null || fullName.isEmpty) return 'U';
    
    final nameParts = fullName.trim().split(' ');
    if (nameParts.length == 1) {
      return nameParts[0].substring(0, 1).toUpperCase();
    }
    
    final firstInitial = nameParts.first.substring(0, 1);
    final lastInitial = nameParts.last.substring(0, 1);
    return (firstInitial + lastInitial).toUpperCase();
  }

  /// Gera cor do avatar baseada no nome
  static Color generateAvatarColor(String? name) {
    if (name == null || name.isEmpty) return const Color(0xFFE57373);
    
    final colors = [
      const Color(0xFFE57373), // Red
      const Color(0xFF81C784), // Green  
      const Color(0xFF64B5F6), // Blue
      const Color(0xFFBA68C8), // Purple
      const Color(0xFFFFB74D), // Orange
      const Color(0xFF4DD0E1), // Cyan
      const Color(0xFFF06292), // Pink
      const Color(0xFFAED581), // Light Green
    ];
    
    final index = name.codeUnitAt(0) % colors.length;
    return colors[index];
  }
}
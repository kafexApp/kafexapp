import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<NotificationItem> notifications = [
    NotificationItem(
      id: '1',
      type: NotificationType.newPlace,
      title: 'Nova cafeteria descoberta!',
      message: 'Encontramos "Café do Centro" perto de você. Que tal dar uma conferida?',
      time: DateTime.now().subtract(Duration(minutes: 30)),
      isRead: false,
      icon: 'assets/images/coffee_cup.svg',
    ),
    NotificationItem(
      id: '2',
      type: NotificationType.promotion,
      title: 'Desconto especial! ☕️',
      message: 'A "Cafeteria Bourbon" está com 15% de desconto para usuários do Kafex!',
      time: DateTime.now().subtract(Duration(hours: 2)),
      isRead: false,
      icon: 'assets/images/discount.svg',
    ),
    NotificationItem(
      id: '3',
      type: NotificationType.review,
      title: 'Sua avaliação foi útil!',
      message: 'Sua avaliação sobre "Coffee Lab" já teve 12 curtidas da comunidade.',
      time: DateTime.now().subtract(Duration(hours: 5)),
      isRead: true,
      icon: 'assets/images/star.svg',
    ),
    NotificationItem(
      id: '4',
      type: NotificationType.appUpdate,
      title: 'Kafex atualizado!',
      message: 'Nova versão disponível com melhorias na busca e novos filtros.',
      time: DateTime.now().subtract(Duration(days: 1)),
      isRead: true,
      icon: 'assets/images/update.svg',
    ),
    NotificationItem(
      id: '5',
      type: NotificationType.community,
      title: 'Novo seguidor',
      message: 'Maria Silva começou a seguir suas avaliações de cafeterias.',
      time: DateTime.now().subtract(Duration(days: 2)),
      isRead: true,
      icon: 'assets/images/user.svg',
    ),
  ];

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  void markAsRead(String id) {
    setState(() {
      final notification = notifications.firstWhere((n) => n.id == id);
      notification.isRead = true;
    });
  }

  void markAllAsRead() {
    setState(() {
      for (var notification in notifications) {
        notification.isRead = true;
      }
    });
  }

  void deleteNotification(String id) {
    setState(() {
      notifications.removeWhere((n) => n.id == id);
    });
  }

  String formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.oatWhite,
      appBar: AppBar(
        backgroundColor: AppColors.oatWhite,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.carbon,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notificações',
          style: GoogleFonts.albertSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.carbon,
          ),
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: markAllAsRead,
              child: Text(
                'Marcar todas',
                style: GoogleFonts.albertSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.velvetMerlot,
                ),
              ),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                if (unreadCount > 0)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.papayaSensorial.withOpacity(0.1),
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.papayaSensorial.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Text(
                      '$unreadCount notificação${unreadCount > 1 ? 'ões' : ''} não lida${unreadCount > 1 ? 's' : ''}',
                      style: GoogleFonts.albertSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.papayaSensorial,
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 8),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return _buildNotificationItem(notification);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.moonAsh,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_outlined,
              size: 60,
              color: AppColors.grayScale2,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Nenhuma notificação',
            style: GoogleFonts.albertSans(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.carbon,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Quando houver novidades sobre cafeterias\ne promoções, você verá aqui.',
            textAlign: TextAlign.center,
            style: GoogleFonts.albertSans(
              fontSize: 14,
              color: AppColors.grayScale1,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(NotificationItem notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 24),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.spiced,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.delete_outline,
          color: AppColors.whiteWhite,
          size: 24,
        ),
      ),
      onDismissed: (direction) {
        deleteNotification(notification.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notificação removida'),
            backgroundColor: AppColors.carbon,
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: notification.isRead ? AppColors.whiteWhite : AppColors.whiteWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notification.isRead
                ? AppColors.moonAsh
                : AppColors.papayaSensorial.withOpacity(0.3),
            width: notification.isRead ? 1 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.grayScale2.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: EdgeInsets.all(16),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getNotificationColor(notification.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getNotificationIcon(notification.type),
              color: _getNotificationColor(notification.type),
              size: 24,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  notification.title,
                  style: GoogleFonts.albertSans(
                    fontSize: 16,
                    fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w600,
                    color: AppColors.carbon,
                  ),
                ),
              ),
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.papayaSensorial,
                    shape: BoxShape.circle,
                  ),
                ),
              SizedBox(width: 8),
              Text(
                formatTime(notification.time),
                style: GoogleFonts.albertSans(
                  fontSize: 12,
                  color: AppColors.grayScale2,
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              notification.message,
              style: GoogleFonts.albertSans(
                fontSize: 14,
                color: AppColors.grayScale1,
                height: 1.3,
              ),
            ),
          ),
          onTap: () {
            if (!notification.isRead) {
              markAsRead(notification.id);
            }
            // Aqui você pode adicionar navegação específica baseada no tipo
            _handleNotificationTap(notification);
          },
        ),
      ),
    );
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.newPlace:
        return AppColors.forestInk;
      case NotificationType.promotion:
        return AppColors.papayaSensorial;
      case NotificationType.review:
        return AppColors.pear;
      case NotificationType.appUpdate:
        return AppColors.eletricBlue;
      case NotificationType.community:
        return AppColors.softRose;
      default:
        return AppColors.grayScale1;
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.newPlace:
        return Icons.location_on_outlined;
      case NotificationType.promotion:
        return Icons.local_offer_outlined;
      case NotificationType.review:
        return Icons.star_outline;
      case NotificationType.appUpdate:
        return Icons.system_update_outlined;
      case NotificationType.community:
        return Icons.people_outline;
      default:
        return Icons.notifications_outlined;
    }
  }

  void _handleNotificationTap(NotificationItem notification) {
    // Aqui você pode implementar navegação específica para cada tipo de notificação
    switch (notification.type) {
      case NotificationType.newPlace:
        // Navegar para detalhes da cafeteria
        print('Abrir detalhes da cafeteria');
        break;
      case NotificationType.promotion:
        // Navegar para a promoção
        print('Abrir promoção');
        break;
      case NotificationType.review:
        // Navegar para a avaliação
        print('Abrir avaliação');
        break;
      case NotificationType.appUpdate:
        // Abrir loja de apps
        print('Abrir loja de apps');
        break;
      case NotificationType.community:
        // Navegar para perfil do usuário
        print('Abrir perfil do usuário');
        break;
    }
  }
}

// Modelos de dados
enum NotificationType {
  newPlace,
  promotion,
  review,
  appUpdate,
  community,
}

class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime time;
  bool isRead;
  final String? icon;

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.time,
    required this.isRead,
    this.icon,
  });
}
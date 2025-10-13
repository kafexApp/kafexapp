import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_icons.dart';
import '../../../data/models/domain/notification.dart';
import '../viewmodel/notifications_viewmodel.dart';
import '../../posts/widgets/post_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationsViewModel>().loadNotifications.execute();
    });

    // Atualiza a tela a cada 1 minuto para recalcular os tempos
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {
          // Força rebuild para atualizar os tempos
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.oatWhite,
      appBar: _buildAppBar(),
      body: Consumer<NotificationsViewModel>(
        builder: (context, viewModel, _) {
          // Loading state
          if (viewModel.loadNotifications.running) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.papayaSensorial,
              ),
            );
          }

          // Error state
          if (viewModel.loadNotifications.error) {
            return _buildErrorState(viewModel);
          }

          // Empty state
          if (viewModel.notifications.isEmpty) {
            return _buildEmptyState();
          }

          // Notifications list
          return Column(
            children: [
              if (viewModel.unreadCount > 0) _buildUnreadBanner(viewModel),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.only(top: 8),
                  itemCount: viewModel.notifications.length,
                  itemBuilder: (context, index) {
                    final notification = viewModel.notifications[index];
                    return _buildNotificationItem(context, notification, viewModel);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.oatWhite,
      elevation: 0,
      leading: IconButton(
        icon: Icon(AppIcons.back, color: AppColors.carbon),
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
        Consumer<NotificationsViewModel>(
          builder: (context, viewModel, _) {
            if (viewModel.unreadCount > 0) {
              return TextButton(
                onPressed: () {
                  viewModel.markAllAsRead.execute();
                },
                child: Text(
                  'Marcar todas',
                  style: GoogleFonts.albertSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.velvetMerlot,
                  ),
                ),
              );
            }
            return SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildUnreadBanner(NotificationsViewModel viewModel) {
    return Container(
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
        '${viewModel.unreadCount} notificação${viewModel.unreadCount > 1 ? 'ões' : ''} não lida${viewModel.unreadCount > 1 ? 's' : ''}',
        style: GoogleFonts.albertSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.papayaSensorial,
        ),
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
              AppIcons.notification,
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

  Widget _buildErrorState(NotificationsViewModel viewModel) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.warning,
              size: 60,
              color: AppColors.spiced,
            ),
            SizedBox(height: 24),
            Text(
              'Erro ao carregar notificações',
              style: GoogleFonts.albertSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.carbon,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                viewModel.loadNotifications.execute();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.papayaSensorial,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Tentar novamente',
                style: GoogleFonts.albertSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.whiteWhite,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    AppNotification notification,
    NotificationsViewModel viewModel,
  ) {
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
          AppIcons.delete,
          color: AppColors.whiteWhite,
          size: 24,
        ),
      ),
      onDismissed: (direction) {
        viewModel.deleteNotification.execute(notification.id);
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
          color: AppColors.whiteWhite,
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
                    fontWeight:
                        notification.isRead ? FontWeight.w500 : FontWeight.w600,
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
                viewModel.formatTime(notification.time),
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
              viewModel.markAsRead.execute(notification.id);
            }
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
        return AppColors.spiced; // Vermelho para curtida (coração)
      case NotificationType.appUpdate:
        return AppColors.eletricBlue;
      case NotificationType.community:
        return AppColors.softRose;
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.newPlace:
        return AppIcons.location;
      case NotificationType.promotion:
        return AppIcons.tag;
      case NotificationType.review:
        return AppIcons.heart; // ❤️ Coração para curtida
      case NotificationType.appUpdate:
        return AppIcons.download;
      case NotificationType.community:
        return AppIcons.users;
    }
  }

  void _handleNotificationTap(AppNotification notification) {
    print('🔔 === CLIQUE NA NOTIFICAÇÃO ===');
    print('   Notification ID: ${notification.id}');
    print('   Notification Type: ${notification.type}');
    print('   Action URL: ${notification.actionUrl}');
    
    // Se tem actionUrl, navegar
    if (notification.actionUrl != null) {
      _navigateFromNotification(notification.actionUrl!);
      return;
    }

    print('⚠️ ActionURL está null, usando fallback');
    
    // Fallback para tipos sem actionUrl
    switch (notification.type) {
      case NotificationType.newPlace:
        print('Abrir detalhes da cafeteria');
        break;
      case NotificationType.promotion:
        print('Abrir promoção');
        break;
      case NotificationType.review:
        print('Abrir post com curtida');
        break;
      case NotificationType.appUpdate:
        print('Abrir loja de apps');
        break;
      case NotificationType.community:
        print('Abrir post com comentário');
        break;
    }
  }

  /// Navega para a tela correta baseado na actionUrl
  void _navigateFromNotification(String actionUrl) {
    print('🔔 Navegando para: $actionUrl');

    // Parse da URL
    final uri = Uri.parse(actionUrl);
    final path = uri.path;
    final queryParams = uri.queryParameters;

    if (path.startsWith('/post/')) {
      // Navegar para detalhes do post
      final postId = path.replaceFirst('/post/', '');
      final commentId = queryParams['commentId'];

      print('📍 Navegando para PostDetailScreen');
      print('   Post ID: $postId');
      print('   Comment ID: $commentId');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PostDetailScreen(
            postId: postId,
            highlightCommentId: commentId,
          ),
        ),
      );
    } else if (path.startsWith('/cafeteria/')) {
      // TODO: Navegar para detalhes da cafeteria
      final cafeteriaId = path.replaceFirst('/cafeteria/', '');
      print('Abrir cafeteria: $cafeteriaId');
    }
  }
}
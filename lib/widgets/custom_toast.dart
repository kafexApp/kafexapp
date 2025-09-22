import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';

// Enum para tipos de toast
enum ToastType {
  success,
  error,
  warning,
  info,
}

// Classe principal para exibir toasts customizados
class CustomToast {
  
  // Método principal para mostrar toast
  static void show(
    BuildContext context, {
    required String message,
    required ToastType type,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return _ToastModal(
          message: message,
          type: type,
          duration: duration,
          actionLabel: actionLabel,
          onActionPressed: onActionPressed,
        );
      },
    );
  }
  
  // Métodos de conveniência para cada tipo
  static void showSuccess(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    show(
      context,
      message: message,
      type: ToastType.success,
      duration: duration,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }
  
  static void showError(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    show(
      context,
      message: message,
      type: ToastType.error,
      duration: duration,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }
  
  static void showWarning(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    show(
      context,
      message: message,
      type: ToastType.warning,
      duration: duration,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }
  
  static void showInfo(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    show(
      context,
      message: message,
      type: ToastType.info,
      duration: duration,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }
}

// Widget modal para o toast
class _ToastModal extends StatefulWidget {
  final String message;
  final ToastType type;
  final Duration duration;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  const _ToastModal({
    required this.message,
    required this.type,
    required this.duration,
    this.actionLabel,
    this.onActionPressed,
  });

  @override
  State<_ToastModal> createState() => _ToastModalState();
}

class _ToastModalState extends State<_ToastModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _animationController.forward();
    
    // Auto-dismiss após o tempo especificado
    Future.delayed(widget.duration, () {
      if (mounted) {
        _animationController.reverse().then((_) {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SlideTransition(
              position: _slideAnimation,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.whiteWhite,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: _getBorderColor(),
                      width: 3,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: _ToastContent(
                  message: widget.message,
                  type: widget.type,
                  actionLabel: widget.actionLabel,
                  onActionPressed: widget.onActionPressed,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getBorderColor() {
    switch (widget.type) {
      case ToastType.success:
      case ToastType.info:
        return AppColors.cyberLime;
      case ToastType.error:
      case ToastType.warning:
        return AppColors.spiced;
    }
  }
}

// Widget interno para o conteúdo do toast
class _ToastContent extends StatelessWidget {
  final String message;
  final ToastType type;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  const _ToastContent({
    required this.message,
    required this.type,
    this.actionLabel,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Ícone do tipo de toast
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _getIconBackgroundColor(),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: _getIcon(),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Mensagem
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.albertSans(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.carbon,
                height: 1.4,
              ),
            ),
          ),
          
          // Botão de ação (opcional)
          if (actionLabel != null && onActionPressed != null) ...[
            const SizedBox(width: 16),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onActionPressed!();
              },
              style: TextButton.styleFrom(
                foregroundColor: _getActionColor(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                actionLabel!,
                style: GoogleFonts.albertSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          
          // Botão de fechar
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.grayScale2.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 18,
                color: AppColors.grayScale1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getIconBackgroundColor() {
    switch (type) {
      case ToastType.success:
      case ToastType.info:
        return AppColors.cyberLime.withOpacity(0.15);
      case ToastType.error:
      case ToastType.warning:
        return AppColors.spiced.withOpacity(0.15);
    }
  }

  Widget _getIcon() {
    IconData iconData;
    Color iconColor;
    
    switch (type) {
      case ToastType.success:
        iconData = Icons.check_circle;
        iconColor = AppColors.cyberLime;
        break;
      case ToastType.error:
        iconData = Icons.error;
        iconColor = AppColors.spiced;
        break;
      case ToastType.warning:
        iconData = Icons.warning;
        iconColor = AppColors.spiced;
        break;
      case ToastType.info:
        iconData = Icons.info;
        iconColor = AppColors.cyberLime;
        break;
    }
    
    return Icon(
      iconData,
      size: 20,
      color: iconColor,
    );
  }

  Color _getActionColor() {
    switch (type) {
      case ToastType.success:
      case ToastType.info:
        return AppColors.cyberLime;
      case ToastType.error:
      case ToastType.warning:
        return AppColors.spiced;
    }
  }
}

// Widget de exemplo para demonstrar os toasts
class ToastExampleScreen extends StatelessWidget {
  const ToastExampleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.oatWhite,
      appBar: AppBar(
        title: const Text('Toast Examples'),
        backgroundColor: AppColors.velvetMerlot,
        foregroundColor: AppColors.whiteWhite,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Teste os Toast Messages',
              style: GoogleFonts.albertSans(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.velvetMerlot,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Botão Success
            ElevatedButton(
              onPressed: () {
                CustomToast.showSuccess(
                  context,
                  message: 'Login realizado com sucesso!',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.forestInk,
                foregroundColor: AppColors.whiteWhite,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Toast de Sucesso',
                style: GoogleFonts.albertSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Botão Error
            ElevatedButton(
              onPressed: () {
                CustomToast.showError(
                  context,
                  message: 'Erro ao processar dados. Tente novamente.',
                  actionLabel: 'Tentar Novamente',
                  onActionPressed: () {
                    print('Tentando novamente...');
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.spiced,
                foregroundColor: AppColors.whiteWhite,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Toast de Erro',
                style: GoogleFonts.albertSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Botão Warning
            ElevatedButton(
              onPressed: () {
                CustomToast.showWarning(
                  context,
                  message: 'Atenção: Verifique suas informações antes de continuar.',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sunsetBlaze,
                foregroundColor: AppColors.whiteWhite,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Toast de Aviso',
                style: GoogleFonts.albertSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Botão Info
            ElevatedButton(
              onPressed: () {
                CustomToast.showInfo(
                  context,
                  message: 'Cafeteria adicionada ao seu explorador de cafeterias.',
                  actionLabel: 'Ver',
                  onActionPressed: () {
                    print('Abrindo explorador...');
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.velvetMerlot,
                foregroundColor: AppColors.whiteWhite,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Toast de Informação',
                style: GoogleFonts.albertSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
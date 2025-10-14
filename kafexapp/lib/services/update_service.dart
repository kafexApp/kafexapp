import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_buttons.dart';

class KafexUpdateService {
  static final KafexUpdateService _instance = KafexUpdateService._internal();
  factory KafexUpdateService() => _instance;
  KafexUpdateService._internal();

  // Configurar o Upgrader com visual personalizado do Kafex
  static Widget wrapWithUpdateChecker({required Widget child}) {
    return UpgradeAlert(
      upgrader: Upgrader(
        durationUntilAlertAgain: Duration(days: 1), // Pergunta novamente em 1 dia
        debugLogging: false,
      ),
      child: child,
    );
  }

  // Dialog personalizado com visual do Kafex
  static void showCustomUpdateDialog({
    required BuildContext context,
    required String currentVersion,
    required String newVersion,
    required bool isRequired,
    required VoidCallback onUpdate,
    VoidCallback? onLater,
  }) {
    showDialog(
      context: context,
      barrierDismissible: !isRequired,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: AppColors.whiteWhite,
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ícone de atualização
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.papayaSensorial.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.system_update,
                    color: AppColors.papayaSensorial,
                    size: 40,
                  ),
                ),

                SizedBox(height: 24),

                // Título
                Text(
                  isRequired ? 'ATUALIZAÇÃO OBRIGATÓRIA' : 'NOVA VERSÃO DISPONÍVEL',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Monigue',
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: AppColors.velvetMerlot,
                  ),
                ),

                SizedBox(height: 16),

                // Descrição
                Text(
                  isRequired 
                    ? 'Uma nova versão do Kafex está disponível e é necessária para continuar usando o app.'
                    : 'Uma nova versão do Kafex está disponível com melhorias e correções.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Albert Sans',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),

                SizedBox(height: 16),

                // Informações das versões
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.moonAsh.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Versão atual',
                            style: TextStyle(
                              fontFamily: 'Albert Sans',
                              fontSize: 12,
                              color: AppColors.textTertiary,
                            ),
                          ),
                          Text(
                            currentVersion,
                            style: TextStyle(
                              fontFamily: 'Albert Sans',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.arrow_forward,
                        color: AppColors.papayaSensorial,
                        size: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Nova versão',
                            style: TextStyle(
                              fontFamily: 'Albert Sans',
                              fontSize: 12,
                              color: AppColors.textTertiary,
                            ),
                          ),
                          Text(
                            newVersion,
                            style: TextStyle(
                              fontFamily: 'Albert Sans',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.papayaSensorial,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32),

                // Botões
                Column(
                  children: [
                    // Botão principal - Atualizar
                    PrimaryButton(
                      text: 'Atualizar agora',
                      onPressed: onUpdate,
                    ),

                    SizedBox(height: 12),

                    // Botão secundário - Mais tarde (só se não for obrigatório)
                    if (!isRequired && onLater != null)
                      CustomTextButton(
                        text: 'Mais tarde',
                        onPressed: onLater,
                        textColor: AppColors.textTertiary,
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Verificar manualmente se há atualizações
  static Future<bool> checkForUpdates() async {
    try {
      final upgrader = Upgrader();
      await upgrader.initialize();
      
      return upgrader.shouldDisplayUpgrade();
    } catch (e) {
      print('Erro ao verificar atualizações: $e');
      return false;
    }
  }

  // Obter informações da versão atual
  static Future<String> getCurrentVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (e) {
      print('Erro ao obter versão atual: $e');
      return '1.0.0';
    }
  }

  // Obter informações da versão disponível na loja
  static Future<String?> getAvailableVersion() async {
    try {
      // Para desenvolvimento, simular uma versão nova
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      
      // Simular uma versão mais nova para testar (remover em produção)
      final versionParts = currentVersion.split('.');
      final majorVersion = int.parse(versionParts[0]);
      return '${majorVersion + 1}.0.0';
    } catch (e) {
      print('Erro ao obter versão da loja: $e');
      return null;
    }
  }
}
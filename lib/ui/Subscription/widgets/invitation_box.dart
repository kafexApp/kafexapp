import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../widgets/custom_toast.dart';
import '../viewmodel/invitation_box_viewmodel.dart';

class InvitationBox extends StatelessWidget {
  const InvitationBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => InvitationBoxViewModel(),
      child: _InvitationBoxContent(),
    );
  }
}

class _InvitationBoxContent extends StatelessWidget {
  const _InvitationBoxContent({Key? key}) : super(key: key);

  void _handleSubmit(BuildContext context, InvitationBoxViewModel viewModel) async {
    await viewModel.submitWaitlist.execute();
    
    if (viewModel.submitWaitlist.error) {
      CustomToast.showError(context, message: viewModel.errorMessage ?? 'Erro ao salvar');
    } else if (viewModel.submitWaitlist.completed) {
      Navigator.pop(context);
      CustomToast.showSuccess(
        context,
        message: 'Seu cadastro foi realizado, quando liberarmos novos convites te avisaremos. Até lá!',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InvitationBoxViewModel>(
      builder: (context, viewModel, _) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.whiteWhite,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                // Handle do topo
                Container(
                  margin: EdgeInsets.only(top: 16, bottom: 24),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grayScale2.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Ícone triste
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.whiteWhite,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.carbon.withOpacity(0.1),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/icon-negative.png',
                      width: 48,
                      height: 48,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                SizedBox(height: 24),

                // Título
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Ops, você não tem um\nconvite para participar!',
                    style: GoogleFonts.albertSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.carbon,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: 16),

                // Descrição
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Para participar do Clube da xícara, você precisa ser convidado por um coffeelover que já participa do clube.',
                    style: GoogleFonts.albertSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: AppColors.carbon,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: 16),

                // Instrução
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Solicite que um amigo te convide para participar. Ou clique no botão abaixo para se inscrever na lista de espera. Quando liberarmos novos convites te avisaremos em primeira mão.',
                    style: GoogleFonts.albertSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: AppColors.grayScale2,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: 32),

                // Campo de Email
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: TextField(
                    controller: viewModel.emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    enabled: !viewModel.submitWaitlist.running,
                    style: GoogleFonts.albertSans(fontSize: 16, color: AppColors.carbon),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: GoogleFonts.albertSans(fontSize: 14, color: AppColors.grayScale2),
                      filled: true,
                      fillColor: AppColors.oatWhite,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.papayaSensorial, width: 2)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // Campo de Telefone
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: TextField(
                    controller: viewModel.phoneController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => FocusScope.of(context).unfocus(),
                    enabled: !viewModel.submitWaitlist.running,
                    style: GoogleFonts.albertSans(fontSize: 16, color: AppColors.carbon),
                    decoration: InputDecoration(
                      labelText: 'Telefone',
                      labelStyle: GoogleFonts.albertSans(fontSize: 14, color: AppColors.grayScale2),
                      filled: true,
                      fillColor: AppColors.oatWhite,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.papayaSensorial, width: 2)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                ),

                SizedBox(height: 24),

                // Botão
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: viewModel.submitWaitlist.running ? null : () => _handleSubmit(context, viewModel),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.pear,
                        foregroundColor: AppColors.carbon,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                      child: viewModel.submitWaitlist.running
                          ? SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(AppColors.carbon)))
                          : Text('Entrar na lista de espera', style: GoogleFonts.albertSans(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.carbon)),
                    ),
                  ),
                ),

                SizedBox(height: 32),
              ],
            ),
          ),
          ),
        );
      },
    );
  }
}
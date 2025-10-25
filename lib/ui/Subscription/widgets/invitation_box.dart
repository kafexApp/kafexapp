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

class _InvitationBoxContent extends StatefulWidget {
  const _InvitationBoxContent({Key? key}) : super(key: key);

  @override
  State<_InvitationBoxContent> createState() => _InvitationBoxContentState();
}

class _InvitationBoxContentState extends State<_InvitationBoxContent> {
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() => setState(() {}));
    _phoneFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

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
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                Container(
                  margin: EdgeInsets.only(top: 16, bottom: 24),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grayScale2.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                Image.asset(
                  'assets/images/icon-negative.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                ),

                SizedBox(height: 24),

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

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: AppColors.whiteWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _emailFocusNode.hasFocus 
                            ? AppColors.papayaSensorial 
                            : AppColors.oatWhite,
                        width: _emailFocusNode.hasFocus ? 2 : 1,
                      ),
                      boxShadow: _emailFocusNode.hasFocus
                          ? [
                              BoxShadow(
                                color: AppColors.papayaSensorial.withOpacity(0.1),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: TextField(
                      controller: viewModel.emailController,
                      focusNode: _emailFocusNode,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      enabled: !viewModel.submitWaitlist.running,
                      style: GoogleFonts.albertSans(
                        fontSize: 16,
                        color: AppColors.carbon,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: _emailFocusNode.hasFocus 
                              ? AppColors.papayaSensorial 
                              : AppColors.grayScale2,
                          size: 22,
                        ),
                        hintText: 'Email',
                        hintStyle: GoogleFonts.albertSans(
                          fontSize: 16,
                          color: AppColors.grayScale2.withOpacity(0.6),
                          fontWeight: FontWeight.w400,
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 16),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: AppColors.whiteWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _phoneFocusNode.hasFocus 
                            ? AppColors.papayaSensorial 
                            : AppColors.oatWhite,
                        width: _phoneFocusNode.hasFocus ? 2 : 1,
                      ),
                      boxShadow: _phoneFocusNode.hasFocus
                          ? [
                              BoxShadow(
                                color: AppColors.papayaSensorial.withOpacity(0.1),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: TextField(
                      controller: viewModel.phoneController,
                      focusNode: _phoneFocusNode,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => FocusScope.of(context).unfocus(),
                      enabled: !viewModel.submitWaitlist.running,
                      inputFormatters: [viewModel.phoneMaskFormatter],
                      style: GoogleFonts.albertSans(
                        fontSize: 16,
                        color: AppColors.carbon,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.phone_outlined,
                          color: _phoneFocusNode.hasFocus 
                              ? AppColors.papayaSensorial 
                              : AppColors.grayScale2,
                          size: 22,
                        ),
                        hintText: '+55 (00) 0 0000-0000',
                        hintStyle: GoogleFonts.albertSans(
                          fontSize: 16,
                          color: AppColors.grayScale2.withOpacity(0.6),
                          fontWeight: FontWeight.w400,
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 24),

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
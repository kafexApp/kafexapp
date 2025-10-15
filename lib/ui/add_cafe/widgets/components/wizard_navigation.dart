import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_icons.dart';
import '../../../../data/models/domain/wizard_state.dart';
import '../../viewmodel/add_cafe_viewmodel.dart';

class WizardNavigation extends StatelessWidget {
  final AddCafeViewModel viewModel;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onSubmit;

  const WizardNavigation({
    Key? key,
    required this.viewModel,
    required this.onNext,
    required this.onPrevious,
    required this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final wizardState = viewModel.wizardState;
    final canProceed = viewModel.canProceedFromCurrentStep();
    final isLastStep = wizardState.isLastStep;
    final isSubmitting = viewModel.submitCafe.running;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 110),
      decoration: BoxDecoration(
        color: AppColors.whiteWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (wizardState.canGoBack) ...[
            Expanded(
              flex: 1,
              child: _BackButton(onPressed: onPrevious),
            ),
            SizedBox(width: 12),
          ],
          Expanded(
            flex: wizardState.canGoBack ? 2 : 1,
            child: _NextButton(
              isLastStep: isLastStep,
              canProceed: canProceed,
              isSubmitting: isSubmitting,
              onPressed: isLastStep ? onSubmit : onNext,
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _BackButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          AppIcons.back,
          size: 18,
          color: AppColors.grayScale1,
        ),
        label: Text(
          'Voltar',
          style: GoogleFonts.albertSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.grayScale1,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.moonAsh),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  final bool isLastStep;
  final bool canProceed;
  final bool isSubmitting;
  final VoidCallback onPressed;

  const _NextButton({
    required this.isLastStep,
    required this.canProceed,
    required this.isSubmitting,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: isSubmitting ? null : (canProceed ? onPressed : null),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.papayaSensorial,
          foregroundColor: AppColors.velvetMerlot,
          disabledBackgroundColor: AppColors.grayScale2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: isSubmitting
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.whiteWhite,
                  ),
                ),
              )
            : Text(
                isLastStep ? 'Enviar cadastro' : 'Continuar',
                style: GoogleFonts.albertSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: canProceed
                      ? AppColors.velvetMerlot
                      : AppColors.whiteWhite,
                ),
              ),
      ),
    );
  }
}
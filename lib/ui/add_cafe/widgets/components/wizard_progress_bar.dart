import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../utils/app_colors.dart';
import '../../../../data/models/domain/wizard_state.dart';

class WizardProgressBar extends StatefulWidget {
  final AddCafeWizardState wizardState;

  const WizardProgressBar({
    Key? key,
    required this.wizardState,
  }) : super(key: key);

  @override
  State<WizardProgressBar> createState() => _WizardProgressBarState();
}

class _WizardProgressBarState extends State<WizardProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  double _currentProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _currentProgress = widget.wizardState.progress;

    _progressController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: _currentProgress,
      end: widget.wizardState.progress,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _progressController.forward();
  }

  @override
  void didUpdateWidget(WizardProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.wizardState.progress != widget.wizardState.progress) {
      _updateProgress();
    }
  }

  void _updateProgress() {
    _progressAnimation = Tween<double>(
      begin: _currentProgress,
      end: widget.wizardState.progress,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _progressController.forward(from: 0.0);
    _currentProgress = widget.wizardState.progress;
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: AppColors.whiteWhite,
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Passo ${widget.wizardState.currentStepIndex + 1} de ${widget.wizardState.totalSteps}',
                style: GoogleFonts.albertSans(
                  fontSize: 12,
                  color: AppColors.grayScale2,
                ),
              ),
              Spacer(),
              Text(
                '${(widget.wizardState.progress * 100).round()}%',
                style: GoogleFonts.albertSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.papayaSensorial,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.moonAsh,
              borderRadius: BorderRadius.circular(3),
            ),
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _progressAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.papayaSensorial,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
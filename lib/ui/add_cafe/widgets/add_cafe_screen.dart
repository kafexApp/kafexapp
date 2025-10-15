import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../utils/app_colors.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_bottom_navbar.dart';
import '../../../widgets/custom_toast.dart';
import '../viewmodel/add_cafe_viewmodel.dart';
import 'components/wizard_progress_bar.dart';
import 'components/wizard_navigation.dart';
import 'steps/search_step.dart';
import 'steps/photo_step.dart';
import 'steps/details_step.dart';
import 'steps/submit_step.dart';

class AddCafeScreen extends StatefulWidget {
  @override
  _AddCafeScreenState createState() => _AddCafeScreenState();
}

class _AddCafeScreenState extends State<AddCafeScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  final ImagePicker _imagePicker = ImagePicker();

  late AnimationController _transitionController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _transitionController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeIn,
    ));

    _transitionController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _transitionController.dispose();
    super.dispose();
  }

  void _nextStep() {
    final viewModel = context.read<AddCafeViewModel>();
    viewModel.nextStep();
    _animateTransition();
    _pageController.animateToPage(
      viewModel.wizardState.currentStepIndex,
      duration: Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  void _previousStep() {
    final viewModel = context.read<AddCafeViewModel>();
    viewModel.previousStep();
    _animateTransition();
    _pageController.animateToPage(
      viewModel.wizardState.currentStepIndex,
      duration: Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  void _animateTransition() {
    _transitionController.reset();
    _transitionController.forward();
  }

  void _submitCafe() async {
    final viewModel = context.read<AddCafeViewModel>();

    if (!viewModel.canProceedFromCurrentStep()) {
      CustomToast.showError(
        context,
        message: 'Por favor, complete o cadastro primeiro.',
      );
      return;
    }

    viewModel.submitCafe.execute();
  }

  void _handleBackPress() {
    final viewModel = context.read<AddCafeViewModel>();
    if (viewModel.wizardState.canGoBack) {
      _previousStep();
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.oatWhite,
      appBar: CustomAppBar(
        showBackButton: true,
        onBackPressed: _handleBackPress,
      ),
      body: Consumer<AddCafeViewModel>(
        builder: (context, viewModel, _) {
          _handleSubmitCallbacks(viewModel);

          return Stack(
            children: [
              Column(
                children: [
                  WizardProgressBar(wizardState: viewModel.wizardState),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        _buildAnimatedStep(SearchStep(viewModel: viewModel)),
                        _buildAnimatedStep(PhotoStep(
                          viewModel: viewModel,
                          imagePicker: _imagePicker,
                        )),
                        _buildAnimatedStep(DetailsStep(viewModel: viewModel)),
                        _buildAnimatedStep(SubmitStep(viewModel: viewModel)),
                      ],
                    ),
                  ),
                  WizardNavigation(
                    viewModel: viewModel,
                    onNext: _nextStep,
                    onPrevious: _previousStep,
                    onSubmit: _submitCafe,
                  ),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: CustomBottomNavbar(
                  isInCafeExplorer: true,
                  onSearchPressed: () {},
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAnimatedStep(Widget step) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: step,
      ),
    );
  }

  void _handleSubmitCallbacks(AddCafeViewModel viewModel) {
    if (viewModel.submitCafe.completed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CustomToast.showSuccess(
          context,
          message: 'Cafeteria enviada com sucesso!',
        );
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      });
    }

    if (viewModel.submitCafe.error) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CustomToast.showError(
          context,
          message: 'Erro ao enviar cafeteria. Tente novamente.',
        );
      });
    }
  }
}
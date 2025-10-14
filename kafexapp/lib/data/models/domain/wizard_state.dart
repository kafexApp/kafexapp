import 'package:freezed_annotation/freezed_annotation.dart';

part 'wizard_state.freezed.dart';

/// Enum para os passos do wizard
enum WizardStep {
  search,
  photo,
  details,
  submit,
}

/// Estado do wizard de cadastro
@freezed
class AddCafeWizardState with _$AddCafeWizardState {
  const factory AddCafeWizardState({
    @Default(WizardStep.search) WizardStep currentStep,
    @Default(0) int currentStepIndex,
    @Default(4) int totalSteps,
  }) = _AddCafeWizardState;

  const AddCafeWizardState._();

  /// Progresso em porcentagem (0.0 a 1.0)
  double get progress => (currentStepIndex + 1) / totalSteps;

  /// Pode avançar para o próximo passo?
  bool get canGoNext => currentStepIndex < totalSteps - 1;

  /// Pode voltar para o passo anterior?
  bool get canGoBack => currentStepIndex > 0;

  /// Está no último passo?
  bool get isLastStep => currentStepIndex == totalSteps - 1;

  /// Está no primeiro passo?
  bool get isFirstStep => currentStepIndex == 0;
}
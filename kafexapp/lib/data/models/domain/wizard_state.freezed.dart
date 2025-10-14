// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wizard_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AddCafeWizardState {
  WizardStep get currentStep => throw _privateConstructorUsedError;
  int get currentStepIndex => throw _privateConstructorUsedError;
  int get totalSteps => throw _privateConstructorUsedError;

  /// Create a copy of AddCafeWizardState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AddCafeWizardStateCopyWith<AddCafeWizardState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AddCafeWizardStateCopyWith<$Res> {
  factory $AddCafeWizardStateCopyWith(
    AddCafeWizardState value,
    $Res Function(AddCafeWizardState) then,
  ) = _$AddCafeWizardStateCopyWithImpl<$Res, AddCafeWizardState>;
  @useResult
  $Res call({WizardStep currentStep, int currentStepIndex, int totalSteps});
}

/// @nodoc
class _$AddCafeWizardStateCopyWithImpl<$Res, $Val extends AddCafeWizardState>
    implements $AddCafeWizardStateCopyWith<$Res> {
  _$AddCafeWizardStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AddCafeWizardState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStep = null,
    Object? currentStepIndex = null,
    Object? totalSteps = null,
  }) {
    return _then(
      _value.copyWith(
            currentStep: null == currentStep
                ? _value.currentStep
                : currentStep // ignore: cast_nullable_to_non_nullable
                      as WizardStep,
            currentStepIndex: null == currentStepIndex
                ? _value.currentStepIndex
                : currentStepIndex // ignore: cast_nullable_to_non_nullable
                      as int,
            totalSteps: null == totalSteps
                ? _value.totalSteps
                : totalSteps // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AddCafeWizardStateImplCopyWith<$Res>
    implements $AddCafeWizardStateCopyWith<$Res> {
  factory _$$AddCafeWizardStateImplCopyWith(
    _$AddCafeWizardStateImpl value,
    $Res Function(_$AddCafeWizardStateImpl) then,
  ) = __$$AddCafeWizardStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({WizardStep currentStep, int currentStepIndex, int totalSteps});
}

/// @nodoc
class __$$AddCafeWizardStateImplCopyWithImpl<$Res>
    extends _$AddCafeWizardStateCopyWithImpl<$Res, _$AddCafeWizardStateImpl>
    implements _$$AddCafeWizardStateImplCopyWith<$Res> {
  __$$AddCafeWizardStateImplCopyWithImpl(
    _$AddCafeWizardStateImpl _value,
    $Res Function(_$AddCafeWizardStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AddCafeWizardState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStep = null,
    Object? currentStepIndex = null,
    Object? totalSteps = null,
  }) {
    return _then(
      _$AddCafeWizardStateImpl(
        currentStep: null == currentStep
            ? _value.currentStep
            : currentStep // ignore: cast_nullable_to_non_nullable
                  as WizardStep,
        currentStepIndex: null == currentStepIndex
            ? _value.currentStepIndex
            : currentStepIndex // ignore: cast_nullable_to_non_nullable
                  as int,
        totalSteps: null == totalSteps
            ? _value.totalSteps
            : totalSteps // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$AddCafeWizardStateImpl extends _AddCafeWizardState {
  const _$AddCafeWizardStateImpl({
    this.currentStep = WizardStep.search,
    this.currentStepIndex = 0,
    this.totalSteps = 4,
  }) : super._();

  @override
  @JsonKey()
  final WizardStep currentStep;
  @override
  @JsonKey()
  final int currentStepIndex;
  @override
  @JsonKey()
  final int totalSteps;

  @override
  String toString() {
    return 'AddCafeWizardState(currentStep: $currentStep, currentStepIndex: $currentStepIndex, totalSteps: $totalSteps)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AddCafeWizardStateImpl &&
            (identical(other.currentStep, currentStep) ||
                other.currentStep == currentStep) &&
            (identical(other.currentStepIndex, currentStepIndex) ||
                other.currentStepIndex == currentStepIndex) &&
            (identical(other.totalSteps, totalSteps) ||
                other.totalSteps == totalSteps));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, currentStep, currentStepIndex, totalSteps);

  /// Create a copy of AddCafeWizardState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AddCafeWizardStateImplCopyWith<_$AddCafeWizardStateImpl> get copyWith =>
      __$$AddCafeWizardStateImplCopyWithImpl<_$AddCafeWizardStateImpl>(
        this,
        _$identity,
      );
}

abstract class _AddCafeWizardState extends AddCafeWizardState {
  const factory _AddCafeWizardState({
    final WizardStep currentStep,
    final int currentStepIndex,
    final int totalSteps,
  }) = _$AddCafeWizardStateImpl;
  const _AddCafeWizardState._() : super._();

  @override
  WizardStep get currentStep;
  @override
  int get currentStepIndex;
  @override
  int get totalSteps;

  /// Create a copy of AddCafeWizardState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AddCafeWizardStateImplCopyWith<_$AddCafeWizardStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

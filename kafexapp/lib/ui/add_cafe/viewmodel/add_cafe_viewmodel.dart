import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import '../../../data/models/domain/cafe_submission.dart';
import '../../../data/models/domain/wizard_state.dart';
import '../../../data/repositories/places_submission_repository.dart';
import '../../../data/repositories/cafe_submission_repository.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

class AddCafeViewModel extends ChangeNotifier {
  final PlacesSubmissionRepository _placesRepository;
  final CafeSubmissionRepository _submissionRepository;

  AddCafeViewModel({
    required PlacesSubmissionRepository placesRepository,
    required CafeSubmissionRepository submissionRepository,
  })  : _placesRepository = placesRepository,
        _submissionRepository = submissionRepository;

  // ==================== ESTADO ====================

  // Estado do wizard
  AddCafeWizardState _wizardState = AddCafeWizardState();
  AddCafeWizardState get wizardState => _wizardState;

  // Busca de lugares
  List<PlaceDetails> _placeSuggestions = [];
  List<PlaceDetails> get placeSuggestions => _placeSuggestions;
  
  String _lastSearchQuery = '';
  Timer? _searchTimer;
  bool _showSuggestions = false;
  bool get showSuggestions => _showSuggestions;

  // Dados do formulário
  PlaceDetails? _selectedPlace;
  PlaceDetails? get selectedPlace => _selectedPlace;

  File? _customPhoto;
  File? get customPhoto => _customPhoto;

  bool _isOfficeFriendly = false;
  bool get isOfficeFriendly => _isOfficeFriendly;

  bool _isPetFriendly = false;
  bool get isPetFriendly => _isPetFriendly;

  bool _isVegFriendly = false;
  bool get isVegFriendly => _isVegFriendly;

  // ==================== COMMANDS ====================

  late final Command1<List<PlaceDetails>, String> searchPlaces =
      Command1(_searchPlaces);

  late final Command1<void, PlaceDetails> selectPlace = Command1(_selectPlace);

  late final Command0<void> submitCafe = Command0(_submitCafe);

  // ==================== NAVEGAÇÃO DO WIZARD ====================

  void nextStep() {
    if (_wizardState.canGoNext) {
      _wizardState = AddCafeWizardState(
        currentStepIndex: _wizardState.currentStepIndex + 1,
        currentStep: WizardStep.values[_wizardState.currentStepIndex + 1],
        totalSteps: _wizardState.totalSteps,
      );
      notifyListeners();
    }
  }

  void previousStep() {
    if (_wizardState.canGoBack) {
      _wizardState = AddCafeWizardState(
        currentStepIndex: _wizardState.currentStepIndex - 1,
        currentStep: WizardStep.values[_wizardState.currentStepIndex - 1],
        totalSteps: _wizardState.totalSteps,
      );
      notifyListeners();
    }
  }

  void goToStep(int stepIndex) {
    if (stepIndex >= 0 && stepIndex < _wizardState.totalSteps) {
      _wizardState = AddCafeWizardState(
        currentStepIndex: stepIndex,
        currentStep: WizardStep.values[stepIndex],
        totalSteps: _wizardState.totalSteps,
      );
      notifyListeners();
    }
  }

  // ==================== VALIDAÇÕES ====================

  bool canProceedFromCurrentStep() {
    switch (_wizardState.currentStep) {
      case WizardStep.search:
        return _selectedPlace != null;
      case WizardStep.photo:
        return true; // Foto é opcional
      case WizardStep.details:
        return true; // Detalhes são opcionais
      case WizardStep.submit:
        return true;
    }
  }

  // ==================== BUSCA DE LUGARES ====================

  Future<Result<List<PlaceDetails>>> _searchPlaces(String query) async {
    try {
      if (query.trim().isEmpty) {
        _placeSuggestions = [];
        _showSuggestions = false;
        _lastSearchQuery = '';
        _selectedPlace = null;
        notifyListeners();
        return Result.ok([]);
      }

      // Evitar buscas duplicadas
      if (query == _lastSearchQuery) {
        return Result.ok(_placeSuggestions);
      }

      // Cancelar timer anterior
      _searchTimer?.cancel();

      // Aguardar 500ms (debounce)
      await Future.delayed(Duration(milliseconds: 500));

      _lastSearchQuery = query;
      _placeSuggestions = await _placesRepository.searchPlaces(query);
      _showSuggestions = _placeSuggestions.isNotEmpty;
      notifyListeners();

      return Result.ok(_placeSuggestions);
    } catch (e) {
      return Result.error(Exception('Erro ao buscar lugares: $e'));
    }
  }

  Future<Result<void>> _selectPlace(PlaceDetails place) async {
    try {
      _showSuggestions = false;
      notifyListeners();

      // Buscar detalhes completos do lugar
      final details = await _placesRepository.getPlaceDetails(place.placeId);

      if (details != null) {
        _selectedPlace = details;
        _placeSuggestions = [];
        notifyListeners();

        // Auto-avançar após delay
        await Future.delayed(Duration(milliseconds: 1200));
        if (canProceedFromCurrentStep()) {
          nextStep();
        }
      }

      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Erro ao selecionar lugar: $e'));
    }
  }

  void clearSearch() {
    _placeSuggestions = [];
    _showSuggestions = false;
    _lastSearchQuery = '';
    _selectedPlace = null;
    notifyListeners();
  }

  void hideSuggestions() {
    _showSuggestions = false;
    notifyListeners();
  }

  // ==================== FOTO ====================

  void setCustomPhoto(File? photo) {
    _customPhoto = photo;
    notifyListeners();
  }

  void removeCustomPhoto() {
    _customPhoto = null;
    notifyListeners();
  }

  // ==================== FACILIDADES ====================

  void toggleOfficeFriendly() {
    _isOfficeFriendly = !_isOfficeFriendly;
    notifyListeners();
  }

  void togglePetFriendly() {
    _isPetFriendly = !_isPetFriendly;
    notifyListeners();
  }

  void toggleVegFriendly() {
    _isVegFriendly = !_isVegFriendly;
    notifyListeners();
  }

  void setOfficeFriendly(bool value) {
    _isOfficeFriendly = value;
    notifyListeners();
  }

  void setPetFriendly(bool value) {
    _isPetFriendly = value;
    notifyListeners();
  }

  void setVegFriendly(bool value) {
    _isVegFriendly = value;
    notifyListeners();
  }

  // ==================== SUBMIT ====================

  Future<Result<void>> _submitCafe() async {
    try {
      if (_selectedPlace == null) {
        return Result.error(Exception('Nenhuma cafeteria selecionada'));
      }

      // Criar submissão
      final submission = CafeSubmission(
        placeId: _selectedPlace!.placeId,
        name: _selectedPlace!.name,
        address: _selectedPlace!.address,
        phone: _selectedPlace!.phone,
        website: _selectedPlace!.website,
        photoUrl: _selectedPlace!.photoUrl,
        latitude: _selectedPlace!.latitude,
        longitude: _selectedPlace!.longitude,
        isOfficeFriendly: _isOfficeFriendly,
        isPetFriendly: _isPetFriendly,
        isVegFriendly: _isVegFriendly,
        customPhotoPath: _customPhoto?.path,
      );

      // Enviar para o repository
      return await _submissionRepository.submitCafe(submission, _customPhoto);
    } catch (e) {
      return Result.error(Exception('Erro ao enviar cafeteria: $e'));
    }
  }

  // ==================== HELPERS ====================

  String getStepTitle() {
    switch (_wizardState.currentStep) {
      case WizardStep.search:
        return 'Encontre a cafeteria';
      case WizardStep.photo:
        return 'Adicione uma foto';
      case WizardStep.details:
        return 'Informações extras';
      case WizardStep.submit:
        return 'Finalize o cadastro';
    }
  }

  String getStepDescription() {
    switch (_wizardState.currentStep) {
      case WizardStep.search:
        return 'Digite o nome da cafeteria para encontrarmos as informações para você.';
      case WizardStep.photo:
        return 'Tire uma foto ou escolha da galeria (opcional)';
      case WizardStep.details:
        return 'Adicione mais detalhes sobre o local (opcional)';
      case WizardStep.submit:
        return 'Revise as informações e envie para análise';
    }
  }

  String getFacilitiesText() {
    List<String> facilities = [];
    if (_isPetFriendly) facilities.add('Pet-friendly');
    if (_isVegFriendly) facilities.add('Opções veganas');
    if (_isOfficeFriendly) facilities.add('Office-friendly');

    if (facilities.isEmpty) return 'Nenhuma informada';
    return facilities.join(', ');
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    searchPlaces.dispose();
    selectPlace.dispose();
    submitCafe.dispose();
    super.dispose();
  }
}
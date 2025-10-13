// lib/ui/add_cafe/viewmodel/add_cafe_viewmodel.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
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

  AddCafeWizardState _wizardState = AddCafeWizardState();
  AddCafeWizardState get wizardState => _wizardState;

  List<PlaceDetails> _placeSuggestions = [];
  List<PlaceDetails> get placeSuggestions => _placeSuggestions;
  
  String _lastSearchQuery = '';
  Timer? _searchTimer;
  bool _showSuggestions = false;
  bool get showSuggestions => _showSuggestions;

  PlaceDetails? _selectedPlace;
  PlaceDetails? get selectedPlace => _selectedPlace;

  XFile? _customPhoto;
  XFile? get customPhoto => _customPhoto;

  bool _isOfficeFriendly = false;
  bool get isOfficeFriendly => _isOfficeFriendly;

  bool _isPetFriendly = false;
  bool get isPetFriendly => _isPetFriendly;

  bool _isVegFriendly = false;
  bool get isVegFriendly => _isVegFriendly;

  late final Command1<List<PlaceDetails>, String> searchPlaces =
      Command1(_searchPlaces);

  late final Command1<void, PlaceDetails> selectPlace = Command1(_selectPlace);

  late final Command0<void> submitCafe = Command0(_submitCafe);

  void nextStep() {
    if (_wizardState.canGoNext) {
      final newIndex = _wizardState.currentStepIndex + 1;
      _wizardState = AddCafeWizardState(
        currentStepIndex: newIndex,
        currentStep: WizardStep.values[newIndex],
        totalSteps: _wizardState.totalSteps,
      );
      print('🔄 Wizard avançou para step $newIndex: ${_wizardState.currentStep}');
      notifyListeners();
    }
  }

  void previousStep() {
    if (_wizardState.canGoBack) {
      final newIndex = _wizardState.currentStepIndex - 1;
      _wizardState = AddCafeWizardState(
        currentStepIndex: newIndex,
        currentStep: WizardStep.values[newIndex],
        totalSteps: _wizardState.totalSteps,
      );
      print('🔄 Wizard voltou para step $newIndex: ${_wizardState.currentStep}');
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
      print('🔄 Wizard foi para step $stepIndex: ${_wizardState.currentStep}');
      notifyListeners();
    }
  }

  bool canProceedFromCurrentStep() {
    switch (_wizardState.currentStep) {
      case WizardStep.search:
        return _selectedPlace != null;
      case WizardStep.photo:
        return true;
      case WizardStep.details:
        return true;
      case WizardStep.submit:
        return true;
    }
  }

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

      if (query == _lastSearchQuery) {
        return Result.ok(_placeSuggestions);
      }

      _searchTimer?.cancel();
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
      print('📍 Selecionando lugar: ${place.name}');
      
      _showSuggestions = false;
      notifyListeners();

      if (place.latitude != null && place.longitude != null) {
        print('✅ Coordenadas já disponíveis');
        _selectedPlace = place;
        _placeSuggestions = [];
        notifyListeners();
        return Result.ok(null);
      }

      print('🌐 Buscando coordenadas no Google Places...');
      final details = await _placesRepository.getPlaceDetails(place.placeId);

      if (details != null && details.latitude != null && details.longitude != null) {
        print('✅ Coordenadas obtidas: (${details.latitude}, ${details.longitude})');
        
        _selectedPlace = PlaceDetails(
          placeId: place.placeId,
          name: place.name,
          address: place.address,
          phone: place.phone,
          website: place.website,
          photoUrl: place.photoUrl,
          latitude: details.latitude,
          longitude: details.longitude,
        );
        
        _placeSuggestions = [];
        notifyListeners();
      } else {
        print('⚠️ Não foi possível obter coordenadas');
        return Result.error(Exception('Não foi possível obter as coordenadas do lugar'));
      }

      return Result.ok(null);
    } catch (e) {
      print('❌ Erro ao selecionar lugar: $e');
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

  void setCustomPhoto(XFile? photo) {
    _customPhoto = photo;
    notifyListeners();
  }

  void removeCustomPhoto() {
    _customPhoto = null;
    notifyListeners();
  }

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

  Future<Result<void>> _submitCafe() async {
    try {
      if (_selectedPlace == null) {
        return Result.error(Exception('Nenhuma cafeteria selecionada'));
      }

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

      final result = await _submissionRepository.submitCafe(submission, _customPhoto);
      
      if (result.isOk) {
        print('✅ Cafeteria enviada com sucesso!');
      } else {
        print('❌ Erro ao enviar cafeteria: ${result.asError.error}');
      }
      
      return result;
    } catch (e) {
      return Result.error(Exception('Erro ao enviar cafeteria: $e'));
    }
  }

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
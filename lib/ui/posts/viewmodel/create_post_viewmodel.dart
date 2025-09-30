import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import '../../../data/repositories/feed_repository.dart';
import '../../../data/models/domain/post.dart';
import '../../../utils/user_manager.dart';
import '../../../services/post_creation_service.dart';

class CreatePostViewModel extends ChangeNotifier {
  final FeedRepository _feedRepository;
  final ImagePicker _picker = ImagePicker();
  
  CreatePostViewModel({
    required FeedRepository feedRepository,
  }) : _feedRepository = feedRepository;

  // Controllers
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController linkController = TextEditingController();

  // State
  XFile? _selectedMediaFile;
  File? _selectedMedia; // Apenas para mobile
  bool _isVideo = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  File? get selectedMedia => _selectedMedia;
  XFile? get selectedMediaFile => _selectedMediaFile;
  bool get isVideo => _isVideo;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasValidContent => 
      descriptionController.text.trim().isNotEmpty || _selectedMediaFile != null;
  bool get hasLink => linkController.text.trim().isNotEmpty;

  // Commands - versões melhoradas
  Future<void> pickMediaFromGallery() async {
    await _pickMedia(ImageSource.gallery);
  }

  Future<void> pickMediaFromCamera() async {
    await _pickMedia(ImageSource.camera);
  }

  // Novo método para selecionar especificamente imagem
  Future<void> pickImageFromSource(ImageSource source) async {
    await _pickSpecificMedia(source, isVideo: false);
  }

  // Novo método para selecionar especificamente vídeo
  Future<void> pickVideoFromSource(ImageSource source) async {
    await _pickSpecificMedia(source, isVideo: true);
  }

  void removeMedia() {
    _selectedMedia = null;
    _selectedMediaFile = null;
    _isVideo = false;
    _clearError();
    notifyListeners();
  }

  Future<bool> publishPost() async {
    if (!hasValidContent) {
      _setError('Adicione uma descrição ou mídia para continuar');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      String? imageUrl;
      String? videoUrl;

      // Upload da mídia se selecionada
      if (_selectedMediaFile != null) {
        print('📤 Iniciando upload de ${_isVideo ? 'vídeo' : 'imagem'}...');
        
        if (_isVideo) {
          videoUrl = await PostCreationService.uploadVideoFromXFile(_selectedMediaFile!);
          if (videoUrl == null) {
            _setError('Erro ao enviar vídeo. Tente novamente.');
            return false;
          }
          print('✅ Vídeo uploaded: $videoUrl');
        } else {
          imageUrl = await PostCreationService.uploadImageFromXFile(_selectedMediaFile!);
          if (imageUrl == null) {
            _setError('Erro ao enviar imagem. Tente novamente.');
            return false;
          }
          print('✅ Imagem uploaded: $imageUrl');
        }
      }

      // Cria o post no banco
      final success = await PostCreationService.createPost(
        description: descriptionController.text.trim(),
        imageUrl: imageUrl,
        videoUrl: videoUrl,
        externalLink: linkController.text.trim().isEmpty 
            ? null 
            : linkController.text.trim(),
      );

      if (success) {
        _clearForm();
        return true;
      } else {
        _setError('Erro ao publicar post. Tente novamente.');
        return false;
      }
    } catch (e) {
      print('❌ Erro ao publicar post: $e');
      _setError('Erro inesperado: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Método melhorado para seleção de mídia
  Future<void> _pickMedia(ImageSource source) async {
    try {
      _clearError();
      
      // Por padrão, seleciona imagem
      // O tipo será definido pelo modal de seleção
      await _pickSpecificMedia(source, isVideo: false);
    } catch (e) {
      print('❌ Erro ao selecionar mídia: $e');
      _setError('Erro ao selecionar mídia: ${e.toString()}');
    }
  }

  // Método específico para selecionar mídia com tipo definido
  Future<void> _pickSpecificMedia(ImageSource source, {required bool isVideo}) async {
    try {
      _clearError();
      
      XFile? pickedFile;
      
      if (isVideo) {
        print('🎥 Selecionando vídeo da ${source == ImageSource.camera ? 'câmera' : 'galeria'}...');
        pickedFile = await _picker.pickVideo(
          source: source,
          maxDuration: Duration(minutes: 5), // Limite de 5 minutos
        );
        _isVideo = true;
      } else {
        print('📷 Selecionando imagem da ${source == ImageSource.camera ? 'câmera' : 'galeria'}...');
        pickedFile = await _picker.pickImage(
          source: source,
          maxWidth: 1920,
          maxHeight: 1920,
          imageQuality: 85,
        );
        _isVideo = false;
      }

      if (pickedFile != null) {
        _selectedMediaFile = pickedFile;
        
        // Apenas no mobile, cria o File para preview
        if (!kIsWeb) {
          _selectedMedia = File(pickedFile.path);
        }
        
        print('✅ Mídia selecionada: ${pickedFile.name}');
        notifyListeners();
      } else {
        print('ℹ️ Seleção de mídia cancelada pelo usuário');
      }
    } catch (e) {
      print('❌ Erro ao selecionar mídia: $e');
      _setError('Erro ao selecionar mídia: ${e.toString()}');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _clearForm() {
    descriptionController.clear();
    linkController.clear();
    _selectedMedia = null;
    _selectedMediaFile = null;
    _isVideo = false;
    _clearError();
    notifyListeners();
  }

  @override
  void dispose() {
    descriptionController.dispose();
    linkController.dispose();
    super.dispose();
  }
}
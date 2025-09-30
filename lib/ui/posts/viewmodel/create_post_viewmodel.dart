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

  // Commands
  Future<void> pickMediaFromGallery() async {
    await _pickMedia(ImageSource.gallery);
  }

  Future<void> pickMediaFromCamera() async {
    await _pickMedia(ImageSource.camera);
  }

  void removeMedia() {
    _selectedMedia = null;
    _selectedMediaFile = null;
    _isVideo = false;
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
        if (_isVideo) {
          videoUrl = await PostCreationService.uploadVideoFromXFile(_selectedMediaFile!);
          if (videoUrl == null) {
            _setError('Erro ao enviar vídeo. Tente novamente.');
            return false;
          }
        } else {
          imageUrl = await PostCreationService.uploadImageFromXFile(_selectedMediaFile!);
          if (imageUrl == null) {
            _setError('Erro ao enviar imagem. Tente novamente.');
            return false;
          }
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
      _setError('Erro inesperado: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _pickMedia(ImageSource source) async {
    try {
      // Primeiro, determinar se é foto ou vídeo
      final mediaType = await _showMediaTypeDialog();
      if (mediaType == null) return;

      XFile? pickedFile;
      
      if (mediaType == 'photo') {
        pickedFile = await _picker.pickImage(source: source);
        _isVideo = false;
      } else {
        pickedFile = await _picker.pickVideo(source: source);
        _isVideo = true;
      }

      if (pickedFile != null) {
        _selectedMediaFile = pickedFile;
        
        // Apenas no mobile, cria o File para preview
        if (!kIsWeb) {
          _selectedMedia = File(pickedFile.path);
        }
        
        notifyListeners();
      }
    } catch (e) {
      _setError('Erro ao selecionar mídia: ${e.toString()}');
    }
  }

  Future<String?> _showMediaTypeDialog() async {
    // Este método será implementado na View
    // Por enquanto, retorna 'photo' como padrão
    return 'photo';
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
    notifyListeners();
  }

  @override
  void dispose() {
    descriptionController.dispose();
    linkController.dispose();
    super.dispose();
  }
}
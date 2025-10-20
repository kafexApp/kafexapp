// lib/ui/posts/viewmodel/create_post_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import '../../../data/repositories/feed_repository.dart';
import '../../../data/models/domain/post.dart';
import '../../../utils/user_manager.dart';
import '../../../services/post_creation_service.dart';
import '../../../services/event_bus_service.dart';

class CreatePostViewModel extends ChangeNotifier {
  final FeedRepository _feedRepository;
  final ImagePicker _picker = ImagePicker();
  final EventBusService _eventBus = EventBusService();

  CreatePostViewModel({required FeedRepository feedRepository})
    : _feedRepository = feedRepository {
    print('🎯 CreatePostViewModel criado - EventBus: ${_eventBus.hashCode}');
    
    // Adiciona listeners nos controllers para atualizar estado quando necessário
    descriptionController.addListener(_onTextChanged);
    linkController.addListener(_onTextChanged);
  }

  // Controllers
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController linkController = TextEditingController();

  // State
  XFile? _selectedMediaFile;
  File? _selectedMedia;
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
      descriptionController.text.trim().isNotEmpty ||
      _selectedMediaFile != null;
  bool get hasLink => linkController.text.trim().isNotEmpty;

  // Listener para mudanças no texto (sem notifyListeners para não perder foco)
  void _onTextChanged() {
    // Não chama notifyListeners aqui para evitar perder o foco do TextField
  }

  // Métodos para selecionar mídia
  Future<void> pickMediaFromGallery() async {
    await _showMediaTypePicker(ImageSource.gallery);
  }

  Future<void> pickMediaFromCamera() async {
    await _showMediaTypePicker(ImageSource.camera);
  }

  Future<void> pickImageFromSource(ImageSource source) async {
    await _pickSpecificMedia(source, isVideo: false);
  }

  Future<void> pickVideoFromSource(ImageSource source) async {
    await _pickSpecificMedia(source, isVideo: true);
  }

  // Método auxiliar para escolher tipo de mídia
  Future<void> _showMediaTypePicker(ImageSource source) async {
    // Por padrão, tenta pegar imagem primeiro
    // Se quiser vídeo, use os métodos específicos
    await _pickSpecificMedia(source, isVideo: false);
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
          videoUrl = await PostCreationService.uploadVideoFromXFile(
            _selectedMediaFile!,
          );
          if (videoUrl == null) {
            _setError('Erro ao enviar vídeo. Tente novamente.');
            return false;
          }
          print('✅ Vídeo uploaded: $videoUrl');
        } else {
          imageUrl = await PostCreationService.uploadImageFromXFile(
            _selectedMediaFile!,
          );
          if (imageUrl == null) {
            _setError('Erro ao enviar imagem. Tente novamente.');
            return false;
          }
          print('✅ Imagem uploaded: $imageUrl');
        }
      }

      // Criar post no Supabase
      final description = descriptionController.text.trim();
      final externalLink = linkController.text.trim().isNotEmpty
          ? linkController.text.trim()
          : null;

      print('📝 Criando post no Supabase...');
      print('📝 Descrição: $description');
      print('📝 ImageUrl: $imageUrl');
      print('📝 VideoUrl: $videoUrl');
      print('📝 Link: $externalLink');

      final success = await PostCreationService.createTraditionalPost(
        description: description,
        imageUrl: imageUrl,
        videoUrl: videoUrl,
        externalLink: externalLink,
      );

      if (success) {
        print('✅ Post criado com sucesso!');

        await Future.delayed(Duration(milliseconds: 300));

        final postId = 'new_post_${DateTime.now().millisecondsSinceEpoch}';
        print('🚀 Emitindo evento PostCreatedEvent com ID: $postId');
        _eventBus.emit(PostCreatedEvent(postId));

        await Future.delayed(Duration(milliseconds: 200));
        print('✅ Evento PostCreatedEvent emitido com sucesso');

        _clearForm();
        _setLoading(false);
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

  // Método privado para selecionar mídia específica (imagem ou vídeo)
  Future<void> _pickSpecificMedia(
    ImageSource source, {
    required bool isVideo,
  }) async {
    try {
      _clearError();
      print('📸 Tentando selecionar ${isVideo ? 'vídeo' : 'imagem'}...');

      XFile? pickedFile;

      if (isVideo) {
        pickedFile = await _picker.pickVideo(
          source: source,
          maxDuration: Duration(minutes: 5), // Limite de 5 minutos
        );
      } else {
        pickedFile = await _picker.pickImage(
          source: source,
          maxWidth: 1920,
          maxHeight: 1920,
          imageQuality: 85,
        );
      }

      if (pickedFile != null) {
        _selectedMediaFile = pickedFile;

        // Apenas converte para File no mobile
        if (!kIsWeb) {
          _selectedMedia = File(pickedFile.path);
        }

        _isVideo = isVideo;
        print('✅ Mídia selecionada: ${pickedFile.name}');
        print('   - Tipo: ${_isVideo ? 'vídeo' : 'imagem'}');
        print('   - Path: ${pickedFile.path}');
        print('   - Web: $kIsWeb');
        
        notifyListeners();
      } else {
        print('⚠️ Nenhuma mídia selecionada');
      }
    } catch (e) {
      print('❌ Erro ao selecionar mídia: $e');
      _setError('Erro ao selecionar mídia. Tente novamente.');
    }
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

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  @override
  void dispose() {
    descriptionController.removeListener(_onTextChanged);
    linkController.removeListener(_onTextChanged);
    descriptionController.dispose();
    linkController.dispose();
    super.dispose();
  }
}
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
  }

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
      descriptionController.text.trim().isNotEmpty ||
      _selectedMediaFile != null;
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
      final success = await PostCreationService.createPost(
        description: description,
        imageUrl: imageUrl,
        videoUrl: videoUrl,
        externalLink: externalLink,
      );

      if (success) {
        print('✅ Post criado com sucesso!');

        // Aguarda um pequeno delay para garantir que o post foi salvo
        await Future.delayed(Duration(milliseconds: 300));

        // IMPORTANTE: Emite evento para atualizar o feed automaticamente
        final postId = 'new_post_${DateTime.now().millisecondsSinceEpoch}';
        print('🚀 Emitindo evento PostCreatedEvent com ID: $postId');
        _eventBus.emit(PostCreatedEvent(postId));

        // Aguarda mais um pouco para garantir que o evento foi processado
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
      _setError('Erro inesperado. Tente novamente.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Método privado para selecionar mídia
  Future<void> _pickMedia(ImageSource source) async {
    try {
      _clearError();

      // Tenta pegar mídia (imagem ou vídeo)
      final XFile? media = await _picker.pickImage(source: source);

      if (media != null) {
        _selectedMediaFile = media;

        // Para mobile, também mantemos o File
        if (!kIsWeb) {
          _selectedMedia = File(media.path);
        }

        // Verifica se é vídeo baseado na extensão
        final extension = media.path.toLowerCase();
        _isVideo =
            extension.endsWith('.mp4') ||
            extension.endsWith('.mov') ||
            extension.endsWith('.avi');

        print('📸 Mídia selecionada: ${_isVideo ? 'Vídeo' : 'Imagem'}');
        notifyListeners();
      }
    } catch (e) {
      print('❌ Erro ao selecionar mídia: $e');
      _setError('Erro ao selecionar mídia');
    }
  }

  // Método privado para selecionar mídia específica
  Future<void> _pickSpecificMedia(
    ImageSource source, {
    required bool isVideo,
  }) async {
    try {
      _clearError();

      XFile? media;

      if (isVideo) {
        media = await _picker.pickVideo(source: source);
      } else {
        media = await _picker.pickImage(source: source);
      }

      if (media != null) {
        _selectedMediaFile = media;

        // Para mobile, também mantemos o File
        if (!kIsWeb) {
          _selectedMedia = File(media.path);
        }

        _isVideo = isVideo;

        print('📸 ${isVideo ? 'Vídeo' : 'Imagem'} selecionado(a)');
        notifyListeners();
      }
    } catch (e) {
      print('❌ Erro ao selecionar ${isVideo ? 'vídeo' : 'imagem'}: $e');
      _setError('Erro ao selecionar ${isVideo ? 'vídeo' : 'imagem'}');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false;
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
    _errorMessage = null;
  }

  @override
  void dispose() {
    descriptionController.dispose();
    linkController.dispose();
    super.dispose();
  }
}

// lib/ui/posts/viewmodel/create_post_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../data/repositories/feed_repository.dart';
import '../../../data/models/domain/post.dart';
import '../../../utils/user_manager.dart';

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
  File? _selectedMedia;
  bool _isVideo = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  File? get selectedMedia => _selectedMedia;
  bool get isVideo => _isVideo;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasValidContent => 
      descriptionController.text.trim().isNotEmpty || _selectedMedia != null;
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
      final userManager = UserManager.instance;
      
      final post = Post(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        authorName: userManager.userName,
        authorAvatar: userManager.userPhotoUrl ?? '',
        content: descriptionController.text.trim(),
        imageUrl: _selectedMedia?.path,
        videoUrl: _isVideo ? _selectedMedia?.path : null,
        createdAt: DateTime.now(),
        likes: 0,
        comments: 0,
        isLiked: false,
        type: DomainPostType.traditional,
        coffeeName: null,
        rating: null,
        coffeeId: null,
        isFavorited: null,
        wantToVisit: null,
        coffeeAddress: null,
      );

      await _feedRepository.createPost(post);
      _clearForm();
      return true;
    } catch (e) {
      _setError('Erro ao publicar post: ${e.toString()}');
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
        _selectedMedia = File(pickedFile.path);
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
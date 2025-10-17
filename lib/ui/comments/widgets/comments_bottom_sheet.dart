// lib/ui/comments/widgets/comments_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_icons.dart';
import '../../../models/comment_models.dart';
import '../../../services/comments_service.dart';
import '../../../widgets/common/alert_modal.dart';
import '../../../widgets/common/success_modal.dart';
import 'comment_header.dart';
import 'comment_input.dart';
import 'comment_item.dart';
import 'comment_options_modal.dart';
import '../dialogs/edit_comment_dialog.dart';
import '../dialogs/report_comment_dialog.dart';

class PostCommentsModal extends StatefulWidget {
  final String postId;
  final List<CommentData> initialComments;
  final Function(String)? onCommentAdded;
  final String? highlightCommentId;

  const PostCommentsModal({
    Key? key,
    required this.postId,
    this.initialComments = const [],
    this.onCommentAdded,
    this.highlightCommentId,
  }) : super(key: key);

  @override
  _PostCommentsModalState createState() => _PostCommentsModalState();
}

class _PostCommentsModalState extends State<PostCommentsModal> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocus = FocusNode();
  final ScrollController _scrollController = ScrollController();

  List<CommentData> comments = [];
  bool isPosting = false;
  bool isLoading = true;
  
  // Controle de edição
  bool isEditMode = false;
  String? editingCommentId;
  String? originalCommentContent;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() => isLoading = true);

    try {
      final loadedComments = await CommentsService.getCommentsByPostId(
        widget.postId,
      );

      setState(() {
        comments = loadedComments;
        isLoading = false;
      });

      if (widget.highlightCommentId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToHighlightedComment();
        });
      }
    } catch (e) {
      print('Erro ao carregar comentários: $e');
      setState(() {
        comments = widget.initialComments;
        isLoading = false;
      });
    }
  }

  void _scrollToHighlightedComment() {
    if (widget.highlightCommentId == null) return;

    final index = comments.indexWhere((c) => c.id == widget.highlightCommentId);
    
    if (index != -1 && _scrollController.hasClients) {
      final targetPosition = index * 100.0;
      
      _scrollController.jumpTo(
        targetPosition.clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        ),
      );
    }
  }

  Future<void> _postComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || isPosting) return;

    // Se está em modo de edição, salva a edição ao invés de criar novo
    if (isEditMode && editingCommentId != null) {
      await _saveEdit();
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showLoginRequiredDialog();
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => isPosting = true);

    try {
      final newComment = await CommentsService.addComment(
        postId: widget.postId,
        conteudo: text,
      );

      if (newComment != null) {
        setState(() {
          comments.add(newComment);
          _commentController.clear();
        });

        widget.onCommentAdded?.call(text);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });

        _showSuccessSnackBar('Comentário adicionado!');
      } else {
        _showErrorSnackBar('Erro ao adicionar comentário');
      }
    } catch (e) {
      print('Erro ao postar comentário: $e');
      _showErrorSnackBar('Erro ao adicionar comentário');
    } finally {
      setState(() => isPosting = false);
    }
  }

  void _startEditMode(CommentData comment) {
    setState(() {
      isEditMode = true;
      editingCommentId = comment.id;
      originalCommentContent = comment.content;
      _commentController.text = comment.content;
    });
    
    // Aguarda o próximo frame para garantir que o widget foi atualizado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Foca no campo de texto (isso abre o teclado automaticamente)
      _commentFocus.requestFocus();
      
      // Posiciona o cursor no final do texto
      _commentController.selection = TextSelection.fromPosition(
        TextPosition(offset: _commentController.text.length),
      );
    });
  }

  void _cancelEdit() {
    setState(() {
      isEditMode = false;
      editingCommentId = null;
      originalCommentContent = null;
      _commentController.clear();
    });
    
    FocusScope.of(context).unfocus();
  }

  Future<void> _saveEdit() async {
    if (editingCommentId == null) return;
    
    final newContent = _commentController.text.trim();
    if (newContent.isEmpty) return;
    
    // Se não mudou nada, só cancela
    if (newContent == originalCommentContent) {
      _cancelEdit();
      return;
    }

    setState(() => isPosting = true);

    try {
      final success = await CommentsService.editComment(
        commentId: editingCommentId!,
        novoConteudo: newContent,
      );

      if (success) {
        setState(() {
          final commentIndex = comments.indexWhere((c) => c.id == editingCommentId);
          if (commentIndex != -1) {
            final comment = comments[commentIndex];
            comments[commentIndex] = comment.copyWith(content: newContent);
          }
        });

        _showSuccessSnackBar('Comentário editado!');
        _cancelEdit();
      } else {
        _showErrorSnackBar('Erro ao editar comentário');
      }
    } catch (e) {
      print('Erro ao editar comentário: $e');
      _showErrorSnackBar('Erro ao editar comentário');
    } finally {
      setState(() => isPosting = false);
    }
  }

  Future<void> _editComment(String commentId, String newContent) async {
    try {
      final success = await CommentsService.editComment(
        commentId: commentId,
        novoConteudo: newContent,
      );

      if (success) {
        setState(() {
          final commentIndex = comments.indexWhere((c) => c.id == commentId);
          if (commentIndex != -1) {
            final comment = comments[commentIndex];
            comments[commentIndex] = comment.copyWith(content: newContent);
          }
        });

        _showSuccessSnackBar('Comentário editado!');
      } else {
        _showErrorSnackBar('Erro ao editar comentário');
      }
    } catch (e) {
      print('Erro ao editar comentário: $e');
      _showErrorSnackBar('Erro ao editar comentário');
    }
  }

  Future<void> _deleteComment(String commentId) async {
    try {
      final success = await CommentsService.deleteComment(
        commentId: commentId,
        postId: widget.postId,
      );

      if (success) {
        setState(() {
          comments.removeWhere((comment) => comment.id == commentId);
        });

        await SuccessModal.show(
          context: context,
          title: 'Comentário excluído!',
          message: 'Seu comentário foi removido com sucesso.',
        );
      } else {
        _showErrorSnackBar('Erro ao excluir comentário');
      }
    } catch (e) {
      print('Erro ao excluir comentário: $e');
      _showErrorSnackBar('Erro ao excluir comentário');
    }
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Login necessário'),
          content: Text('Você precisa estar logado para comentar.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.spiced,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.papayaSensorial,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showCommentOptionsModal(CommentData comment) async {
    final isOwnComment = await CommentsService.isUserComment(comment.id);

    CommentOptionsModal.show(
      context: context,
      comment: comment,
      isOwnComment: isOwnComment,
      onEdit: () => _handleEditComment(comment),
      onDelete: () => _handleDeleteComment(comment.id),
      onReport: () => _handleReportComment(comment),
    );
  }

  Future<void> _handleEditComment(CommentData comment) async {
    _startEditMode(comment);
  }

  Future<void> _handleDeleteComment(String commentId) async {
    final confirmed = await AlertModal.show(
      context: context,
      title: 'Excluir comentário?',
      message: 'Tem certeza que deseja excluir este comentário? Esta ação não pode ser desfeita.',
      type: AlertType.warning,
      confirmText: 'Excluir',
      cancelText: 'Cancelar',
    );

    if (confirmed == true) {
      await _deleteComment(commentId);
    }
  }

  Future<void> _handleReportComment(CommentData comment) async {
    final confirmed = await ReportCommentDialog.show(context);

    if (confirmed) {
      _showSuccessSnackBar('Comentário reportado');
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 100),
        height: MediaQuery.of(context).size.height * 0.85,
        padding: EdgeInsets.only(bottom: keyboardHeight),
        decoration: BoxDecoration(
          color: AppColors.whiteWhite,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            CommentHeader(
              commentsCount: comments.length,
              onClose: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: _buildContent(),
              ),
            ),
            CommentInput(
              controller: _commentController,
              focusNode: _commentFocus,
              isPosting: isPosting,
              onSend: _postComment,
              onChanged: () => setState(() {}),
              isEditMode: isEditMode,
              onCancelEdit: _cancelEdit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.papayaSensorial),
      );
    }

    if (comments.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
      itemCount: comments.length,
      itemBuilder: (context, index) {
        final comment = comments[index];
        return CommentItem(
          comment: comment,
          isHighlighted: widget.highlightCommentId == comment.id,
          onOptionsPressed: () => _showCommentOptionsModal(comment),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(AppIcons.comment, size: 48, color: AppColors.grayScale2),
          SizedBox(height: 16),
          Text(
            'Nenhum comentário ainda',
            style: GoogleFonts.albertSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Seja o primeiro a comentar!',
            style: GoogleFonts.albertSans(
              fontSize: 14,
              color: AppColors.grayScale2,
            ),
          ),
        ],
      ),
    );
  }
}

void showCommentsModal(
  BuildContext context, {
  required String postId,
  List<CommentData> comments = const [],
  Function(String)? onCommentAdded,
  String? highlightCommentId,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (context) => PostCommentsModal(
      postId: postId,
      initialComments: comments,
      onCommentAdded: onCommentAdded,
      highlightCommentId: highlightCommentId,
    ),
  );
}
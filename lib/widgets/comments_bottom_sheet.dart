// lib/widgets/comments_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_colors.dart';
import '../utils/app_icons.dart';
import '../models/comment_models.dart';
import '../services/comments_service.dart';
import '../backend/supabase/tables/comentario_com_usuario.dart';

class PostCommentsModal extends StatefulWidget {
  final String postId;
  final List<CommentData> initialComments;
  final Function(String)? onCommentAdded;

  const PostCommentsModal({
    Key? key,
    required this.postId,
    this.initialComments = const [],
    this.onCommentAdded,
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

  /// Carrega comentários do Supabase
  Future<void> _loadComments() async {
    setState(() {
      isLoading = true;
    });

    try {
      final loadedComments = await CommentsService.getCommentsByPostId(
        widget.postId,
      );

      setState(() {
        comments = loadedComments;
        isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar comentários: $e');
      setState(() {
        comments = widget.initialComments;
        isLoading = false;
      });
    }
  }

  /// Adiciona novo comentário
  Future<void> _postComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || isPosting) return;

    // Verificar se usuário está logado
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showLoginRequiredDialog();
      return;
    }

    setState(() {
      isPosting = true;
    });

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

        // Callback para atualizar contador na UI principal
        widget.onCommentAdded?.call(text);

        // Scroll para o final para mostrar novo comentário
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });

        // Feedback visual
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Comentário adicionado!'),
            backgroundColor: AppColors.papayaSensorial,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        _showErrorSnackBar('Erro ao adicionar comentário');
      }
    } catch (e) {
      print('Erro ao postar comentário: $e');
      _showErrorSnackBar('Erro ao adicionar comentário');
    } finally {
      setState(() {
        isPosting = false;
      });
    }
  }

  /// Curte ou descurte um comentário (funcionalidade desabilitada temporariamente)
  Future<void> _toggleCommentLike(CommentData comment) async {
    // TODO: Implementar sistema de curtidas se necessário
    // A estrutura atual não possui campo de curtidas
    print('Sistema de curtidas não implementado ainda');
  }

  /// Edita um comentário
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

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Comentário editado!'),
            backgroundColor: AppColors.papayaSensorial,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        _showErrorSnackBar('Erro ao editar comentário');
      }
    } catch (e) {
      print('Erro ao editar comentário: $e');
      _showErrorSnackBar('Erro ao editar comentário');
    }
  }

  /// Remove um comentário
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

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Comentário excluído!'),
            backgroundColor: AppColors.carbon,
            duration: Duration(seconds: 2),
          ),
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

  void _showCommentOptionsModal(CommentData comment) async {
    // Verificar se é comentário do usuário atual
    final isOwnComment = await CommentsService.isUserComment(comment.id);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.whiteWhite,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle do Modal
              Container(
                margin: EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grayScale2.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              SizedBox(height: 20),

              if (isOwnComment) ...[
                // Botão Editar
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    _showEditCommentDialog(comment);
                  },
                  leading: Icon(
                    AppIcons.edit,
                    color: AppColors.papayaSensorial,
                    size: 24,
                  ),
                  title: Text(
                    'Editar comentário',
                    style: GoogleFonts.albertSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),

                // Divisor
                Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.moonAsh,
                  indent: 16,
                  endIndent: 16,
                ),

                // Botão Excluir
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirmDialog(comment.id);
                  },
                  leading: Icon(
                    AppIcons.delete,
                    color: AppColors.spiced,
                    size: 24,
                  ),
                  title: Text(
                    'Excluir comentário',
                    style: GoogleFonts.albertSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.spiced,
                    ),
                  ),
                ),
              ] else ...[
                // Botão Reportar (para comentários de outros usuários)
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    _showReportDialog(comment);
                  },
                  leading: Icon(
                    AppIcons.warning,
                    color: AppColors.spiced,
                    size: 24,
                  ),
                  title: Text(
                    'Reportar comentário',
                    style: GoogleFonts.albertSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],

              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showEditCommentDialog(CommentData comment) {
    final editController = TextEditingController(text: comment.content);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar comentário'),
          content: TextField(
            controller: editController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Digite seu comentário...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _editComment(comment.id, editController.text.trim());
              },
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmDialog(String commentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Excluir comentário'),
          content: Text(
            'Tem certeza que deseja excluir este comentário? Esta ação não pode ser desfeita.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteComment(commentId);
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.spiced),
              child: Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  void _showReportDialog(CommentData comment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reportar comentário'),
          content: Text(
            'Deseja reportar este comentário por conteúdo inadequado?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Implementar sistema de reports
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Comentário reportado'),
                    backgroundColor: AppColors.papayaSensorial,
                  ),
                );
              },
              child: Text('Reportar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: AppColors.whiteWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),

          Expanded(
            child: isLoading
                ? _buildLoadingState()
                : comments.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      return _buildCommentItem(comments[index]);
                    },
                  ),
          ),

          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(color: AppColors.papayaSensorial),
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

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.whiteWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.grayScale2.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grayScale2.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Comentários (${comments.length})',
                  style: GoogleFonts.albertSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.carbon,
                  ),
                ),
              ],
            ),
          ),

          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.moonAsh,
                shape: BoxShape.circle,
              ),
              child: Icon(AppIcons.close, color: AppColors.carbon, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(CommentData comment) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          _buildUserAvatar(comment.userName, comment.userAvatar),

          SizedBox(width: 12),

          // Conteúdo do comentário
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nome e tempo
                Row(
                  children: [
                    Text(
                      comment.userName,
                      style: GoogleFonts.albertSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      _formatTimestamp(comment.timestamp),
                      style: GoogleFonts.albertSans(
                        fontSize: 12,
                        color: AppColors.grayScale2,
                      ),
                    ),
                    Spacer(),
                    // Botão de opções
                    GestureDetector(
                      onTap: () => _showCommentOptionsModal(comment),
                      child: Container(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          AppIcons.dotsThreeVertical,
                          color: AppColors.grayScale2,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 4),

                // Conteúdo
                Text(
                  comment.content,
                  style: GoogleFonts.albertSans(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),

                SizedBox(height: 8),

                // Botão de curtir (desabilitado temporariamente)
                Row(
                  children: [
                    GestureDetector(
                      onTap: null, // Desabilitado até implementar curtidas
                      child: Row(
                        children: [
                          Icon(
                            AppIcons.heart,
                            color: AppColors.grayScale2.withOpacity(0.5),
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Curtir',
                            style: GoogleFonts.albertSans(
                              fontSize: 12,
                              color: AppColors.grayScale2.withOpacity(0.5),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(String userName, String? avatarUrl) {
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          avatarUrl,
          width: 32,
          height: 32,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildAvatarFallback(userName);
          },
        ),
      );
    }

    return _buildAvatarFallback(userName);
  }

  Widget _buildAvatarFallback(String userName) {
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';
    final colorIndex = userName.isNotEmpty ? userName.codeUnitAt(0) % 5 : 0;
    final avatarColors = [
      AppColors.papayaSensorial,
      AppColors.velvetMerlot,
      AppColors.spiced,
      AppColors.forestInk,
      AppColors.pear,
    ];

    final avatarColor = avatarColors[colorIndex];

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: avatarColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.albertSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: avatarColor,
          ),
        ),
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: AppColors.whiteWhite,
        border: Border(top: BorderSide(color: AppColors.moonAsh, width: 1)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Campo de texto
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.oatWhite,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _commentFocus.hasFocus
                        ? AppColors.papayaSensorial.withOpacity(0.3)
                        : AppColors.moonAsh,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _commentController,
                  focusNode: _commentFocus,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.newline,
                  keyboardType: TextInputType.multiline,
                  style: GoogleFonts.albertSans(
                    fontSize: 14,
                    color: AppColors.carbon,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Escreva um comentário...',
                    hintStyle: GoogleFonts.albertSans(
                      fontSize: 14,
                      color: AppColors.grayScale2,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    filled: false,
                  ),
                  onChanged: (value) {
                    setState(() {}); // Para atualizar o botão de envio
                  },
                ),
              ),
            ),

            SizedBox(width: 12),

            // Botão Enviar
            GestureDetector(
              onTap: _commentController.text.trim().isNotEmpty && !isPosting
                  ? _postComment
                  : null,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _commentController.text.trim().isNotEmpty && !isPosting
                      ? AppColors.papayaSensorial
                      : AppColors.grayScale2.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: isPosting
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.whiteWhite,
                        ),
                      )
                    : Icon(
                        AppIcons.paperPlaneTilt,
                        color: AppColors.whiteWhite,
                        size: 18,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min';
    } else {
      return 'agora';
    }
  }
}

// Função helper para mostrar o modal
void showCommentsModal(
  BuildContext context, {
  required String postId,
  List<CommentData> comments = const [],
  Function(String)? onCommentAdded,
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
    ),
  );
}

// lib/widgets/comments_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../utils/app_icons.dart';

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

  @override
  void initState() {
    super.initState();
    comments = List.from(widget.initialComments);
    
    // Mock de comentários para demonstração
    if (comments.isEmpty) {
      comments = [
        CommentData(
          id: '1',
          userName: 'Maria Santos',
          userAvatar: 'https://images.unsplash.com/photo-1494790108755-2616b612b829?w=150',
          content: 'Que lugar incrível! Já fui lá várias vezes e sempre uma experiência única ☕️',
          timestamp: DateTime.now().subtract(Duration(hours: 2)),
          likes: 12,
          isLiked: false,
        ),
        CommentData(
          id: '2',
          userName: 'João Silva',
          userAvatar: null,
          content: 'Concordo! O café lá é excepcional. Recomendo o espresso com notas de chocolate.',
          timestamp: DateTime.now().subtract(Duration(hours: 4)),
          likes: 8,
          isLiked: true,
        ),
        CommentData(
          id: '3',
          userName: 'Ana Costa',
          userAvatar: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
          content: 'Ambiente aconchegante demais! Perfeito para trabalhar ou relaxar.',
          timestamp: DateTime.now().subtract(Duration(days: 1)),
          likes: 5,
          isLiked: false,
        ),
      ];
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _postComment() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() {
      isPosting = true;
    });

    // Simular delay de postagem
    await Future.delayed(Duration(milliseconds: 800));

    final newComment = CommentData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userName: 'Você', // Em um app real, viria do UserManager
      userAvatar: null,
      content: _commentController.text.trim(),
      timestamp: DateTime.now(),
      likes: 0,
      isLiked: false,
    );

    setState(() {
      comments.insert(0, newComment);
      isPosting = false;
    });

    _commentController.clear();
    widget.onCommentAdded?.call(newComment.content);

    // Scroll para o novo comentário
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _toggleLike(String commentId) {
    setState(() {
      final commentIndex = comments.indexWhere((c) => c.id == commentId);
      if (commentIndex != -1) {
        final comment = comments[commentIndex];
        comments[commentIndex] = CommentData(
          id: comment.id,
          userName: comment.userName,
          userAvatar: comment.userAvatar,
          content: comment.content,
          timestamp: comment.timestamp,
          likes: comment.isLiked ? comment.likes - 1 : comment.likes + 1,
          isLiked: !comment.isLiked,
        );
      }
    });
  }

  void _deleteComment(String commentId) {
    setState(() {
      comments.removeWhere((comment) => comment.id == commentId);
    });
    
    // Mostrar feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Comentário excluído'),
        backgroundColor: AppColors.carbon,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _editComment(String commentId, String newContent) {
    setState(() {
      final commentIndex = comments.indexWhere((c) => c.id == commentId);
      if (commentIndex != -1) {
        final comment = comments[commentIndex];
        comments[commentIndex] = CommentData(
          id: comment.id,
          userName: comment.userName,
          userAvatar: comment.userAvatar,
          content: newContent,
          timestamp: comment.timestamp,
          likes: comment.likes,
          isLiked: comment.isLiked,
        );
      }
    });
  }

  void _showCommentOptionsModal(CommentData comment) {
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
              
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showEditCommentDialog(CommentData comment) {
    final TextEditingController editController = TextEditingController(text: comment.content);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.whiteWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Editar comentário',
            style: GoogleFonts.albertSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.carbon,
            ),
          ),
          content: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.oatWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.moonAsh,
                width: 1,
              ),
            ),
            child: TextField(
              controller: editController,
              maxLines: null,
              style: GoogleFonts.albertSans(
                fontSize: 14,
                color: AppColors.carbon,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Digite seu comentário...',
                hintStyle: GoogleFonts.albertSans(
                  fontSize: 14,
                  color: AppColors.grayScale2,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: GoogleFonts.albertSans(
                  fontSize: 14,
                  color: AppColors.grayScale2,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                if (editController.text.trim().isNotEmpty) {
                  _editComment(comment.id, editController.text.trim());
                  Navigator.pop(context);
                }
              },
              child: Text(
                'Salvar',
                style: GoogleFonts.albertSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.papayaSensorial,
                ),
              ),
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
          backgroundColor: AppColors.whiteWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Excluir comentário?',
            style: GoogleFonts.albertSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.carbon,
            ),
          ),
          content: Text(
            'Esta ação não pode ser desfeita.',
            style: GoogleFonts.albertSans(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: GoogleFonts.albertSans(
                  fontSize: 14,
                  color: AppColors.grayScale2,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _deleteComment(commentId);
                Navigator.pop(context);
              },
              child: Text(
                'Excluir',
                style: GoogleFonts.albertSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.spiced,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Método para verificar se o comentário é do usuário atual
  bool _isUserComment(String userName) {
    // Em um app real, você compararia com UserManager.instance.userName
    // Por enquanto, vamos considerar que comentários do "Você" são do usuário atual
    return userName == 'Você';
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
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
          // Header do Modal
          _buildHeader(),
          
          // Lista de Comentários
          Expanded(
            child: comments.isEmpty 
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.fromLTRB(20, 16, 20, 0), // MARGEM SUPERIOR ADICIONADA
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      return _buildCommentItem(comments[index]);
                    },
                  ),
          ),
          
          // Campo de Comentário
          _buildCommentInput(),
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
          // Handle do Modal
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
          
          // Botão Fechar
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.moonAsh,
                shape: BoxShape.circle,
              ),
              child: Icon(
                AppIcons.close,
                color: AppColors.textSecondary,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.moonAsh,
              shape: BoxShape.circle,
            ),
            child: Icon(
              AppIcons.comment,
              size: 40,
              color: AppColors.grayScale2,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Nenhum comentário ainda',
            style: GoogleFonts.albertSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.carbon,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Seja o primeiro a comentar!',
            style: GoogleFonts.albertSans(
              fontSize: 14,
              color: AppColors.grayScale1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(CommentData comment) {
    final isUserComment = _isUserComment(comment.userName);
    
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.papayaSensorial.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.papayaSensorial.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: comment.userAvatar != null
                ? ClipOval(
                    child: Image.network(
                      comment.userAvatar!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildDefaultAvatar(comment.userName);
                      },
                    ),
                  )
                : _buildDefaultAvatar(comment.userName),
          ),
          
          SizedBox(width: 12),
          
          // Conteúdo do Comentário
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Nome, Tempo e Menu (se for do usuário)
                Row(
                  children: [
                    Text(
                      comment.userName,
                      style: GoogleFonts.albertSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.carbon,
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
                    // Menu de opções (só aparece para comentários do usuário)
                    if (isUserComment)
                      GestureDetector(
                        onTap: () => _showCommentOptionsModal(comment),
                        child: Container(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            AppIcons.dotsThree,
                            color: AppColors.grayScale2,
                            size: 16,
                          ),
                        ),
                      ),
                  ],
                ),
                
                SizedBox(height: 4),
                
                // Texto do Comentário
                Text(
                  comment.content,
                  style: GoogleFonts.albertSans(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
                
                SizedBox(height: 8),
                
                // Ações: Like
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _toggleLike(comment.id),
                      child: Row(
                        children: [
                          Icon(
                            comment.isLiked ? AppIcons.heartFill : AppIcons.heart,
                            size: 16,
                            color: comment.isLiked 
                                ? AppColors.spiced 
                                : AppColors.grayScale2,
                          ),
                          if (comment.likes > 0) ...[
                            SizedBox(width: 4),
                            Text(
                              comment.likes.toString(),
                              style: GoogleFonts.albertSans(
                                fontSize: 12,
                                color: AppColors.grayScale2,
                              ),
                            ),
                          ],
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

  Widget _buildDefaultAvatar(String userName) {
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
    
    return Center(
      child: Text(
        initial,
        style: GoogleFonts.albertSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: avatarColor,
        ),
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.whiteWhite,
        border: Border(
          top: BorderSide(
            color: AppColors.moonAsh,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Avatar do usuário atual
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.papayaSensorial.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.papayaSensorial.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  'V', // Em um app real, viria do UserManager
                  style: GoogleFonts.albertSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.papayaSensorial,
                  ),
                ),
              ),
            ),
            
            SizedBox(width: 12),
            
            // Campo de Texto
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.whiteWhite, // MUDANÇA: de oatWhite para whiteWhite
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
                    enabledBorder: InputBorder.none, // REMOVE BORDA PADRÃO
                    focusedBorder: InputBorder.none, // REMOVE BORDA QUANDO FOCADO
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    filled: false, // REMOVE PREENCHIMENTO AUTOMÁTICO
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
                        AppIcons.forward,
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
}

// Modelo de dados para comentários
class CommentData {
  final String id;
  final String userName;
  final String? userAvatar;
  final String content;
  final DateTime timestamp;
  final int likes;
  final bool isLiked;

  CommentData({
    required this.id,
    required this.userName,
    this.userAvatar,
    required this.content,
    required this.timestamp,
    required this.likes,
    required this.isLiked,
  });
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
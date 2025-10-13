// lib/ui/create_account/widgets/username_selector.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/app_colors.dart';

class UsernameSelector extends StatefulWidget {
  final List<String> suggestions;
  final String? selectedUsername;
  final Function(String) onUsernameSelected;
  final Function(String) onCustomUsernameChanged;
  final bool isLoading;
  final String? customUsernameError;
  final bool isValidatingCustomUsername;

  const UsernameSelector({
    Key? key,
    required this.suggestions,
    required this.selectedUsername,
    required this.onUsernameSelected,
    required this.onCustomUsernameChanged,
    this.isLoading = false,
    this.customUsernameError,
    this.isValidatingCustomUsername = false,
  }) : super(key: key);

  @override
  _UsernameSelectorState createState() => _UsernameSelectorState();
}

class _UsernameSelectorState extends State<UsernameSelector> {
  bool _showCustomField = false;
  bool _isFieldFocused = false;
  final TextEditingController _customUsernameController = TextEditingController();
  final FocusNode _customUsernameFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _customUsernameFocus.addListener(() {
      setState(() {
        _isFieldFocused = _customUsernameFocus.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _customUsernameController.dispose();
    _customUsernameFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.whiteWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.moonAsh.withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.papayaSensorial),
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Gerando sugestões de username...',
              style: GoogleFonts.albertSans(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (widget.suggestions.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.alternate_email,
              size: 18,
              color: AppColors.pear,
            ),
            SizedBox(width: 8),
            Text(
              'Escolha seu username',
              style: GoogleFonts.albertSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            // Sugestões de username
            ...widget.suggestions.map((username) {
              final isSelected = username == widget.selectedUsername && !_showCustomField;
              
              return _buildUsernameTag(
                username: username,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    _showCustomField = false;
                  });
                  widget.onUsernameSelected(username);
                },
              );
            }).toList(),
            
            // Tag "Outro"
            _buildUsernameTag(
              username: 'Outro',
              isSelected: _showCustomField,
              isCustom: true,
              onTap: () {
                setState(() {
                  _showCustomField = !_showCustomField;
                  if (!_showCustomField) {
                    _customUsernameController.clear();
                  }
                });
              },
            ),
          ],
        ),
        
        // Campo customizado
        if (_showCustomField) ...[
          SizedBox(height: 16),
          _buildCustomUsernameField(),
        ],
      ],
    );
  }

  Widget _buildUsernameTag({
    required String username,
    required bool isSelected,
    required VoidCallback onTap,
    bool isCustom = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.pear : AppColors.whiteWhite,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: AppColors.pear,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected && !isCustom) ...[
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.forestInk,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  size: 16,
                  color: AppColors.whiteWhite,
                ),
              ),
              SizedBox(width: 10),
            ],
            if (isCustom) ...[
              Icon(
                Icons.edit_outlined,
                size: 18,
                color: AppColors.carbon,
              ),
              SizedBox(width: 8),
            ],
            Text(
              username,
              style: GoogleFonts.albertSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.carbon,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomUsernameField() {
    final hasError = widget.customUsernameError != null;
    final isValid = !hasError && 
                    widget.selectedUsername != null && 
                    _customUsernameController.text.isNotEmpty &&
                    !widget.isValidatingCustomUsername;
    
    Color borderColor;
    if (hasError) {
      borderColor = AppColors.spiced;
    } else {
      borderColor = AppColors.pear;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: AppColors.whiteWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: 2,
            ),
          ),
          child: TextField(
            controller: _customUsernameController,
            focusNode: _customUsernameFocus,
            onChanged: (value) {
              widget.onCustomUsernameChanged(value.toLowerCase());
            },
            style: GoogleFonts.albertSans(
              fontSize: 16,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              prefixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: 16),
                  Text(
                    '@',
                    style: GoogleFonts.albertSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.carbon,
                    ),
                  ),
                  SizedBox(width: 4),
                ],
              ),
              prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
              suffixIcon: _buildSuffixIcon(hasError, isValid),
              hintText: 'seu_username',
              hintStyle: GoogleFonts.albertSans(
                fontSize: 16,
                color: AppColors.textSecondary.withOpacity(0.5),
                fontWeight: FontWeight.w400,
              ),
              filled: true,
              fillColor: Colors.transparent,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 18),
            ),
          ),
        ),
        if (hasError) ...[
          SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.error_outline,
                size: 16,
                color: AppColors.spiced,
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.customUsernameError!,
                  style: GoogleFonts.albertSans(
                    fontSize: 13,
                    color: AppColors.spiced,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
        if (isValid) ...[
          SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 16,
                color: AppColors.carbon,
              ),
              SizedBox(width: 6),
              Text(
                'Username disponível',
                style: GoogleFonts.albertSans(
                  fontSize: 13,
                  color: AppColors.carbon,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget? _buildSuffixIcon(bool hasError, bool isValid) {
    if (widget.isValidatingCustomUsername) {
      return Padding(
        padding: EdgeInsets.only(right: 12),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.pear),
          ),
        ),
      );
    }
    
    if (hasError && _customUsernameController.text.isNotEmpty) {
      return Padding(
        padding: EdgeInsets.only(right: 12),
        child: Icon(
          Icons.close_rounded,
          color: AppColors.spiced,
          size: 24,
        ),
      );
    }
    
    if (isValid) {
      return Padding(
        padding: EdgeInsets.only(right: 12),
        child: Icon(
          Icons.check_circle_outline,
          color: AppColors.pear,
          size: 24,
        ),
      );
    }
    
    return null;
  }
}
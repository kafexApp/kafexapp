import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_buttons.dart';
import '../services/location_service.dart';
import '../models/user_location.dart';

class LocationPermissionDialog extends StatefulWidget {
  final Function(UserLocation?) onLocationResult;

  const LocationPermissionDialog({
    Key? key,
    required this.onLocationResult,
  }) : super(key: key);

  @override
  _LocationPermissionDialogState createState() => _LocationPermissionDialogState();
}

class _LocationPermissionDialogState extends State<LocationPermissionDialog> {
  bool _isLoading = false;

  Future<void> _requestLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final location = await LocationService.instance.getCurrentLocation();
      widget.onLocationResult(location);
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      widget.onLocationResult(null);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  void _skipLocation() {
    widget.onLocationResult(null);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.whiteWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícone de localização Phosphor
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.papayaSensorial.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                PhosphorIcons.mapPin(),
                size: 40,
                color: AppColors.papayaSensorial,
              ),
            ),

            SizedBox(height: 24),

            // Título
            Text(
              'Personalize seu rolê do café',
              textAlign: TextAlign.center,
              style: GoogleFonts.albertSans(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),

            SizedBox(height: 12),

            // Descrição
            Text(
              'Deixe a gente mostrar as cafeterias que estão próximas de você agora e criaremos uma curadoria top de lugares pra você visitar.',
              textAlign: TextAlign.center,
              style: GoogleFonts.albertSans(
                fontSize: 14,
                color: AppColors.grayScale1,
                height: 1.4,
              ),
            ),

            SizedBox(height: 32),

            // Botões
            if (_isLoading) ...[
              Container(
                height: 48,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.papayaSensorial,
                    ),
                  ),
                ),
              ),
            ] else ...[
              // Botão permitir
              PrimaryButton(
                text: 'Permitir localização',
                onPressed: _requestLocation,
              ),

              SizedBox(height: 12),

              // Botão pular
              CustomTextButton(
                text: 'Pular por agora',
                onPressed: _skipLocation,
                textColor: AppColors.grayScale1,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
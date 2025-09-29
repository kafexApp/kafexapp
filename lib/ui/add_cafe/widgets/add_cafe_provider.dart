import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/repositories/places_submission_repository.dart';
import '../../../data/repositories/cafe_submission_repository.dart';
import '../viewmodel/add_cafe_viewmodel.dart';
import 'add_cafe_screen.dart';

class AddCafeProvider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Repositories
        Provider<PlacesSubmissionRepository>(
          create: (_) => PlacesSubmissionRepositoryImpl(),
        ),
        Provider<CafeSubmissionRepository>(
          create: (_) => CafeSubmissionRepositoryImpl(),
        ),
        
        // ViewModel
        ChangeNotifierProvider<AddCafeViewModel>(
          create: (context) => AddCafeViewModel(
            placesRepository: context.read<PlacesSubmissionRepository>(),
            submissionRepository: context.read<CafeSubmissionRepository>(),
          ),
        ),
      ],
      child: AddCafeScreen(),
    );
  }
}
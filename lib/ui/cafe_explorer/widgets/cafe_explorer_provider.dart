import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/repositories/cafe_repository.dart';
import '../../../data/repositories/places_repository.dart';
import '../../../data/services/google_places_service.dart';
import '../../../data/services/clustering_service.dart';
import '../viewmodel/cafe_explorer_viewmodel.dart';
import 'cafe_explorer_screen.dart';

class CafeExplorerProvider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services
        Provider<GooglePlacesService>(
          create: (_) => GooglePlacesService(),
        ),
        Provider<ClusteringService>(
          create: (_) => ClusteringService(),
        ),
        
        // Repositories
        Provider<CafeRepository>(
          create: (_) => CafeRepositoryImpl(),
        ),
        Provider<PlacesRepository>(
          create: (context) => PlacesRepositoryImpl(
            placesService: context.read<GooglePlacesService>(),
          ),
        ),
        
        // ViewModel
        ChangeNotifierProvider<CafeExplorerViewModel>(
          create: (context) => CafeExplorerViewModel(
            cafeRepository: context.read<CafeRepository>(),
            placesRepository: context.read<PlacesRepository>(),
            clusteringService: context.read<ClusteringService>(),
          ),
        ),
      ],
      child: CafeExplorerScreen(),
    );
  }
}
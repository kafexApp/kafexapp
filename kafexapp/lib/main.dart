// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';
import 'utils/app_colors.dart';
import 'screens/splash_screen.dart';
import 'ui/home/widgets/home_screen_provider.dart';
import 'data/repositories/cafe_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase inicializado com sucesso!');
  } catch (e) {
    print('❌ Erro ao inicializar Firebase: $e');
  }

  await Supabase.initialize(
    url: 'https://mroljkgkiseuqlwlaibu.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1yb2xqa2draXNldXFsd2xhaWJ1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY3MDc3NzQsImV4cCI6MjA2MjI4Mzc3NH0.umy8tSCMmO1_goqX0TpO-coC2K6FXnwwZVQpqDDMrmw',
  );

  runApp(KafexApp());
}

class KafexApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provider do CafeRepository para acesso global
        Provider<CafeRepository>(
          create: (_) => CafeRepositoryImpl(),
        ),
        // Adicione outros providers aqui conforme necessário
      ],
      child: MaterialApp(
        title: 'Kafex',
        theme: AppTheme.lightTheme,
        home: SplashScreen(),
        debugShowCheckedModeBanner: false,
        // ROTA TEMPORÁRIA PARA TESTES
        routes: {
          '/home-test': (context) => const HomeScreenProvider(),
        },
      ),
    );
  }
}
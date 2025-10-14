// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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

  print('🔍 Diagnóstico - kIsWeb: $kIsWeb');
  
  runApp(KafexApp());
}

class KafexApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget app = MultiProvider(
      providers: [
        Provider<CafeRepository>(
          create: (_) => CafeRepositoryImpl(),
        ),
      ],
      child: MaterialApp(
        title: 'Kafex',
        theme: AppTheme.lightTheme,
        home: SplashScreen(),
        debugShowCheckedModeBanner: false,
        routes: {
          '/home-test': (context) => const HomeScreenProvider(),
        },
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                print('📏 Largura detectada: $width');
                
                if (kIsWeb && width > 600) {
                  print('✅ Aplicando centralização - Desktop detectado');
                  return Container(
                    color: const Color(0xFF333333),
                    child: Center(
                      child: Container(
                        width: 480,
                        constraints: BoxConstraints(
                          maxHeight: constraints.maxHeight,
                        ),
                        child: ClipRect(
                          child: child ?? const SizedBox(),
                        ),
                      ),
                    ),
                  );
                }
                
                print('📱 Layout mobile mantido');
                return child ?? const SizedBox();
              },
            ),
          );
        },
      ),
    );

    return app;
  }
}

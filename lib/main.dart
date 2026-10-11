import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'services/storage_service.dart';
import 'services/ai_summary_service.dart';
import 'services/place_repository.dart';
import 'screens/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  final storageService = await StorageService.create();
  final aiSummaryService = AiSummaryService();
  final repository = PlaceRepository(
    storageService: storageService,
    aiSummaryService: aiSummaryService,
  );

  await repository.initialize();

  runApp(AccessPathApp(repository: repository));
}

class AccessPathApp extends StatelessWidget {
  final PlaceRepository repository;

  const AccessPathApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AccessPath',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: MainShell(repository: repository),
    );
  }
}

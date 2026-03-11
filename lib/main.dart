import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/detail_template_provider.dart';
import 'providers/estimate_provider.dart';
import 'providers/estimate_template_provider.dart';
import 'screens/home_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EstimateProvider()),
        ChangeNotifierProvider(create: (_) => DetailTemplateProvider()),
        ChangeNotifierProvider(create: (_) => EstimateTemplateProvider()),
      ],
      child: MaterialApp(
        title: '대운공조시스템 - 에어컨 견적서',
        theme: AppTheme.theme,
        debugShowCheckedModeBanner: false,
        home: const HomeScreen(),
      ),
    );
  }
}

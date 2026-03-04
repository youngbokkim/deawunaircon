import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/estimate_provider.dart';
import 'screens/home_screen.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final provider = EstimateProvider();
        provider.loadSampleEstimatesIfEmpty();
        return provider;
      },
      child: MaterialApp(
        title: '대운공조시스템 - 에어컨 견적서',
        theme: AppTheme.theme,
        debugShowCheckedModeBanner: false,
        home: const HomeScreen(),
      ),
    );
  }
}

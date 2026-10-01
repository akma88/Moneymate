import 'package:flutter/material.dart';
import 'home_screen.dart';

void main() {
  runApp(const MoneyMateApp());
}

class MoneyMateApp extends StatelessWidget {
  const MoneyMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoneyMate',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F8F6),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D60)),
        useMaterial3: true,
      ),

      home: const HomeScreen(),
    );
  }
}

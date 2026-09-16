import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/forum_provider.dart';
import 'providers/auth_provider.dart';
import 'views/home_page.dart';

void main() {
  runApp(const HuagongcnApp());
}

class HuagongcnApp extends StatelessWidget {
  const HuagongcnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ForumProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: '化工机械研究论坛',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0F4C81),
            primary: const Color(0xFF0F4C81),
            secondary: const Color(0xFF2B6CB0),
            surface: const Color(0xFFF7FAFC),
          ),
          fontFamily: '-apple-system',
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0F4C81),
            foregroundColor: Colors.white,
            elevation: 1,
            centerTitle: false,
          ),
          cardTheme: CardTheme(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            color: Colors.white,
          ),
        ),
        home: const HomePage(),
      ),
    );
  }
}

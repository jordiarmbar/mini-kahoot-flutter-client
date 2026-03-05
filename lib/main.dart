import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens_client.dart';

const kKahootPurple = Color(0xFF46178F);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyBJETRE4_Z-BARcg6TlGkDa_53IDXqDA8Y',
      appId: '1:488983629429:android:86bf24f417d58f3f65323c',
      messagingSenderId: '488983629429',
      projectId: 'mini-kahoot-7741b',
      storageBucket: 'mini-kahoot-7741b.firebasestorage.app',
    ),
  );
  runApp(const ClienteApp());
}

class ClienteApp extends StatelessWidget {
  const ClienteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kahoot Cliente',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: kKahootPurple),
        scaffoldBackgroundColor: kKahootPurple,
        appBarTheme: const AppBarTheme(
          backgroundColor: kKahootPurple,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white12,
          labelStyle: const TextStyle(color: Colors.white70),
          hintStyle: const TextStyle(color: Colors.white38),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white24),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white, width: 2),
          ),
        ),
        useMaterial3: true,
      ),
      home: const ClientJoinScreen(),
    );
  }
}

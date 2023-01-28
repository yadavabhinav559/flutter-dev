import 'package:flutter/material.dart';
import 'home_page.dart';
import 'package:firebase_core/firebase_core.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyBV8cm5Dv3hyvSOgLh5CRoFWYA6HBpQAJg",
          authDomain: "snakegame-d018b.firebaseapp.com",
          projectId: "snakegame-d018b",
          storageBucket: "snakegame-d018b.appspot.com",
          messagingSenderId: "35287748620",
          appId: "1:35287748620:web:1b7e08d879e16acda39e29",
          measurementId: "G-DGRNFXL3M9"));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
    
  }
}

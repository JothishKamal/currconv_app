import 'package:currconv_app/pages/profile.dart';
import 'package:flutter/material.dart';
import 'package:currconv_app/pages/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Poppins',),
        home: const HomePage(),
        routes: {
          '/homepage': (context) => const HomePage(),
          '/profilepage': (context) => const ProfilePage(),
        });
  }
}

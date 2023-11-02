import 'package:flutter/material.dart';
import 'package:weather_app/View/Home_screen.dart';
import 'package:weather_app/View/Splash_screen.dart';
import 'package:weather_app/View/next_days.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        
       
        useMaterial3: true,
      ),
      home: SplashScreen(),

    );
  }
}





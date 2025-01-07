import 'package:flutter/material.dart';

import 'Screens/RoutineScreen.dart';
import 'Screens/StreaksScreen.dart';

void main(){
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Skincare App',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      // Define routes for navigation
      initialRoute: '/routine',
      routes: {
        '/routine': (context) => RoutineScreen(),
        '/streaks': (context) => StreaksScreen(),
      },
    );
  }
}
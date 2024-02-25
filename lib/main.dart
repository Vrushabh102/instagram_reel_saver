import 'package:flutter/material.dart';
import 'package:instagram_reel_saver/screens/home_screen.dart';
import 'package:instagram_reel_saver/themes/themes.dart';

void main(){
  runApp(
    MaterialApp(
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
      theme: lightMode,
      darkTheme: darkMode,

    ),
  );
}


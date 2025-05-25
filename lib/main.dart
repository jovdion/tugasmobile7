
import 'screens/clothing_list_screen.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(ClothingApp());
}

class ClothingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clothing Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ClothingListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}




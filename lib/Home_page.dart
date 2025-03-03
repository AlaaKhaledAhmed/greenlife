import 'dart:ui';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final String firstName;
  final String lastName;

  const HomePage({super.key, required this.firstName, required this.lastName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'مرحبًا $firstName $lastName!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    //   body: Center(
    //     child: Text(
    //       'home page'
    //     ),
    //  ),
);
}
}
import 'package:flutter/material.dart';

class PetsScreen extends StatelessWidget {

  const PetsScreen({super.key});

  @override
  Widget build(BuildContext context) {

      return Scaffold(
        appBar: AppBar(
          title: Text("My Pets"),
        ),

        body: const Center(
          child : Text(
            'Pets will  appear here',
            style: TextStyle(
              fontSize: 24,
            ),
          )

        ),
      );
  }

}
import 'package:flutter/material.dart';

class LoadingStudentScreen extends StatelessWidget {
  const LoadingStudentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blue.withOpacity(.3),
          ),
          const SizedBox(height: 15,),
          const Text("Please wait, while we load your student...")
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';

class FurdleDialog extends StatelessWidget {
  final String title;
  final String message;

  FurdleDialog({Key? key, required this.title, required this.message})
      : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 0.5,
      child: Container(
        width: 350,
        height: 200,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              '$title',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text('$message'),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/src/go_router.dart';

class ErrorPage extends StatelessWidget {
  final String errorMessage;
  ErrorPage({Key? key, this.errorMessage = "Error 404 not found"})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
            child: Text('Go Home'), onPressed: () => context.go('/')),
      ),
    );
  }
}

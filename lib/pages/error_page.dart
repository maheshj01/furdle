import 'package:flutter/material.dart';
import 'package:furdle/pages/playground.dart';
import 'package:go_router/go_router.dart';

class ErrorPage extends StatefulWidget {
  const ErrorPage({Key? key}) : super(key: key);

  @override
  State<ErrorPage> createState() => _ErrorPageState();
}

class _ErrorPageState extends State<ErrorPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Uh oh!\n You have lost your way.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              TextButton(
                child: const Text('Go Home 🏠'),
                onPressed: () => context.replace(PlayGround.path),
              )
            ],
          ),
        ));
  }
}

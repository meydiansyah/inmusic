import 'package:flutter/material.dart';

class ErrorConnection extends StatelessWidget {
  final VoidCallback update;
  const ErrorConnection({required this.update, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "No Internet Connection",
            style: Theme.of(context).primaryTextTheme.bodyMedium,
          ),
          OutlinedButton(
            onPressed: update,
            child: const Text("RETRY"),
          ),
        ],
      ),
    );
  }
}

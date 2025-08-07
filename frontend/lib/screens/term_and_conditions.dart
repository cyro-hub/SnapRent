import 'package:flutter/material.dart';
import '../components/safe_scaffold.dart';

class TermAndConditionsScreen extends StatelessWidget {
  const TermAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeScaffold(
      child: const Center(
        child: Text(
          "🎉 Welcome to the Home Screen!",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

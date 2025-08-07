import 'package:flutter/material.dart';

class SafeScaffold extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;

  const SafeScaffold({super.key, required this.child, this.appBar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: appBar,
      body: SafeArea(
        left: true,
        right: true,
        minimum: EdgeInsets.all(12.0),
        child: child,
      ),
    );
  }
}

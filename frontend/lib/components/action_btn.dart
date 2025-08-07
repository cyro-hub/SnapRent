import 'package:flutter/material.dart';

class ActionBotton extends StatefulWidget {
  const ActionBotton({super.key});

  @override
  State<ActionBotton> createState() => _ActionBottonState();
}

class _ActionBottonState extends State<ActionBotton> {
  String btnText = "botton";

  _ActionBottonState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: const Center(child: Text("hi")));
  }
}

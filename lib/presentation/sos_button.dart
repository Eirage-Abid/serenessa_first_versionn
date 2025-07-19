import 'package:flutter/material.dart';


class SOSButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SOSButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: Colors.red,
      child: const Icon(Icons.sos, size: 30, color: Colors.white),
    );
  }
}

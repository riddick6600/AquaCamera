import 'package:flutter/material.dart';

class AboutButton extends StatelessWidget {
  const AboutButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      heroTag: 'about-button',
      tooltip: 'О приложении',
      onPressed: onPressed,
      child: const Icon(Icons.info_outline),
    );
  }
}

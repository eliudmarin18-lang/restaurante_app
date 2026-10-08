import 'package:flutter/material.dart';

// Definimos la constante localmente si no la detecta del otro archivo
class BotonPersonalizado extends StatelessWidget {
  final String texto;
  final VoidCallback? onPressed;
  final Color color;

  const BotonPersonalizado({
    super.key,
    required this.texto,
    required this.onPressed,
    this.color = Colors.deepOrange,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          texto,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
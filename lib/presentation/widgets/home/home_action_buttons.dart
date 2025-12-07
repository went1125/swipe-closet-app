import 'package:flutter/material.dart';

class HomeActionButtons extends StatelessWidget {
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;

  const HomeActionButtons({
    super.key,
    required this.onSwipeLeft,
    required this.onSwipeRight,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildButton(
            icon: Icons.close,
            color: Colors.red,
            onPressed: onSwipeLeft,
          ),
          _buildButton(
            icon: Icons.favorite,
            color: Colors.green,
            onPressed: onSwipeRight,
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return IconButton.filled(
      onPressed: onPressed,
      icon: Icon(icon, size: 30),
      style: IconButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: color,
        iconSize: 30,
        elevation: 5, // 加一點陰影更有質感
      ),
    );
  }
}
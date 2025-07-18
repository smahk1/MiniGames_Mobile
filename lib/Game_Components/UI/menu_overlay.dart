import 'package:flutter/material.dart';

class MenuOverlay extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onGoHome;

  const MenuOverlay({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onGoHome,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background blur or dim effect
        Container(
          color: Colors.black45,
        ),

        // Centered menu
        Center(
          child: Container(
            width: 250,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.brown[200],
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Game Paused',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: onResume,
                  child: const Text('Resume'),
                ),
                ElevatedButton(
                  onPressed: onRestart,
                  child: const Text('Restart'),
                ),
                ElevatedButton(
                  onPressed: onGoHome,
                  child: const Text('Home'),
                ),
              ],
            ),
          ),
        ),

        // Top-right settings button
        Positioned(
          top: 30,
          right: 20,
          child: IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // Settings logic placeholder
              // e.g. showDialog(...)
            },
          ),
        ),
      ],
    );
  }
}

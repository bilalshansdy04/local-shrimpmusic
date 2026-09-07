import "package:flutter/material.dart";

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.library_music_rounded, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text("Your Library", style: TextStyle(color: Colors.grey[800], fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Albums, Artists, and more will appear here.", style: TextStyle(color: Colors.grey[500], fontSize: 14)),
          ],
        ),
      ),
    );
  }
}


import "package:flutter/material.dart";

class PlaylistsScreen extends StatelessWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.queue_music_rounded, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text("Your Playlists", style: TextStyle(color: Colors.grey[800], fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Create your first playlist.", style: TextStyle(color: Colors.grey[500], fontSize: 14)),
          ],
        ),
      ),
    );
  }
}


import "package:flutter/material.dart";

class FavoriteSongsScreen extends StatelessWidget {
  const FavoriteSongsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_outline_rounded, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text("No Favorites Yet", style: TextStyle(color: Colors.grey[800], fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Songs you like will appear here.", style: TextStyle(color: Colors.grey[500], fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

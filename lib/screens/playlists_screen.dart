import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/music_provider.dart';
import '../screens/playlist_detail_screen.dart';
import '../widgets/create_playlist_sheet.dart';

class PlaylistsScreen extends ConsumerWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final musicState = ref.watch(musicProvider);
    final playlists = musicState.playlists;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 32.0, right: 32.0, top: 48.0, bottom: 180.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Playlists",
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showCreatePlaylistSheet(context, ref),
              icon: const Icon(Icons.add_rounded),
              label: const Text("Create Playlist"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4500),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
            ),
            const SizedBox(height: 24),
            if (playlists.isEmpty)
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.queue_music_rounded, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text("Your Playlists", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text("Create your first playlist.", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              )
            else
              ...playlists.map((pl) {
                return GestureDetector(
                  onTap: () {
                    // Use a simple route for now, or a details screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlaylistDetailScreen(playlistId: pl.id),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: const Icon(Icons.queue_music_rounded, color: Color(0xFFFF4500), size: 32),
                      title: Text(pl.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("${pl.songIds.length} songs"),
                      trailing: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_horiz_rounded, color: Colors.grey, size: 20),
                        onSelected: (value) => _handlePlaylistMenu(context, ref, pl.id, value),
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'open', child: Text('Open')),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete', style: TextStyle(color: Colors.red[400])),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  void _handlePlaylistMenu(BuildContext context, WidgetRef ref, String playlistId, String value) {
    if (value == 'open') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlaylistDetailScreen(playlistId: playlistId),
        ),
      );
    } else if (value == 'delete') {
      ref.read(musicProvider.notifier).deletePlaylist(playlistId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Playlist deleted'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _showCreatePlaylistSheet(BuildContext context, WidgetRef ref) async {
    final result = await showCreatePlaylistSheet(context);
    if (result != null && result.isNotEmpty) {
      ref.read(musicProvider.notifier).createPlaylist(result);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Playlist "$result" created'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }
}


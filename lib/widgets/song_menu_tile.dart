import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../providers/music_provider.dart';

class SongMenuTile extends ConsumerWidget {
  final SongModel song;

  const SongMenuTile({super.key, required this.song});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final musicState = ref.watch(musicProvider);
    final isFav = musicState.favoriteSongs.any((s) => s.id == song.id);

    return PopupMenuButton<String>(
      icon: const Icon(
        Icons.more_horiz_rounded,
        color: Colors.grey,
        size: 20,
      ),
      onSelected: (value) => _handleTap(context, ref, value, isFav),
      itemBuilder: (context) => [
        // Add to Playlist
        PopupMenuItem<String>(
          value: 'playlist',
          child: Row(
            children: [
              Icon(Icons.playlist_add_rounded, color: Colors.grey[700], size: 20),
              const SizedBox(width: 12),
              const Text('Add to Playlist'),
            ],
          ),
        ),
        // Favorite / Unfavorite
        PopupMenuItem<String>(
          value: 'favorite',
          child: Row(
            children: [
              Icon(
                isFav ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                color: isFav ? const Color(0xFFFF4500) : Colors.grey[700],
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(isFav ? 'Unfavorite' : 'Favorite'),
            ],
          ),
        ),
        // Add to Queue
        PopupMenuItem<String>(
          value: 'queue',
          child: Row(
            children: [
              Icon(Icons.queue_rounded, color: Colors.grey[700], size: 20),
              const SizedBox(width: 12),
              const Text('Add to Queue'),
            ],
          ),
        ),
      ],
    );
  }

  void _handleTap(BuildContext context, WidgetRef ref, String value, bool isFav) {
    switch (value) {
      case 'favorite':
        ref.read(musicProvider.notifier).toggleFavorite(song);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isFav ? 'Removed from favorites' : 'Added to favorites'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        break;
      case 'queue':
        ref.read(musicProvider.notifier).addToQueue(song);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added to queue'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        break;
      case 'playlist':
        // Show playlist selection dialog
        _showPlaylistPicker(context, ref);
        break;
    }
  }

  void _showPlaylistPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Add to Playlist',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.add_rounded, color: Color(0xFFFF4500)),
                title: const Text('New Playlist'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Playlist creation coming soon'),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../providers/music_provider.dart';
import '../widgets/create_playlist_sheet.dart';

class SongMenuTile extends ConsumerWidget {
  final SongModel song;
  final String? playlistId; // If inside playlist, use remove instead of favorite toggle

  const SongMenuTile({super.key, required this.song, this.playlistId});

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
        if (playlistId == null) ...[
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
        ],
        if (playlistId != null) ...[
          // Remove from Playlist
          PopupMenuItem<String>(
            value: 'remove',
            child: Row(
              children: [
                Icon(Icons.remove_from_queue_rounded, color: Colors.red[400], size: 20),
                const SizedBox(width: 12),
                Text('Remove from Playlist', style: TextStyle(color: Colors.red[400])),
              ],
            ),
          ),
        ],
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
        _showPlaylistPicker(context, ref);
        break;
      case 'remove':
        ref.read(musicProvider.notifier).removeSongFromPlaylist(playlistId!, song);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed from playlist'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        break;
    }
  }

  Future<void> _showPlaylistPicker(BuildContext context, WidgetRef ref) async {
    final playlists = ref.read(musicProvider).playlists;

    await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 40,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Add to Playlist',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
              ),
              const SizedBox(height: 4),
              Text(
                'Choose a playlist',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
              const SizedBox(height: 20),

              // New playlist option
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3EE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add_rounded, color: Color(0xFFFF4500), size: 20),
                ),
                title: const Text('Create New Playlist', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () async {
                  Navigator.pop(context);
                  final name = await showCreatePlaylistSheet(context);
                  if (name != null && name.isNotEmpty) {
                    ref.read(musicProvider.notifier).addSongToPlaylist(name, song);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added to "$name"'),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    }
                  }
                },
              ),

              const Divider(height: 1, indent: 16, endIndent: 16),

              // Existing playlists
              if (playlists.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text('No playlists yet', style: TextStyle(color: Colors.grey, fontSize: 14)),
                )
              else
                ...playlists.map((pl) {
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3EE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.queue_music_rounded, color: Color(0xFFFF4500), size: 20),
                    ),
                    title: Text(pl.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${pl.songIds.length} song${pl.songIds.length == 1 ? '' : 's'}'),
                    onTap: () async {
                      Navigator.pop(context);
                      ref.read(musicProvider.notifier).addSongToPlaylist(pl.id, song);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Added to "${pl.name}"'),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      }
                    },
                  );
                }),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

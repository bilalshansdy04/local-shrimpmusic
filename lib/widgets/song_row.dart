import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../providers/music_provider.dart';
import 'song_menu_tile.dart';

class SongRow extends ConsumerWidget {
  final int index;
  final SongModel song;
  final String? playlistId;
  final VoidCallback? onTap;

  const SongRow({super.key, required this.index, required this.song, this.playlistId, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artworkAsync = ref.watch(artworkProvider(song.data));
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(
          children: [
            Text(
              "${index + 1}",
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(width: 16),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: artworkAsync.when(
                data: (bytes) {
                  if (bytes != null) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: RepaintBoundary(
                        child: Image.file(bytes, fit: BoxFit.cover, cacheWidth: 100),
                      ),
                    );
                  }
                  return const Icon(Icons.music_note, color: Colors.grey);
                },
                loading: () => const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                error: (_, _) => const Icon(Icons.music_note, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(song.title, style: const TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(song.artist ?? "Unknown Artist", style: TextStyle(color: Colors.grey[600], fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Text(song.album ?? "Unknown Album", style: TextStyle(color: Colors.grey[600], fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text("${(song.duration ?? 0) ~/ 60000}:${(((song.duration ?? 0) % 60000) ~/ 1000).toString().padLeft(2, '0')}", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                  const SizedBox(width: 16),
                  SongMenuTile(song: song, playlistId: playlistId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../providers/music_provider.dart';
import '../widgets/song_menu_tile.dart';

class PlaylistDetailScreen extends ConsumerWidget {
  final String playlistId;

  const PlaylistDetailScreen({super.key, required this.playlistId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final musicState = ref.watch(musicProvider);

    final playlist = musicState.playlists
        .where((p) => p.id == playlistId)
        .firstOrNull;

    if (playlist == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.queue_music_rounded, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text("Playlist not found",
                  style: TextStyle(color: Colors.grey[800], fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
    }

    final songs = playlist.songIds
        .map((id) => musicState.allSongs
            .where((s) => s.id.toString() == id.toString())
            .firstOrNull)
        .whereType<SongModel>()
        .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          // Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 32.0, right: 32.0, top: 48.0, bottom: 24.0),
              child: Text(
                playlist.name,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),

          // Action buttons (Play All + Shuffle)
          if (songs.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 32.0, right: 32.0, bottom: 24.0),
                child: Row(
                  children: [
                    // Play All
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          ref.read(musicProvider.notifier).playSong(
                                songs.first,
                                contextList: songs,
                              );
                        },
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF4500), Color(0xFFFF6B35)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF4500).withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                              SizedBox(width: 8),
                              Text(
                                'Play All',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Shuffle Play
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          final shuffled = List.of(songs)..shuffle();
                          ref.read(musicProvider.notifier).playSong(
                                shuffled.first,
                                contextList: shuffled,
                              );
                        },
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey[200]!),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shuffle_rounded, color: Colors.grey[700], size: 22),
                              const SizedBox(width: 8),
                              Text(
                                'Shuffle',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Song list (same as Library/Favorite)
          if (songs.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Column(
                  children: [
                    Icon(Icons.music_off_rounded, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text("No songs in this playlist",
                        style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                    const SizedBox(height: 8),
                    Text("Add songs from the song menu",
                        style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final song = songs[index];
                  return InkWell(
                    onTap: () {
                      ref.read(musicProvider.notifier).playSong(
                            song,
                            contextList: songs,
                          );
                    },
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
                            child: Consumer(
                              builder: (context, ref, child) {
                                final artworkAsync = ref.watch(artworkProvider(song.data));
                                return artworkAsync.when(
                                  data: (bytes) {
                                    if (bytes != null) {
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(bytes, fit: BoxFit.cover, cacheWidth: 100),
                                      );
                                    }
                                    return const Icon(Icons.music_note, color: Colors.grey);
                                  },
                                  loading: () => const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  ),
                                  error: (_, _) => const Icon(Icons.music_note, color: Colors.grey),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  song.title,
                                  style: const TextStyle(
                                    color: Color(0xFF111827),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  song.artist ?? "Unknown Artist",
                                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            "${(song.duration ?? 0) ~/ 60000}:${(((song.duration ?? 0) % 60000) ~/ 1000).toString().padLeft(2, '0')}",
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                          const SizedBox(width: 8),
                          SongMenuTile(song: song, playlistId: playlistId),
                        ],
                      ),
                    ),
                  );
                }, childCount: songs.length),
              ),
            ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 180)),
        ],
      ),
    );
  }
}

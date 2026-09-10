import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../providers/music_provider.dart';
import '../widgets/song_menu_tile.dart';

/// Detail view yang mirror LibraryScreen:
/// - Scaffold transparent (ikut AppLayout: sidebar kiri, right pane kanan, player bawah)
/// - Header: judul playlist di kiri atas
/// - Dibawah judul: tombol Play All + Shuffle secukupnya (compact, kiri)
/// - List di tengah main container pakai layout row identik Library
class PlaylistDetailScreen extends ConsumerWidget {
  final String playlistId;
  final VoidCallback? onBack;

  const PlaylistDetailScreen({super.key, required this.playlistId, this.onBack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final musicState = ref.watch(musicProvider);
    final playlist = musicState.playlists.where((p) => p.id == playlistId).firstOrNull;

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
        .map((id) => musicState.allSongs.where((s) => s.id.toString() == id.toString()).firstOrNull)
        .whereType<SongModel>()
        .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          // Header mirip Library: judul + back jika inline
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 32.0, right: 32.0, top: 48.0, bottom: 16.0),
              child: Row(
                children: [
                  if (onBack != null) ...[
                    InkWell(
                      onTap: onBack,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: const Icon(Icons.arrow_back_rounded, size: 20, color: Color(0xFF111827)),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          playlist.name,
                          style: const TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${songs.length} song${songs.length == 1 ? '' : 's'}",
                          style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Play All + Shuffle — compact kiri atas secukupnya
          if (songs.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 32.0, right: 32.0, bottom: 24.0),
                child: Row(
                  children: [
                    _SmallAction(
                      label: 'Play All',
                      icon: Icons.play_arrow_rounded,
                      primary: true,
                      onTap: () => ref.read(musicProvider.notifier).playSong(songs.first, contextList: songs),
                    ),
                    const SizedBox(width: 12),
                    _SmallAction(
                      label: 'Shuffle',
                      icon: Icons.shuffle_rounded,
                      primary: false,
                      onTap: () {
                        final shuffled = List<SongModel>.of(songs)..shuffle();
                        ref.read(musicProvider.notifier).playSong(shuffled.first, contextList: shuffled);
                      },
                    ),
                  ],
                ),
              ),
            ),

          if (songs.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 64),
                child: Column(
                  children: [
                    Icon(Icons.music_off_rounded, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text("No songs in this playlist", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
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
                    onTap: () => ref.read(musicProvider.notifier).playSong(song, contextList: songs),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      child: Row(
                        children: [
                          Text("${index + 1}", style: const TextStyle(color: Colors.grey, fontSize: 14)),
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
                                        child: RepaintBoundary(
                                          child: Image.file(bytes, fit: BoxFit.cover, cacheWidth: 100),
                                        ),
                                      );
                                    }
                                    return const Icon(Icons.music_note, color: Colors.grey);
                                  },
                                  loading: () => const Center(
                                    child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                                  ),
                                  error: (_, _) => const Icon(Icons.music_note, color: Colors.grey),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(song.title,
                                    style: const TextStyle(
                                        color: Color(0xFF111827), fontWeight: FontWeight.bold, fontSize: 16),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                Text(song.artist ?? "Unknown Artist",
                                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Text(song.album ?? "Unknown Album",
                                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ),
                          Expanded(
                            flex: 2,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "${(song.duration ?? 0) ~/ 60000}:${(((song.duration ?? 0) % 60000) ~/ 1000).toString().padLeft(2, '0')}",
                                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                                ),
                                const SizedBox(width: 16),
                                SongMenuTile(song: song, playlistId: playlistId),
                              ],
                            ),
                          ),
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

class _SmallAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool primary;
  final VoidCallback onTap;
  const _SmallAction({required this.label, required this.icon, required this.primary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: primary ? const Color(0xFFFF4500) : Colors.white,
          gradient: primary ? const LinearGradient(colors: [Color(0xFFFF4500), Color(0xFFFF6B35)]) : null,
          borderRadius: BorderRadius.circular(24),
          border: primary ? null : Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: (primary ? const Color(0xFFFF4500) : Colors.black).withValues(alpha: primary ? 0.24 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: primary ? Colors.white : Colors.grey[700], size: 20),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: primary ? Colors.white : Colors.grey[800], fontWeight: FontWeight.w700, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

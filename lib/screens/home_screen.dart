import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:on_audio_query/on_audio_query.dart";

import "../providers/music_provider.dart";
import "../providers/ui_provider.dart";

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final musicState = ref.watch(musicProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: !musicState.hasPermission
          ? const Center(
              child: Text(
                "Storage permission required to scan local music.",
                style: TextStyle(color: Color(0xFF111827)),
              ),
            )
          : musicState.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF4500)),
            )
          : musicState.allSongs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    musicState.musicFolderPath != null
                        ? "No songs found in "
                        : "No local songs found in your default Music folder.",
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () =>
                        ref.read(musicProvider.notifier).pickMusicFolder(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF4500),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    icon: const Icon(Icons.folder_open),
                    label: const Text("Select Music Folder"),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.only(
                top: 48.0,
                bottom: 180.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      "Home",
                      style: TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  _buildHorizontalList(
                    title: "Recently Added",
                    songs: List.from(musicState.allSongs)..sort((a, b) => (b.dateAdded ?? 0).compareTo(a.dateAdded ?? 0)),
                    ref: ref,
                  ),
                  const SizedBox(height: 32),

                  _buildHorizontalList(
                    title: "Recently Played",
                    songs: musicState.recentlyPlayed,
                    ref: ref,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHorizontalList({
    required String title,
    required List<SongModel> songs,
    required WidgetRef ref,
  }) {
    final displaySongs = songs.take(15).toList();
    
    if (displaySongs.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF374151),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            scrollDirection: Axis.horizontal,
            itemCount: displaySongs.length,
            itemBuilder: (context, index) {
              final song = displaySongs[index];
              return Container(
                width: 140,
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                child: InkWell(
                  onTap: () {
                    ref.read(musicProvider.notifier).playSong(song, contextList: displaySongs);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3C2C2),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Consumer(
                          builder: (context, ref, _) {
                            final art = ref.watch(artworkProvider(song.data));
                            return art.when(
                              data: (bytes) {
                                if (bytes != null) {
                                  return ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.file(
                                      bytes,
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                }
                                return const Icon(
                                  Icons.music_note_rounded,
                                  color: Colors.white,
                                  size: 48,
                                );
                              },
                              loading: () => const Center(
                                child: CircularProgressIndicator(color: Colors.white),
                              ),
                              error: (_, __) => const Icon(
                                Icons.music_note_rounded,
                                color: Colors.white,
                                size: 48,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        song.title,
                        style: const TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        song.artist ?? "Unknown",
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:on_audio_query/on_audio_query.dart";
import "../providers/music_provider.dart";
import "../providers/ui_provider.dart";

class FavoriteSongsScreen extends ConsumerWidget {
  const FavoriteSongsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final musicState = ref.watch(musicProvider);
    final songs = musicState.allSongs; // For now, show all songs as mock favorites

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFF4500), Color(0xFF4D030A)],
              stops: [0.0, 1.0],
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 40),
                    ),
                    const SizedBox(width: 24),
                    const Text(
                      "Favorite Songs",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
              ),

              // Controls
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.play_arrow_rounded, color: Color(0xFF9C0817), size: 32),
                        ),
                        const SizedBox(width: 24),
                        const Icon(Icons.shuffle_rounded, color: Colors.white, size: 28),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.search_rounded, color: Colors.white, size: 24),
                        const SizedBox(width: 24),
                        Row(
                          children: const [
                            Text("Artist", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            SizedBox(width: 8),
                            Icon(Icons.sort_rounded, color: Colors.white, size: 20),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Table Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
                child: Row(
                  children: [
                    const SizedBox(width: 40, child: Text("#", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold))),
                    const Expanded(flex: 5, child: Text("Title", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold))),
                    const Expanded(flex: 4, child: Text("Album", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold))),
                    const Expanded(flex: 2, child: Align(alignment: Alignment.centerRight, child: Icon(Icons.access_time_rounded, color: Colors.white70, size: 16))),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Divider(color: Colors.white24),
              ),

              // Track List
              Expanded(
                child: songs.isEmpty
                    ? const Center(child: Text("No favorites yet", style: TextStyle(color: Colors.white)))
                    : ListView.builder(
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 150),
                        itemCount: songs.length,
                        itemBuilder: (context, index) {
                          final song = songs[index];
                          return InkWell(
                            onTap: () {
                              ref.read(musicProvider.notifier).playSong(song);
                              ref.read(playerViewModeProvider.notifier).setMode(PlayerViewMode.lyric);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 40,
                                    child: Text("${index + 1}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                                  Expanded(
                                    flex: 5,
                                    child: Row(
                                      children: [
                                        QueryArtworkWidget(
                                          id: song.id,
                                          type: ArtworkType.AUDIO,
                                          nullArtworkWidget: Container(
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                                            child: const Icon(Icons.music_note, color: Colors.white),
                                          ),
                                          artworkBorder: BorderRadius.circular(8),
                                          artworkWidth: 48,
                                          artworkHeight: 48,
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(song.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                                              const SizedBox(height: 4),
                                              Text(song.artist ?? "Unknown", style: const TextStyle(color: Colors.white70, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Text(song.album ?? "Unknown Album", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          "${(song.duration ?? 0) ~/ 60000}:${(((song.duration ?? 0) % 60000) ~/ 1000).toString().padLeft(2, "0")}",
                                          style: const TextStyle(color: Colors.white70),
                                        ),
                                        const SizedBox(width: 16),
                                        const Icon(Icons.more_horiz_rounded, color: Colors.white70, size: 20),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


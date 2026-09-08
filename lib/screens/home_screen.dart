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
                left: 24.0,
                right: 24.0,
                top: 48.0,
                bottom: 180.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Home",
                    style: TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Recent Played",
                    style: TextStyle(
                      color: Color(0xFF374151),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Grid of Songs
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 24,
                        ),
                    itemCount: musicState.allSongs.length,
                    itemBuilder: (context, index) {
                      final song = musicState.allSongs[index];
                      return InkWell(
                        onTap: () {
                          ref.read(musicProvider.notifier).playSong(song, contextList: musicState.allSongs);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3C2C2),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.05,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Consumer(
                                    builder: (context, ref, child) {
                                      final artworkAsync = ref.watch(
                                        artworkProvider(song.data),
                                      );
                                      return artworkAsync.when(
                                        data: (bytes) {
                                          if (bytes != null) {
                                            return RepaintBoundary(
                                              child: Image.file(
                                                bytes,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: double.infinity,
                                                cacheWidth: 300,
                                              ),
                                            );
                                          }
                                          return const Center(
                                            child: Icon(
                                              Icons.music_note,
                                              color: Colors.white,
                                              size: 48,
                                            ),
                                          );
                                        },
                                        loading: () => const Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                          ),
                                        ),
                                        error: (_, _) => const Center(
                                          child: Icon(
                                            Icons.music_note,
                                            color: Colors.white,
                                            size: 48,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              song.title,
                              style: const TextStyle(
                                color: Color(0xFF111827),
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              song.artist ?? "Unknown",
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

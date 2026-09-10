import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../providers/music_provider.dart";
import "../widgets/song_row.dart";

class FavoriteSongsScreen extends ConsumerWidget {
  const FavoriteSongsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final musicState = ref.watch(musicProvider);
    final favoriteSongs = musicState.favoriteSongs;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: favoriteSongs.isEmpty
          ? Center(
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
            )
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 32.0,
                      right: 32.0,
                      top: 48.0,
                      bottom: 24.0,
                    ),
                    child: Text(
                      "Favorites",
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final song = favoriteSongs[index];
                      return SongRow(
                        index: index,
                        song: song,
                        onTap: () {
                          ref.read(musicProvider.notifier).playSong(song, contextList: favoriteSongs);
                        },
                      );
                    }, childCount: favoriteSongs.length),
                  ),
                ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 180)),
              ],
            ),
    );
  }
}
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../providers/music_provider.dart";
import "../widgets/song_row.dart";

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final musicState = ref.watch(musicProvider);
    final songs = musicState.allSongs;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
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
                "Library",
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
                final song = songs[index];
                return SongRow(
                  index: index,
                  song: song,
                  onTap: () {
                    ref.read(musicProvider.notifier).playSong(song, contextList: songs);
                  },
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
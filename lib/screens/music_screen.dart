import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:on_audio_query/on_audio_query.dart";

import "../providers/ui_provider.dart";
import "../providers/music_provider.dart";

class MusicScreen extends ConsumerStatefulWidget {
  const MusicScreen({super.key});

  @override
  ConsumerState<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends ConsumerState<MusicScreen> {
  double? _dragPosition;

  String formatDuration(Duration d) {
    String minutes = (d.inMinutes % 60).toString().padLeft(2, "0");
    String seconds = (d.inSeconds % 60).toString().padLeft(2, "0");
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(playerViewModeProvider);
    final musicState = ref.watch(musicProvider);
    final song = musicState.currentSong;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F4), // stone-100
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF111827),
            size: 32,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Now Playing",
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Color(0xFF111827)),
            onPressed: () {},
          ),
        ],
      ),
      body: song == null
          ? const Center(child: Text("No song playing"))
          : _buildBody(mode, ref, musicState),
    );
  }

  Widget _buildBody(PlayerViewMode mode, WidgetRef ref, MusicState state) {
    switch (mode) {
      case PlayerViewMode.lyric:
        return _buildLyricView(ref, state);
      case PlayerViewMode.queue:
        return _buildQueueView(ref, state);
      case PlayerViewMode.normal:
      default:
        return _buildNormalView(ref, state);
    }
  }

  Widget _buildNormalView(WidgetRef ref, MusicState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Album Art
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: Consumer(
                    builder: (context, ref, child) {
                      final artworkAsync = ref.watch(
                        artworkProvider(state.currentSong!.data),
                      );
                      return artworkAsync.when(
                        data: (bytes) {
                          if (bytes != null) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(32),
                              child: RepaintBoundary(
                                child: Image.file(
                                  bytes,
                                  fit: BoxFit.cover,
                                  cacheWidth: 800,
                                ),
                              ),
                            );
                          }
                          return _buildFallbackArtwork();
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (_, _) => _buildFallbackArtwork(),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),

          // Title & Artist
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              state.currentSong!.title,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              state.currentSong!.artist ?? "Unknown Artist",
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 32),

          // Slider
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              activeTrackColor: const Color(0xFFEB5424), // Shrimp Orange
              inactiveTrackColor: Colors.grey[300],
              thumbColor: const Color(0xFFEB5424),
            ),
            child: Slider(
              value: (_dragPosition ?? state.position.inMilliseconds.toDouble())
                  .clamp(0.0, state.duration.inMilliseconds.toDouble() > 0 ? state.duration.inMilliseconds.toDouble() : 1.0),
              max: state.duration.inMilliseconds.toDouble() > 0
                  ? state.duration.inMilliseconds.toDouble()
                  : 1.0,
              onChangeStart: (v) {
                setState(() { _dragPosition = v; });
              },
              onChanged: (v) {
                setState(() { _dragPosition = v; });
              },
              onChangeEnd: (v) async {
                final target = v;
                setState(() { _dragPosition = v; });
                await ref.read(musicProvider.notifier).seek(Duration(milliseconds: v.toInt()));
                if (mounted && _dragPosition == target) {
                  setState(() { _dragPosition = null; });
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatDuration(_dragPosition != null ? Duration(milliseconds: _dragPosition!.toInt()) : state.position),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  formatDuration(state.duration),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(Icons.shuffle_rounded, color: Colors.grey[600]),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(
                  Icons.skip_previous_rounded,
                  color: Color(0xFF111827),
                  size: 40,
                ),
                onPressed: () => ref.read(musicProvider.notifier).previous(),
              ),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFEB5424),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFDC5028).withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    state.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                  onPressed: () =>
                      ref.read(musicProvider.notifier).togglePlay(),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.skip_next_rounded,
                  color: Color(0xFF111827),
                  size: 40,
                ),
                onPressed: () => ref.read(musicProvider.notifier).next(),
              ),
              IconButton(
                icon: Icon(Icons.repeat_rounded, color: Colors.grey[600]),
                onPressed: () {},
              ),
            ],
          ),

          const SizedBox(height: 48),

          // Bottom Actions (Lyrics & Queue)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _bottomAction(
                Icons.lyrics_rounded,
                "Lyrics",
                () => ref
                    .read(playerViewModeProvider.notifier)
                    .setMode(PlayerViewMode.lyric),
              ),
              const SizedBox(width: 48),
              _bottomAction(
                Icons.queue_music_rounded,
                "Queue",
                () => ref
                    .read(playerViewModeProvider.notifier)
                    .setMode(PlayerViewMode.queue),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _bottomAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFEB5424), size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLyricView(WidgetRef ref, MusicState state) {
    return Column(
      children: [
        const Expanded(
          child: Center(
            child: Text(
              "Lyric View\n(flutter_lyric will be here)",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.close_rounded,
            color: Color(0xFF111827),
            size: 32,
          ),
          onPressed: () => ref
              .read(playerViewModeProvider.notifier)
              .setMode(PlayerViewMode.normal),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildQueueView(WidgetRef ref, MusicState state) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            "Up Next",
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: state.allSongs.length,
            itemBuilder: (context, index) {
              final song = state.allSongs[index];
              return ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCA5A5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                title: Text(
                  song.title,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  song.artist ?? "Unknown",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              );
            },
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.close_rounded,
            color: Color(0xFF111827),
            size: 32,
          ),
          onPressed: () => ref
              .read(playerViewModeProvider.notifier)
              .setMode(PlayerViewMode.normal),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildFallbackArtwork() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFCA5A5), Color(0xFFFECDD3)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(32),
      ),
      child: const Center(
        child: Icon(Icons.music_note_rounded, size: 120, color: Colors.white),
      ),
    );
  }
}

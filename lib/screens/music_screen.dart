import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/music_provider.dart';
import '../providers/ui_provider.dart';
import '../widgets/lyric_pane_view.dart';
import '../widgets/queue_pane_view.dart';

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

  Widget _buildIconWithDot({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    double size = 28,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Icon(icon, color: const Color(0xFFFF4500), size: size),
          if (isActive)
            Positioned(
              bottom: -6,
              child: Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF4500),
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final musicState = ref.watch(musicProvider);
    final song = musicState.currentSong;
    final viewMode = ref.watch(playerViewModeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Row(
            children: [
              // Left side (Album art and controls)
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 64.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Back button at top left
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 36,
                          ),
                          color: const Color(0xFFFF4500),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const Spacer(flex: 1),
                      // Album Art
                      if (song != null)
                        Flexible(
                          flex: 8,
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 30,
                                    offset: const Offset(0, 15),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Consumer(
                                  builder: (context, ref, _) {
                                    final art = ref.watch(
                                      artworkProvider(song.data),
                                    );
                                    return art.when(
                                      data: (bytes) {
                                        if (bytes != null)
                                          return Image.file(
                                            bytes,
                                            fit: BoxFit.cover,
                                          );
                                        return Container(
                                          color: Colors.grey[300],
                                          child: const Center(
                                            child: Icon(
                                              Icons.music_note,
                                              size: 100,
                                            ),
                                          ),
                                        );
                                      },
                                      loading: () =>
                                          Container(color: Colors.grey[300]),
                                      error: (_, _) =>
                                          Container(color: Colors.grey[300]),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 32),
                      // Title & Artist
                      Text(
                        song?.title ?? "No Song Playing",
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        song?.artist ?? "Unknown Artist",
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Progress Bar
                      Row(
                        children: [
                          Text(
                            formatDuration(
                              _dragPosition != null
                                  ? Duration(
                                      milliseconds: _dragPosition!.toInt(),
                                    )
                                  : musicState.position,
                            ),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SliderTheme(
                              data: SliderThemeData(
                                trackHeight: 4,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 6,
                                ),
                                overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 16,
                                ),
                                activeTrackColor: const Color(0xFFFF4500),
                                inactiveTrackColor: Colors.grey[300],
                                thumbColor: const Color(0xFFFF4500),
                                overlayColor: const Color(0xFFFF4500)
                                    .withValues(alpha: 0.2),
                              ),
                              child: Slider(
                                value:
                                    _dragPosition ??
                                    musicState.position.inMilliseconds
                                        .toDouble(),
                                min: 0,
                                max:
                                    musicState.duration.inMilliseconds
                                            .toDouble() >
                                        0
                                    ? musicState.duration.inMilliseconds
                                          .toDouble()
                                    : 1.0,
                                onChanged: (val) =>
                                    setState(() => _dragPosition = val),
                                onChangeEnd: (val) {
                                  ref
                                      .read(musicProvider.notifier)
                                      .seek(
                                        Duration(milliseconds: val.toInt()),
                                      );
                                  setState(() => _dragPosition = null);
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            formatDuration(musicState.duration),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(width: 28),
                          Row(
                            children: [
                              _buildIconWithDot(
                                icon: Icons.shuffle_rounded,
                                isActive: musicState.isShuffle,
                                onTap: () => ref.read(musicProvider.notifier).toggleShuffle(),
                              ),
                              const SizedBox(width: 20),
                              GestureDetector(
                                onTap: () => ref.read(musicProvider.notifier).previous(),
                                child: const Icon(
                                  Icons.skip_previous_rounded,
                                  color: Color(0xFFFF4500),
                                  size: 36,
                                ),
                              ),
                              const SizedBox(width: 20),
                              GestureDetector(
                                onTap: () => ref.read(musicProvider.notifier).togglePlay(),
                                child: Icon(
                                  musicState.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                  color: const Color(0xFFFF4500),
                                  size: 48,
                                ),
                              ),
                              const SizedBox(width: 20),
                              GestureDetector(
                                onTap: () => ref.read(musicProvider.notifier).next(),
                                child: const Icon(
                                  Icons.skip_next_rounded,
                                  color: Color(0xFFFF4500),
                                  size: 36,
                                ),
                              ),
                              const SizedBox(width: 20),
                              _buildIconWithDot(
                                icon: musicState.loopMode == LoopMode.one
                                    ? Icons.repeat_one_rounded
                                    : Icons.repeat_rounded,
                                isActive: musicState.loopMode != LoopMode.off,
                                onTap: () => ref.read(musicProvider.notifier).toggleLoop(),
                              ),
                            ],
                          ),
                          _buildIconWithDot(
                            icon: Icons.queue_music_rounded,
                            isActive: viewMode == PlayerViewMode.queue,
                            onTap: () {
                              final notif = ref.read(playerViewModeProvider.notifier);
                              notif.setMode(viewMode == PlayerViewMode.queue
                                  ? PlayerViewMode.lyric
                                  : PlayerViewMode.queue);
                            },
                          ),
                        ],
                      ),
                      const Spacer(flex: 1),
                    ],
                  ),
                ),
              ),

              // Right side (Lyrics or Queue)
              Expanded(
                flex: 1,
                child: viewMode == PlayerViewMode.queue
                    ? const QueuePaneView()
                    : song != null
                        ? LyricPaneView(song: song)
                        : const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

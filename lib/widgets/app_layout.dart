import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:on_audio_query/on_audio_query.dart";

import "../screens/home_screen.dart";
import "../screens/music_screen.dart";
import "../screens/favorite_songs_screen.dart";
import "../screens/search_screen.dart";
import "../screens/library_screen.dart";
import "../screens/playlists_screen.dart";
import "../screens/settings_screen.dart";
import "../providers/music_provider.dart";
import "../providers/ui_provider.dart";

class AppLayout extends ConsumerStatefulWidget {
  const AppLayout({super.key});

  @override
  ConsumerState<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends ConsumerState<AppLayout> {
  int _selectedIndex = 0;
  bool _isShuffleActive = false;
  int _repeatMode = 0;
  double? _dragPosition;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const LibraryScreen(),
    const FavoriteSongsScreen(),
    const PlaylistsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = MediaQuery.of(context).size.width > 800;
    final musicState = ref.watch(musicProvider);
    final viewMode = ref.watch(playerViewModeProvider);

    final displaySong = musicState.currentSong;

    return Scaffold(
      body: Stack(
        children: [
          // Main Content Area
          Positioned.fill(
            child: Row(
              children: [
                if (isDesktop)
                  const SizedBox(width: 120), // 80 width + 24 left + 16 right

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: 150.0,
                    ), // Always reserve space for player
                    child: _screens[_selectedIndex],
                  ),
                ),

                if (isDesktop)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    width: viewMode == PlayerViewMode.normal
                        ? (64 + 24)
                        : (320 + 24),
                  ),
              ],
            ),
          ),

          // Floating Left Sidebar
          if (isDesktop)
            Positioned(
              left: 24,
              top: 24,
              bottom: 120 + 32, // Always leave space for player dock
              child: _buildFloatingSidebar(),
            ),

          // Right Pane (Closed or Open)
          if (isDesktop)
            Positioned(
              right: 24,
              top: 24,
              bottom: 120 + 32, // Always leave space for player dock
              child: viewMode == PlayerViewMode.normal
                  ? _buildRightPaneClosed()
                  : _buildRightPane(viewMode, displaySong),
            ),

          // Floating Player Dock (Always visible)
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: _buildMiniPlayer(
              musicState,
              displaySong,
              viewMode,
              isDesktop,
            ),
          ),
        ],
      ),
      bottomNavigationBar: isDesktop
          ? null
          : BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (i) => setState(() => _selectedIndex = i),
              backgroundColor: Colors.white,
              selectedItemColor: const Color(0xFFFF4500),
              // unselectedItemColor: Colors.black,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search_rounded),
                  label: "Search",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.library_music_rounded),
                  label: "Library",
                ),
              ],
            ),
    );
  }

  Widget _buildFloatingSidebar() {
    return Container(
      width: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFDC5028).withValues(alpha: 0.08),
            blurRadius: 35,
            offset: const Offset(0, 12),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 28),
          const Icon(Icons.menu_rounded, color: Color(0xFFFF4500), size: 32),
          const SizedBox(height: 32),
          _sidebarItem(Icons.search_rounded, 1),
          const SizedBox(height: 16),
          _sidebarItem(Icons.home_rounded, 0, isHome: true),
          const SizedBox(height: 16),
          _sidebarItem(Icons.music_note_rounded, 2),
          const SizedBox(height: 16),
          _sidebarItem(Icons.favorite_rounded, 3),
          const SizedBox(height: 16),
          _sidebarItem(Icons.queue_music_rounded, 4),
          const Spacer(),
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: _selectedIndex == 5
                  ? const Color(0xFFFF4500)
                  : Colors.grey.shade500,
              size: 28,
            ),
            onPressed: () {
              setState(() {
                _selectedIndex = 5;
              });
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sidebarItem(IconData icon, int index, {bool isHome = false}) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
          border: isSelected
              ? Border.all(
                  color: const Color(0xFFFF4500).withValues(alpha: 0.3),
                )
              : null,
        ),
        child: Icon(icon, color: Color(0xFFFF4500)),
      ),
    );
  }

  Widget _buildRightPaneClosed() {
    return Container(
      width: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFDC5028).withValues(alpha: 0.08),
            blurRadius: 35,
            offset: const Offset(0, 12),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          IconButton(
            icon: const Icon(
              Icons.view_sidebar_outlined,
              color: Color(0xFFFF4500),
              size: 28,
            ),
            onPressed: () {
              ref
                  .read(playerViewModeProvider.notifier)
                  .setMode(PlayerViewMode.lyric);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRightPane(PlayerViewMode mode, SongModel? song) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      width: 320,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFDC5028).withValues(alpha: 0.08),
            blurRadius: 35,
            offset: const Offset(0, 12),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.view_sidebar_outlined,
                    color: Color(0xFFFF4500),
                  ),
                  onPressed: () => ref
                      .read(playerViewModeProvider.notifier)
                      .setMode(PlayerViewMode.normal),
                ),
                // Text(
                //   mode == PlayerViewMode.lyric ? "Lyrics" : "Up Next",
                //   style: const TextStyle(
                //     color: Color(0xFFFF4500),
                //     fontSize: 20,
                //     fontWeight: FontWeight.w800,
                //   ),
                // ),
              ],
            ),
          ),
          Expanded(
            child: song == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.music_off_rounded,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No Music Playing",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                : mode == PlayerViewMode.lyric
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Ã°Å¸Å½Âµ\nBaby, I'm just trying to play it cool\nBut I just can't hide that\nI want you\n\nWait a minute...",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.6),
                          fontSize: 16,
                          height: 2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3C2C2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        title: Text(
                          "Queue Song ${index + 1}",
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          "Artist",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconWithDot({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    double size = 24,
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

  Widget _buildMiniPlayer(
    MusicState state,
    SongModel? displaySong,
    PlayerViewMode viewMode,
    bool isDesktop,
  ) {
    return GestureDetector(
      onTap: () {
        if (!isDesktop && displaySong != null) {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const MusicScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
            ),
          );
        }
      },
      child: Container(
        height: 120,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFDC5028).withValues(alpha: 0.08),
              blurRadius: 35,
              offset: const Offset(0, 12),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Consumer(
              builder: (context, ref, _) {
                final musicState = ref.watch(musicProvider);
                String formatDuration(Duration d) {
                  final mins = d.inMinutes;
                  final secs = (d.inSeconds % 60).toString().padLeft(2, '0');
                  return "${mins}:${secs}";
                }
                final pos = musicState.position;
                final dur = musicState.duration;
                
                return Row(
                  children: [
                    Text(
                      formatDuration(_dragPosition != null ? Duration(milliseconds: _dragPosition!.toInt()) : pos),
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                          activeTrackColor: const Color(0xFFFF4500),
                          inactiveTrackColor: Colors.grey[300],
                          thumbColor: const Color(0xFFFF4500),
                        ),
                        child: Slider(
                          value: (_dragPosition ?? pos.inMilliseconds.toDouble()).clamp(0.0, dur.inMilliseconds.toDouble() > 0 ? dur.inMilliseconds.toDouble() : 1.0),
                          max: dur.inMilliseconds.toDouble() > 0 ? dur.inMilliseconds.toDouble() : 1.0,
                          onChangeStart: (val) {
                            setState(() { _dragPosition = val; });
                          },
                          onChanged: (val) {
                            setState(() { _dragPosition = val; });
                          },
                          onChangeEnd: (val) async {
                            final target = val;
                            setState(() { _dragPosition = val; });
                            await ref.read(musicProvider.notifier).seek(Duration(milliseconds: val.toInt()));
                            if (mounted && _dragPosition == target) {
                              setState(() { _dragPosition = null; });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      formatDuration(dur),
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              }
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (displaySong != null)
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3C2C2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Consumer(
                      builder: (context, ref, child) {
                        final artworkAsync = ref.watch(
                          artworkProvider(displaySong.data),
                        );
                        return artworkAsync.when(
                          data: (bytes) {
                            if (bytes != null) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: RepaintBoundary(
                                  child: Image.file(
                                    bytes,
                                    fit: BoxFit.cover,
                                    cacheWidth: 200,
                                  ),
                                ),
                              );
                            }
                            return const Icon(
                              Icons.music_note,
                              color: Colors.white,
                            );
                          },
                          loading: () => const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          error: (_, _) =>
                              const Icon(Icons.music_note, color: Colors.white),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.music_note, color: Colors.grey),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        displaySong?.title ?? "No Song Playing",
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        displaySong?.artist ?? "Unknown",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildIconWithDot(
                        icon: Icons.shuffle_rounded,
                        isActive: _isShuffleActive,
                        size: 28,
                        onTap: () {
                          setState(() {
                            _isShuffleActive = !_isShuffleActive;
                          });
                        },
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => displaySong != null
                            ? ref.read(musicProvider.notifier).previous()
                            : null,
                        child: const Icon(
                          Icons.skip_previous_rounded,
                          color: Color(0xFFFF4500),
                          size: 36,
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => displaySong != null
                            ? ref.read(musicProvider.notifier).togglePlay()
                            : null,
                        child: Icon(
                          state.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: const Color(0xFFFF4500),
                          size: 42,
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => displaySong != null
                            ? ref.read(musicProvider.notifier).next()
                            : null,
                        child: const Icon(
                          Icons.skip_next_rounded,
                          color: Color(0xFFFF4500),
                          size: 36,
                        ),
                      ),
                      const SizedBox(width: 16),
                      _buildIconWithDot(
                        icon: _repeatMode == 2
                            ? Icons.repeat_one_rounded
                            : Icons.repeat_rounded,
                        isActive: _repeatMode > 0,
                        size: 28,
                        onTap: () {
                          setState(() {
                            _repeatMode = (_repeatMode + 1) % 3;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildIconWithDot(
                        icon: Icons.mic_external_on_rounded,
                        isActive: viewMode == PlayerViewMode.lyric,
                        size: 24,
                        onTap: () {
                          final notifier = ref.read(
                            playerViewModeProvider.notifier,
                          );
                          notifier.setMode(
                            viewMode == PlayerViewMode.lyric
                                ? PlayerViewMode.normal
                                : PlayerViewMode.lyric,
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.volume_up_rounded,
                        color: Color(0xFFFF4500),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 60,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: 0.6,
                          child: Container(color: const Color(0xFFFF4500)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      _buildIconWithDot(
                        icon: Icons.queue_music_rounded,
                        isActive: viewMode == PlayerViewMode.queue,
                        size: 26,
                        onTap: () {
                          final notifier = ref.read(
                            playerViewModeProvider.notifier,
                          );
                          notifier.setMode(
                            viewMode == PlayerViewMode.queue
                                ? PlayerViewMode.normal
                                : PlayerViewMode.queue,
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.more_horiz_rounded,
                        color: Color(0xFFFF4500),
                        size: 26,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

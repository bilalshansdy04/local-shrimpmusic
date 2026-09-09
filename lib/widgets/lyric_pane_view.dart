import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../providers/lyric_provider.dart';
import '../providers/music_provider.dart';
import 'search_lyric_dialog.dart';

class LyricPaneView extends ConsumerStatefulWidget {
  final SongModel song;
  const LyricPaneView({super.key, required this.song});

  @override
  ConsumerState<LyricPaneView> createState() => _LyricPaneViewState();
}

class _LyricPaneViewState extends ConsumerState<LyricPaneView> {
  bool _isAutoSync = true;
  List<GlobalKey> _keys = [];
  int _lastIndex = -1;

  void _scrollToIndex(int index) {
    if (!_isAutoSync) return;
    if (index >= 0 && index < _keys.length) {
      final key = _keys[index];
      if (key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          alignment: 0.5,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lyricState = ref.watch(lyricProvider);
    final isSynced = lyricState.isSynced;
    
    final currentIndex = ref.watch(musicProvider.select((m) {
      if (!isSynced || lyricState.lyrics == null || lyricState.lyrics!.isEmpty) return -1;
      int idx = lyricState.lyrics!.indexWhere((l) => l.time > m.position) - 1;
      if (idx < -1) idx = lyricState.lyrics!.length - 1;
      if (idx < 0) idx = 0;
      return idx;
    }));

    if (lyricState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (lyricState.lyrics == null || lyricState.lyrics!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lyrics_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              lyricState.error != null ? "Error: ${lyricState.error}" : "Lyrics not found locally",
              style: const TextStyle(color: Colors.grey, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => SearchLyricDialog(song: widget.song),
                );
              },
              icon: const Icon(Icons.search),
              label: const Text("Search Online (LRCLIB)"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    final lyrics = lyricState.lyrics!;
    
    if (_keys.length != lyrics.length) {
      _keys = List.generate(lyrics.length, (_) => GlobalKey());
    }

    if (isSynced && currentIndex != _lastIndex && currentIndex != -1) {
      _lastIndex = currentIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToIndex(currentIndex);
      });
    }

    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: MediaQuery.of(context).size.height / 2.2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(lyrics.length, (index) {
              final isCurrent = isSynced ? index == currentIndex : true;
              return Container(
                key: _keys[index],
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                width: double.infinity,
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    color: isSynced ? (isCurrent ? Colors.black : Colors.grey[400]) : Colors.black87,
                    fontSize: isSynced ? (isCurrent ? 36 : 20) : 24,
                    fontWeight: isSynced && isCurrent ? FontWeight.w900 : FontWeight.w700,
                    height: 1.4,
                  ),
                  child: Text(lyrics[index].text),
                ),
              );
            }),
          ),
        ),
        if (isSynced)
          Positioned(
            top: 16,
            right: 24,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
              ),
              child: IconButton(
                icon: Icon(
                  _isAutoSync ? Icons.sync : Icons.sync_disabled,
                  color: _isAutoSync ? Colors.black : Colors.grey,
                ),
                tooltip: _isAutoSync ? "Auto-sync enabled" : "Auto-sync disabled",
                onPressed: () {
                  setState(() {
                    _isAutoSync = !_isAutoSync;
                    if (_isAutoSync && currentIndex != -1) {
                      _scrollToIndex(currentIndex);
                    }
                  });
                },
              ),
            ),
          ),
      ],
    );
  }
}

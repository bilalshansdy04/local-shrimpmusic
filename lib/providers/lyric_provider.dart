import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/lyric_model.dart';
import 'music_provider.dart';

class LyricState {
  final List<LyricLine>? lyrics;
  final bool isLoading;
  final bool isSearching;
  final String? error;
  
  LyricState({
    this.lyrics,
    this.isLoading = false,
    this.isSearching = false,
    this.error,
  });
  
  LyricState copyWith({
    List<LyricLine>? lyrics,
    bool? isLoading,
    bool? isSearching,
    String? error,
  }) {
    return LyricState(
      lyrics: lyrics ?? this.lyrics,
      isLoading: isLoading ?? this.isLoading,
      isSearching: isSearching ?? this.isSearching,
      error: error ?? this.error,
    );
  }
}

class LyricNotifier extends Notifier<LyricState> {
  @override
  LyricState build() {
    _init();
    return LyricState();
  }
  String? _currentSongPath;

  void _init() {
    ref.listen(musicProvider, (previous, next) {
      if (next.currentSong != null && next.currentSong!.data != _currentSongPath) {
        _currentSongPath = next.currentSong!.data;
        _loadLocalLyrics(_currentSongPath!);
      }
    });
  }

  Future<void> _loadLocalLyrics(String audioPath) async {
    state = LyricState(isLoading: true);
    try {
      final file = File(audioPath);
      final dir = file.parent.path;
      final basename = audioPath.split(Platform.pathSeparator).last;
      final lastDot = basename.lastIndexOf('.');
      final name = lastDot != -1 ? basename.substring(0, lastDot) : basename;
      
      final lrcFile = File('$dir${Platform.pathSeparator}$name.lrc');
      print("Looking for LRC file at: ${lrcFile.path}");
      
      if (await lrcFile.exists()) {
        final content = await lrcFile.readAsString();
        final parsed = _parseLrc(content);
        if (parsed.isNotEmpty) {
          state = LyricState(lyrics: parsed);
          return;
        }
      }
      
      state = LyricState(lyrics: null); // Not found locally
    } catch (e) {
      state = LyricState(error: e.toString());
    }
  }

  List<LyricLine> _parseLrc(String lrc) {
    final List<LyricLine> lines = [];
    final regex = RegExp(r'\[(\d+):(\d+(?:\.\d+)?)\](.*)');
    
    for (final line in lrc.split('\n')) {
      final match = regex.firstMatch(line);
      if (match != null) {
        final minutes = int.parse(match.group(1)!);
        final seconds = double.parse(match.group(2)!);
        final text = match.group(3)!.trim();
        
        final duration = Duration(
          milliseconds: (minutes * 60000 + seconds * 1000).toInt(),
        );
        
        lines.add(LyricLine(time: duration, text: text));
      }
    }
    
    return lines;
  }

  Future<List<Map<String, dynamic>>> searchOnline(String trackName, String artistName) async {
    state = state.copyWith(isSearching: true);
    try {
      final uri = Uri.parse('https://lrclib.net/api/search').replace(queryParameters: {
        'track_name': trackName,
        'artist_name': artistName,
      });
      
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print('Error searching lyrics: $e');
    } finally {
      state = state.copyWith(isSearching: false);
    }
    return [];
  }

  Future<void> saveAndUseLyric(String syncedLyrics, String audioPath) async {
    try {
      final file = File(audioPath);
      final dir = file.parent.path;
      final basename = audioPath.split(Platform.pathSeparator).last;
      final lastDot = basename.lastIndexOf('.');
      final name = lastDot != -1 ? basename.substring(0, lastDot) : basename;
      
      final lrcFile = File('$dir${Platform.pathSeparator}$name.lrc');
      print("Looking for LRC file at: ${lrcFile.path}");
      await lrcFile.writeAsString(syncedLyrics);
      
      final parsed = _parseLrc(syncedLyrics);
      state = LyricState(lyrics: parsed);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final lyricProvider = NotifierProvider<LyricNotifier, LyricState>(() {
  return LyricNotifier();
});

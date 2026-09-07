import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:on_audio_query/on_audio_query.dart";
import "package:media_kit/media_kit.dart";

class MusicState {
  final List<SongModel> allSongs;
  final SongModel? currentSong;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final bool hasPermission;

  MusicState({
    this.allSongs = const [],
    this.currentSong,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.hasPermission = false,
  });

  MusicState copyWith({
    List<SongModel>? allSongs,
    SongModel? currentSong,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    bool? hasPermission,
  }) {
    return MusicState(
      allSongs: allSongs ?? this.allSongs,
      currentSong: currentSong ?? this.currentSong,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      hasPermission: hasPermission ?? this.hasPermission,
    );
  }
}

class MusicNotifier extends Notifier<MusicState> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  late final Player _player;

  @override
  MusicState build() {
    _player = Player();
    
    // Listen to player state
    _player.stream.playing.listen((playing) {
      state = state.copyWith(isPlaying: playing);
    });
    
    _player.stream.position.listen((position) {
      state = state.copyWith(position: position);
    });
    
    _player.stream.duration.listen((duration) {
      state = state.copyWith(duration: duration);
    });

    _init();
    return MusicState();
  }

  Future<void> _init() async {
    bool hasPermission = await _audioQuery.permissionsStatus();
    if (!hasPermission) {
      hasPermission = await _audioQuery.permissionsRequest();
    }
    
    if (hasPermission) {
      final songs = await _audioQuery.querySongs(
        sortType: null,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );
      state = state.copyWith(allSongs: songs, hasPermission: true);
    } else {
      state = state.copyWith(hasPermission: false);
    }
  }

  Future<void> playSong(SongModel song) async {
    state = state.copyWith(currentSong: song);
    await _player.open(Media(song.data));
    await _player.play();
  }

  Future<void> togglePlay() async {
    if (state.isPlaying) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> next() async {
    if (state.allSongs.isEmpty || state.currentSong == null) return;
    int index = state.allSongs.indexWhere((s) => s.id == state.currentSong!.id);
    if (index != -1 && index < state.allSongs.length - 1) {
      playSong(state.allSongs[index + 1]);
    }
  }

  Future<void> previous() async {
    if (state.allSongs.isEmpty || state.currentSong == null) return;
    int index = state.allSongs.indexWhere((s) => s.id == state.currentSong!.id);
    if (index > 0) {
      playSong(state.allSongs[index - 1]);
    }
  }
}

final musicProvider = NotifierProvider<MusicNotifier, MusicState>(() {
  return MusicNotifier();
});


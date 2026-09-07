import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:on_audio_query/on_audio_query.dart";
import "package:media_kit/media_kit.dart";
import "dart:io";
import "package:audio_metadata_reader/audio_metadata_reader.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:file_picker/file_picker.dart";

class MusicState {
  final List<SongModel> allSongs;
  final SongModel? currentSong;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final bool hasPermission;
  final bool isLoading;
  final String? musicFolderPath;

  MusicState({
    this.allSongs = const [],
    this.currentSong,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.hasPermission = false,
    this.isLoading = true,
    this.musicFolderPath,
  });

  MusicState copyWith({
    List<SongModel>? allSongs,
    SongModel? currentSong,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    bool? hasPermission,
    bool? isLoading,
    String? musicFolderPath,
  }) {
    return MusicState(
      allSongs: allSongs ?? this.allSongs,
      currentSong: currentSong ?? this.currentSong,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      hasPermission: hasPermission ?? this.hasPermission,
      isLoading: isLoading ?? this.isLoading,
      musicFolderPath: musicFolderPath ?? this.musicFolderPath,
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
    final prefs = await SharedPreferences.getInstance();
    final customPath = prefs.getString('custom_music_path');
    state = state.copyWith(musicFolderPath: customPath);

    bool hasPermission = true;
    if (!Platform.isWindows && !Platform.isMacOS && !Platform.isLinux) {
      hasPermission = await _audioQuery.permissionsStatus();
      if (!hasPermission) {
        hasPermission = await _audioQuery.permissionsRequest();
      }
    }
    
    if (hasPermission) {
      List<SongModel> songs = [];
      
      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        // Fallback for Desktop platforms since on_audio_query doesnt support them natively
        final targetPath = customPath ?? (Platform.environment['USERPROFILE'] != null ? "${Platform.environment['USERPROFILE']}\\Music" : "");
        if (targetPath.isNotEmpty) {
          final dir = Directory(targetPath);
          if (await dir.exists()) {
            final List<FileSystemEntity> entities = [];
            try {
              await for (var entity in dir.list(recursive: true)) {
                entities.add(entity);
              }
            } catch (e) {
              print("Error scanning directory: $e");
            }
            for (var entity in entities) {
              if (entity is File) {
                final ext = entity.path.toLowerCase();
                if (ext.endsWith('.mp3') || ext.endsWith('.flac') || ext.endsWith('.wav') || ext.endsWith('.m4a')) {
                  final filename = entity.uri.pathSegments.last;
                  String title = filename.contains('.') ? filename.substring(0, filename.lastIndexOf('.')) : filename;
                  String artist = 'Unknown Artist';
                  String album = 'Unknown Album';
                  int durationMs = 0;
                  
                  try {
                    final metadata = readMetadata(entity, getImage: false);
                    if (metadata.title != null && metadata.title!.isNotEmpty) title = metadata.title!;
                    if (metadata.artist != null && metadata.artist!.isNotEmpty) artist = metadata.artist!;
                    if (metadata.album != null && metadata.album!.isNotEmpty) album = metadata.album!;
                    if (metadata.duration != null) durationMs = metadata.duration!.inMilliseconds;
                  } catch (e) {
                    // ignore
                  }
                  
                  // Construct a basic SongModel
                  songs.add(SongModel({
                    '_id': entity.path.hashCode,
                    '_data': entity.path,
                    '_uri': entity.uri.toString(),
                    '_display_name': filename,
                    '_display_name_wo_ext': title,
                    '_size': entity.lengthSync(),
                    'album': album,
                    'album_id': 0,
                    'artist': artist,
                    'artist_id': 0,
                    'title': title,
                    'duration': durationMs,
                  }));
                }
              }
            }
          }
        }
      } else {
        songs = await _audioQuery.querySongs(
          sortType: null,
          orderType: OrderType.ASC_OR_SMALLER,
          uriType: UriType.EXTERNAL,
          ignoreCase: true,
          path: customPath,
        );
      }
      
      print("Total songs loaded: ${songs.length}");
      state = state.copyWith(allSongs: songs, hasPermission: true, isLoading: false);
    } else {
      state = state.copyWith(hasPermission: false, isLoading: false);
    }
  }

  Future<void> pickMusicFolder() async {
    final result = await FilePicker.getDirectoryPath(
      dialogTitle: 'Select Music Folder',
    );
    
    if (result != null) {
      state = state.copyWith(isLoading: true);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('custom_music_path', result);
      
      // Stop current playback to avoid errors if the folder changes
      await _player.stop();
      
      // Re-initialize to rescan the new folder
      await _init();
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





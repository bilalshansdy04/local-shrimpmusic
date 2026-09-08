import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:on_audio_query/on_audio_query.dart";
import "package:media_kit/media_kit.dart";

import "dart:convert";
import "dart:io";
import "dart:isolate";

import "package:path_provider/path_provider.dart";
import "package:audio_metadata_reader/audio_metadata_reader.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:file_picker/file_picker.dart";

final artworkProvider = FutureProvider.family<File?, String>((
  ref,
  filePath,
) async {
  try {
    final tempDir = await getTemporaryDirectory();
    final cacheFile = File('${tempDir.path}/art_${filePath.hashCode}.jpg');

    if (cacheFile.existsSync()) {
      return cacheFile;
    }

    final bytes = await Isolate.run(() {
      try {
        final metadata = readMetadata(File(filePath), getImage: true);
        if (metadata.pictures.isNotEmpty) {
          return metadata.pictures.first.bytes;
        }
      } catch (e) {}
      return null;
    });

    if (bytes != null) {
      await cacheFile.writeAsBytes(bytes);
      return cacheFile;
    }
  } catch (e) {}
  return null;
});

final audioBitrateProvider = FutureProvider.family<int?, String>((
  ref,
  filePath,
) async {
  return await Isolate.run(() {
    try {
      final metadata = readMetadata(File(filePath), getImage: false);
      return metadata.bitrate;
    } catch (e) {}
    return null;
  });
});

enum LoopMode { off, all, one }

class MusicState {
  final List<SongModel> allSongs;
  final List<SongModel> queue;
  final int queueIndex;
  final bool isShuffle;
  final LoopMode loopMode;
  final double volume;
  final SongModel? currentSong;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final bool hasPermission;
  final bool isLoading;
  final String? musicFolderPath;
  final int? currentBitrate;
  final List<SongModel> recentlyPlayed;

  MusicState({
    this.allSongs = const [],
    this.queue = const [],
    this.queueIndex = -1,
    this.isShuffle = false,
    this.loopMode = LoopMode.off,
    this.volume = 100.0,
    this.currentSong,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.hasPermission = false,
    this.isLoading = true,
    this.musicFolderPath,
    this.currentBitrate,
    this.recentlyPlayed = const [],
  });

  MusicState copyWith({
    List<SongModel>? allSongs,
    List<SongModel>? queue,
    int? queueIndex,
    bool? isShuffle,
    LoopMode? loopMode,
    double? volume,
    SongModel? currentSong,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    bool? hasPermission,
    bool? isLoading,
    String? musicFolderPath,
    int? currentBitrate,
    List<SongModel>? recentlyPlayed,
  }) {
    return MusicState(
      allSongs: allSongs ?? this.allSongs,
      queue: queue ?? this.queue,
      queueIndex: queueIndex ?? this.queueIndex,
      isShuffle: isShuffle ?? this.isShuffle,
      loopMode: loopMode ?? this.loopMode,
      volume: volume ?? this.volume,
      currentSong: currentSong ?? this.currentSong,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      hasPermission: hasPermission ?? this.hasPermission,
      isLoading: isLoading ?? this.isLoading,
      musicFolderPath: musicFolderPath ?? this.musicFolderPath,
      currentBitrate: currentBitrate ?? this.currentBitrate,
      recentlyPlayed: recentlyPlayed ?? this.recentlyPlayed,
    );
  }
}

class MusicNotifier extends Notifier<MusicState> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  late final Player _player;

  @override
  MusicState build() {
    _player = Player();

    _player.stream.playing.listen((playing) {
      state = state.copyWith(isPlaying: playing);
    });

    _player.stream.position.listen((position) {
      state = state.copyWith(position: position);
    });

    _player.stream.duration.listen((duration) {
      state = state.copyWith(duration: duration);
    });

    _player.stream.volume.listen((volume) {
      state = state.copyWith(volume: volume);
    });

    _player.stream.tracks.listen((tracks) {
      final audioTracks = tracks.audio;
      if (audioTracks.isNotEmpty) {
        final track = audioTracks.first;
        if (track.bitrate != null) {
           state = state.copyWith(currentBitrate: track.bitrate);
        }
      }
    });

    _player.stream.completed.listen((completed) {
      if (completed) {
        if (state.loopMode == LoopMode.one) {
          _player.seek(Duration.zero);
          _player.play();
        } else {
          next();
        }
      }
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
        final targetPath =
            customPath ??
            (Platform.environment['USERPROFILE'] != null
                ? "${Platform.environment['USERPROFILE']}\Music"
                : "");
        if (targetPath.isNotEmpty) {
          final dir = Directory(targetPath);
          if (await dir.exists()) {
            final filePaths = <String>[];
            try {
              await for (var entity in dir.list(recursive: true)) {
                if (entity is File) {
                  final ext = entity.path.toLowerCase();
                  if (ext.endsWith('.mp3') ||
                      ext.endsWith('.flac') ||
                      ext.endsWith('.wav') ||
                      ext.endsWith('.m4a') ||
                      ext.endsWith('.ogg')) {
                    filePaths.add(entity.path);
                  }
                }
              }
            } catch (e) {}

            final songMaps = await Isolate.run(() {
              final results = <Map<String, dynamic>>[];
              for (var path in filePaths) {
                final file = File(path);
                final filename = file.uri.pathSegments.last;
                String title = filename.contains('.')
                    ? filename.substring(0, filename.lastIndexOf('.'))
                    : filename;
                String artist = 'Unknown Artist';
                String album = 'Unknown Album';
                int durationMs = 0;

                try {
                  final metadata = readMetadata(file, getImage: false);
                  if (metadata.title != null && metadata.title!.isNotEmpty)
                    title = metadata.title!;
                  if (metadata.artist != null && metadata.artist!.isNotEmpty)
                    artist = metadata.artist!;
                  if (metadata.album != null && metadata.album!.isNotEmpty)
                    album = metadata.album!;
                  if (metadata.duration != null)
                    durationMs = metadata.duration!.inMilliseconds;
                  print('Read bitrate for $title: ${metadata.bitrate}');
                } catch (e) {}

                results.add({
                  '_id': path.hashCode,
                  '_data': path,
                  '_uri': file.uri.toString(),
                  '_display_name': filename,
                  '_display_name_wo_ext': title,
                  '_size': file.lengthSync(),
                  'album': album,
                  'album_id': 0,
                  'artist': artist,
                  'artist_id': 0,
                  'title': title,
                  'duration': durationMs,
                  'date_added': file.lastModifiedSync().millisecondsSinceEpoch ~/ 1000,
                });
              }
              return results;
            });

            for (var map in songMaps) {
              songs.add(SongModel(map));
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

      state = state.copyWith(
        allSongs: songs,
        hasPermission: true,
        isLoading: false,
      );
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

      await _player.stop();
      await _init();
    }
  }

  Future<void> playSong(SongModel song, {List<SongModel>? contextList}) async {
    // Update recently played
    List<SongModel> newRecentlyPlayed = List.from(state.recentlyPlayed);
    newRecentlyPlayed.removeWhere((s) => s.id == song.id);
    newRecentlyPlayed.insert(0, song);
    if (newRecentlyPlayed.length > 15) {
      newRecentlyPlayed = newRecentlyPlayed.sublist(0, 15);
    }
    
    // Save to SharedPreferences
    SharedPreferences.getInstance().then((prefs) {
      final ids = newRecentlyPlayed.map((s) => s.id.toString()).toList();
      prefs.setString('recently_played_ids', jsonEncode(ids));
    });

    state = state.copyWith(recentlyPlayed: newRecentlyPlayed);

    List<SongModel> newQueue = state.queue;
    int newIndex = state.queueIndex;

    if (contextList != null) {
      if (state.isShuffle) {
        newQueue = List.from(contextList)..shuffle();
        newQueue.removeWhere((s) => s.id == song.id);
        newQueue.insert(0, song);
        newIndex = 0;
      } else {
        newQueue = contextList;
        newIndex = newQueue.indexWhere((s) => s.id == song.id);
      }
    } else if (newQueue.isEmpty) {
      newQueue = state.allSongs;
      newIndex = newQueue.indexWhere((s) => s.id == song.id);
    } else {
      newIndex = newQueue.indexWhere((s) => s.id == song.id);
      if (newIndex == -1) {
        newQueue = [song, ...newQueue];
        newIndex = 0;
      }
    }

    state = state.copyWith(
      currentSong: song,
      queue: newQueue,
      queueIndex: newIndex,
    );
    await _player.open(Media(song.data));
    await _player.play();
  }

  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume);
  }

  Future<void> togglePlay() async {
    if (state.isPlaying) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> seek(Duration position) async {
    // Crossfade effect: Fade out
    final originalVolume = _player.state.volume;
    final step = originalVolume / 5;

    for (int i = 0; i < 5; i++) {
      await _player.setVolume(originalVolume - (step * i));
      await Future.delayed(const Duration(milliseconds: 30));
    }
    await _player.setVolume(0);

    // Perform seek
    await _player.seek(position);

    // Crossfade effect: Fade in
    for (int i = 0; i <= 5; i++) {
      await _player.setVolume(step * i);
      await Future.delayed(const Duration(milliseconds: 30));
    }
    await _player.setVolume(originalVolume);
  }

  Future<void> next() async {
    if (state.queue.isEmpty) return;
    int nextIndex = state.queueIndex + 1;
    if (nextIndex >= state.queue.length) {
      if (state.loopMode == LoopMode.all) {
        nextIndex = 0;
      } else {
        await _player.stop();
        return;
      }
    }
    await skipToQueueItem(nextIndex);
  }

  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= state.queue.length) return;
    
    final song = state.queue[index];
    
    // Update recently played
    List<SongModel> newRecentlyPlayed = List.from(state.recentlyPlayed);
    newRecentlyPlayed.removeWhere((s) => s.id == song.id);
    newRecentlyPlayed.insert(0, song);
    if (newRecentlyPlayed.length > 15) {
      newRecentlyPlayed = newRecentlyPlayed.sublist(0, 15);
    }
    SharedPreferences.getInstance().then((prefs) {
      final ids = newRecentlyPlayed.map((s) => s.id.toString()).toList();
      prefs.setString('recently_played_ids', jsonEncode(ids));
    });

    state = state.copyWith(
      queueIndex: index, 
      currentSong: song,
      recentlyPlayed: newRecentlyPlayed,
    );
    
    await _player.open(Media(song.data));
    if (state.isPlaying) {
      await _player.play();
    }
  }
  
  void removeFromQueue(int index) {
    if (index < 0 || index >= state.queue.length) return;
    if (index == state.queueIndex) return; // Cannot remove currently playing song via swipe
    
    final List<SongModel> newQueue = List.from(state.queue);
    newQueue.removeAt(index);
    
    int newQueueIndex = state.queueIndex;
    if (index < state.queueIndex) {
      newQueueIndex--;
    }
    
    state = state.copyWith(queue: newQueue, queueIndex: newQueueIndex);
  }

  void reorderQueue(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= state.queue.length || newIndex < 0 || newIndex > state.queue.length) return;
    
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    
    final List<SongModel> newQueue = List.from(state.queue);
    final SongModel item = newQueue.removeAt(oldIndex);
    newQueue.insert(newIndex, item);
    
    int newQueueIndex = state.queueIndex;
    if (oldIndex == state.queueIndex) {
      newQueueIndex = newIndex;
    } else if (oldIndex < state.queueIndex && newIndex >= state.queueIndex) {
      newQueueIndex--;
    } else if (oldIndex > state.queueIndex && newIndex <= state.queueIndex) {
      newQueueIndex++;
    }
    
    state = state.copyWith(queue: newQueue, queueIndex: newQueueIndex);
  }

  Future<void> previous() async {
    if (state.queue.isEmpty) return;

    if (state.position.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }

    int prevIndex = state.queueIndex - 1;
    if (prevIndex < 0) {
      if (state.loopMode == LoopMode.all) {
        prevIndex = state.queue.length - 1;
      } else {
        await seek(Duration.zero);
        return;
      }
    }
    await skipToQueueItem(prevIndex);
  }

  void toggleShuffle() {
    if (state.queue.isEmpty || state.currentSong == null) return;
    final newShuffle = !state.isShuffle;

    List<SongModel> newQueue;
    int newIndex;

    if (newShuffle) {
      newQueue = List.from(state.allSongs)..shuffle();
      newQueue.removeWhere((s) => s.id == state.currentSong!.id);
      newQueue.insert(0, state.currentSong!);
      newIndex = 0;
    } else {
      newQueue = state.allSongs;
      newIndex = newQueue.indexWhere((s) => s.id == state.currentSong!.id);
    }

    state = state.copyWith(
      isShuffle: newShuffle,
      queue: newQueue,
      queueIndex: newIndex,
    );
  }

  void toggleLoop() {
    LoopMode nextMode;
    switch (state.loopMode) {
      case LoopMode.off:
        nextMode = LoopMode.all;
        break;
      case LoopMode.all:
        nextMode = LoopMode.one;
        break;
      case LoopMode.one:
        nextMode = LoopMode.off;
        break;
    }
    state = state.copyWith(loopMode: nextMode);
  }
}

final musicProvider = NotifierProvider<MusicNotifier, MusicState>(() {
  return MusicNotifier();
});

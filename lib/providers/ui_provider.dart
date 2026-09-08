import "package:flutter_riverpod/flutter_riverpod.dart";

enum PlayerViewMode { closed, playing, lyric, queue }

class PlayerViewModeNotifier extends Notifier<PlayerViewMode> {
  @override
  PlayerViewMode build() {
    return PlayerViewMode.closed;
  }

  void setMode(PlayerViewMode mode) {
    state = mode;
  }
}

final playerViewModeProvider = NotifierProvider<PlayerViewModeNotifier, PlayerViewMode>(() {
  return PlayerViewModeNotifier();
});


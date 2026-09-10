String formatDuration(int milliseconds) {
  final mins = milliseconds ~/ 60000;
  final secs = (milliseconds % 60000) ~/ 1000;
  return "$mins:${secs.toString().padLeft(2, '0')}";
}

String formatDurationMs(Duration d) => formatDuration(d.inMilliseconds);
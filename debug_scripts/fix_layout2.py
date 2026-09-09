import os
import subprocess

result = subprocess.run(['git', 'show', 'HEAD^:lib/widgets/app_layout.dart'], capture_output=True, text=True, encoding='utf-8')
content = result.stdout

# Change Expanded child
old_expanded = """                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: 150.0,
                    ), // Always reserve space for player
                    child: _screens[_selectedIndex],
                  ),
                ),"""

new_expanded = """                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: 150.0,
                    ), // Always reserve space for player
                    child: viewMode == PlayerViewMode.lyric && displaySong != null
                        ? LyricPaneView(song: displaySong)
                        : _screens[_selectedIndex],
                  ),
                ),"""

content = content.replace(old_expanded, new_expanded)

# Change switch case in _buildRightPane
old_switch = """    switch (mode) {
      case PlayerViewMode.playing:
        return _buildPlayingPaneView(song, nextSong);
      case PlayerViewMode.lyric:
        return _buildLyricPaneView(song);
      case PlayerViewMode.queue:
        return _buildQueuePaneView(queue, queueIndex);
      case PlayerViewMode.closed:
        return const SizedBox();
    }"""

new_switch = """    switch (mode) {
      case PlayerViewMode.playing:
      case PlayerViewMode.lyric:
        return _buildPlayingPaneView(song, nextSong);
      case PlayerViewMode.queue:
        return const QueuePaneView();
      case PlayerViewMode.closed:
        return const SizedBox();
    }"""

content = content.replace(old_switch, new_switch)

# Add imports
imports = """import 'lyric_pane_view.dart';
import 'queue_pane_view.dart';
"""
content = imports + content

def remove_method(method_sig, code):
    start = code.find(method_sig)
    if start == -1: return code
    brace_count = 0
    end = -1
    for i in range(start + len(method_sig) - 1, len(code)):
        if code[i] == '{': brace_count += 1
        elif code[i] == '}':
            brace_count -= 1
            if brace_count == 0:
                end = i + 1
                break
    if end != -1:
        return code[:start] + code[end:]
    return code

content = remove_method("  Widget _buildQueuePaneView(List<SongModel> queue, int queueIndex) {", content)
content = remove_method("  Widget _buildLyricPaneView(SongModel song) {", content)
content = remove_method("  void _showSearchLyricModal(", content)

# Remove SearchLyricDialog class
dialog_sig = "class _SearchLyricDialog extends ConsumerStatefulWidget {"
start = content.find(dialog_sig)
if start != -1:
    content = content[:start]
    
# We need to make sure we close the class properly since the original file had _SearchLyricDialog AT THE END of the file, outside the AppLayout class!
# Wait! Was _SearchLyricDialog OUTSIDE AppLayout? Yes!
# So AppLayout was already closed before _SearchLyricDialog!

with open('lib/widgets/app_layout.dart', 'w', encoding='utf-8') as f:
    f.write(content)

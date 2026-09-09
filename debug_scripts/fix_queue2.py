import os
import subprocess

result = subprocess.run(['git', 'show', 'HEAD^:lib/widgets/app_layout.dart'], capture_output=True, text=True, encoding='utf-8')
content = result.stdout

start_str = "  Widget _buildQueuePaneView(List<SongModel> queue, int queueIndex) {"
start_idx = content.find(start_str)

if start_idx != -1:
    brace_count = 0
    end_idx = -1
    for i in range(start_idx + len(start_str) - 1, len(content)):
        if content[i] == '{':
            brace_count += 1
        elif content[i] == '}':
            brace_count -= 1
            if brace_count == 0:
                end_idx = i + 1
                break
                
    if end_idx != -1:
        queue_code = content[start_idx:end_idx]
        
        # Write to queue_pane_view.dart
        widget_code = """import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/music_provider.dart';

class QueuePaneView extends ConsumerWidget {
  const QueuePaneView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final musicState = ref.watch(musicProvider);
    final queue = musicState.queue;
    final queueIndex = musicState.queueIndex;
""" + queue_code.replace(start_str, "") + "\n}\n"

        with open('lib/widgets/queue_pane_view.dart', 'w', encoding='utf-8') as f:
            f.write(widget_code)
        print("Success extracting queue pane")
    else:
        print("Failed brace matching")
else:
    print("Failed to find start string")

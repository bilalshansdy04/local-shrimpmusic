import os

path = 'lib/widgets/app_layout.dart'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace('_LyricPaneView(song: displaySong)', 'LyricPaneView(song: displaySong)')
content = content.replace('_buildQueuePaneView(queue, queueIndex)', 'const QueuePaneView()')

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)

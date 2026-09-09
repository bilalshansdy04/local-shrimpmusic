import os
import re

path = 'lib/screens/music_screen.dart'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# Replace AspectRatio with Flexible
content = re.sub(
    r'(\s*)if \(song != null\)\s*AspectRatio\(\s*aspectRatio: 1,\s*child: Container\(',
    r'\1if (song != null)\n\1  Flexible(\n\1    flex: 8,\n\1    child: AspectRatio(\n\1      aspectRatio: 1,\n\1      child: Container(',
    content
)

content = re.sub(
    r'(\s*fit: BoxFit\.cover\);\s*return Container\(.*?\);\s*},\s*loading: \(\) => Container\(.*?\),\s*error: \(_, __\) => Container\(.*?\),\s*\);\s*},\s*\),\s*\),\s*\),\s*\),\s*const SizedBox\(height: 48\),',
    r'\1fit: BoxFit.cover);\n                                  return Container(color: Colors.grey[300], child: const Center(child: Icon(Icons.music_note, size: 100)));\n                                },\n                                loading: () => Container(color: Colors.grey[300]),\n                                error: (_, __) => Container(color: Colors.grey[300]),\n                              );\n                            },\n                          ),\n                        ),\n                      ),\n                    ),\n                  const SizedBox(height: 48),',
    content
)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)

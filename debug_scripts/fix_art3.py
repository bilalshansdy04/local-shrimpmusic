import os

path = 'lib/screens/music_screen.dart'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

start_str = "                  if (song != null)\n                    AspectRatio(\n                      aspectRatio: 1,\n                      child: Container("
end_str = "                  const SizedBox(height: 48),\n                  // Title & Artist"

if start_str in content:
    content = content.replace(start_str, "                  if (song != null)\n                    Flexible(\n                      flex: 8,\n                      child: AspectRatio(\n                        aspectRatio: 1,\n                        child: Container(")
    # Need to find the end of the AspectRatio to add one more `),`
    # Just replace the last `),` before `const SizedBox(height: 48)`
    
    parts = content.split("                  const SizedBox(height: 48),\n                  // Title & Artist")
    parts[0] = parts[0] + "  ),\n"
    content = "                  const SizedBox(height: 48),\n                  // Title & Artist".join(parts)
    
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Success")
else:
    print("Failed")

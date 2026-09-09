import os

path = 'lib/screens/music_screen.dart'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

old_art = """                    // Album Art
                    if (song != null)
                      AspectRatio(
                        aspectRatio: 1,
                        child: Container("""

new_art = """                    // Album Art
                    if (song != null)
                      Flexible(
                        flex: 8,
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Container("""

content = content.replace(old_art, new_art)

# Need to add a closing parenthesis for Flexible
# The closing parenthesis of AspectRatio is before the SizedBox(height: 48)
old_after_art = """                              },
                            ),
                          ),
                        ),
                      ),
                  const SizedBox(height: 48),"""

new_after_art = """                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 48),"""

content = content.replace(old_after_art, new_after_art)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)

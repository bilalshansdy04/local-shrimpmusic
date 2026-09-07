# Product Requirements Document (PRD)
## Project: Ultra-Lightweight Local Music Player (Shrimp Local)
**Platform**: Windows, macOS, Linux, Android, iOS (Built with Flutter)
**Goal**: A blazing-fast, offline-first music player with minimal RAM and CPU footprint.

### 1. Core Features
- **Local Audio Scanning**: Scan device storage or specific folders for audio files (MP3, FLAC, WAV, M4A).
- **Metadata Extraction (ID3 Tags)**: Read Title, Artist, Album, and embedded Cover Art offline directly from the audio file.
- **Library Management**: Fast search, album grouping, artist grouping, custom local playlists, and "Liked Songs".
- **Hybrid Lyrics Engine**:
  - *Offline Mode*: Read .lrc files located in the same directory as the audio file.
  - *Online Fallback*: Automatically fetch synced lyrics from lrclib.net API if no local .lrc is found.
  - *Romanization*: On-the-fly transliteration for Japanese (Romaji) and Korean (Hangul) into standard alphabetical text.
- **Audio Engine**: Seamless playback, system media controls support, and background play support.

### 2. Tech Stack (Lightweight Focus)
- **Frontend**: Flutter (Dart)
- **Audio Player**: media_kit (C++ backed MPV engine, highly optimized for all platforms).
- **Local Database**: Isar or sqflite for lightning-fast indexing of thousands of tracks.
- **State Management**: lutter_riverpod.
- **Lyrics & Romanization**: lutter_lyric (Karaoke UI), kuroshiro (Japanese), korean_romanization_converter (Korean).

### 3. Non-Functional Requirements
- **Performance**: App must launch instantly. File scanning operations must be non-blocking.
- **Offline First**: The core app must function 100% without an internet connection.
- **UX/UI**: Clean, un-bloated, desktop & mobile responsive. *(Waiting for UI design uploads)*.

# Changelog

## v1.0.3 - 2026-09-10
- Hardcoded version removed; app now reads version from `package_info_plus`.
- Changelog fetched dynamically from GitHub Releases via new `showChangelog` function.
- Background auto‑update toggle disabled (no hidden service required).
- Video library (`media_kit_libs_windows_video`) removed to cut RAM usage below 100 MB.
- README updated with three distribution formats (ZIP, MSIX, EXE installer) and ZIP packaging instructions.
- Minor UI refinements and bug fixes.
- Updated `msix_config` and rebuilt MSIX package.

## v1.0.2 - 2026-08-30
- Added dynamic version display using `PackageInfo`.
- Integrated GitHub release check for updates.
- Cleaned up unused imports.

## v1.0.1 - 2026-08-15
- Fixed crashes on Windows due to missing DLLs.
- Improved folder selection workflow.

## v1.0.0 - 2026-08-01
- Initial release: local music playback, search, playlists, lyrics support.

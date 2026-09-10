import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/music_provider.dart';
import '../screens/playlist_detail_screen.dart';
import '../widgets/create_playlist_sheet.dart';

class PlaylistsScreen extends ConsumerStatefulWidget {
  const PlaylistsScreen({super.key});

  @override
  ConsumerState<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends ConsumerState<PlaylistsScreen> {
  String? _selectedPlaylistId;

  @override
  Widget build(BuildContext context) {
    // Jika ada playlist terpilih, tampilkan detail di slot yang sama
    if (_selectedPlaylistId != null) {
      return PlaylistDetailScreen(
        playlistId: _selectedPlaylistId!,
        onBack: () => setState(() => _selectedPlaylistId = null),
      );
    }

    final musicState = ref.watch(musicProvider);
    final playlists = musicState.playlists;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 32.0, right: 32.0, top: 48.0, bottom: 180.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Playlists",
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showCreatePlaylistSheet(context, ref),
              icon: const Icon(Icons.add_rounded),
              label: const Text("Create Playlist"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4500),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
            ),
            const SizedBox(height: 32),
            if (playlists.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 80),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.queue_music_rounded, size: 80, color: Colors.grey[200]),
                      const SizedBox(height: 16),
                      const Text("No Playlists Yet", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 8),
                      const Text("Create your first playlist to organize songs.", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1.1,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: playlists.length,
                itemBuilder: (context, index) {
                  final pl = playlists[index];
                  return InkWell(
                    onTap: () => setState(() => _selectedPlaylistId = pl.id),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey[100]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF3EE),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.queue_music_rounded, color: Color(0xFFFF4500), size: 24),
                              ),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_horiz_rounded, color: Colors.grey, size: 20),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onSelected: (value) => _handlePlaylistMenu(context, ref, pl.id, value),
                                itemBuilder: (context) => [
                                  const PopupMenuItem(value: 'open', child: Text('Open')),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete', style: TextStyle(color: Colors.red[400])),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            pl.name,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF111827)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${pl.songIds.length} songs",
                            style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  void _handlePlaylistMenu(BuildContext context, WidgetRef ref, String playlistId, String value) {
    if (value == 'open') {
      setState(() => _selectedPlaylistId = playlistId);
    } else if (value == 'delete') {
      ref.read(musicProvider.notifier).deletePlaylist(playlistId);
    }
  }

  Future<void> _showCreatePlaylistSheet(BuildContext context, WidgetRef ref) async {
    final result = await showCreatePlaylistSheet(context);
    if (result != null && result.isNotEmpty) {
      ref.read(musicProvider.notifier).createPlaylist(result);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../providers/lyric_provider.dart';

class SearchLyricDialog extends ConsumerStatefulWidget {
  final SongModel song;
  const SearchLyricDialog({super.key, required this.song});

  @override
  ConsumerState<SearchLyricDialog> createState() => SearchLyricDialogState();
}

class SearchLyricDialogState extends ConsumerState<SearchLyricDialog> {
  final _titleController = TextEditingController();
  final _artistController = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.song.title;
    _artistController.text = widget.song.artist ?? '';
  }

  Future<void> _search() async {
    setState(() => _isLoading = true);
    final results = await ref
        .read(lyricProvider.notifier)
        .searchOnline(_titleController.text, _artistController.text);
    setState(() {
      _results = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Search Lyrics on LRCLIB"),
      content: SizedBox(
        width: 400,
        height: 500,
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Track Name"),
            ),
            TextField(
              controller: _artistController,
              decoration: const InputDecoration(labelText: "Artist Name"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _search, child: const Text("Search")),
            const SizedBox(height: 16),
            if (_isLoading) const CircularProgressIndicator(),
            Expanded(
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final result = _results[index];
                  final synced = result['syncedLyrics'];
                  final hasSynced =
                      synced != null && synced.toString().isNotEmpty;
                  return ListTile(
                    title: Text(result['trackName'] ?? 'Unknown'),
                    subtitle: Text(
                      "${result['artistName']} - ${result['albumName']}\n${hasSynced ? "Synced Lyrics Available" : "Plain Lyrics Only"}",
                    ),
                    isThreeLine: true,
                    onTap: () {
                      if (hasSynced) {
                        ref
                            .read(lyricProvider.notifier)
                            .saveAndUseLyric(synced, widget.song.data);
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "This track only has plain lyrics. Synced lyrics required.",
                            ),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
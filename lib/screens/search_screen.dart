import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../providers/music_provider.dart";
import "../widgets/song_row.dart";

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _c = TextEditingController();
  String _q = "";
  // ponytail: memori saja, persist SharedPreferences kalau riwayat harus awet.
  final List<String> _history = [];

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _pushHistory(String raw) {
    final v = raw.trim();
    if (v.isEmpty) return;
    setState(() {
      _history.remove(v);
      _history.insert(0, v);
      if (_history.length > 8) _history.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    final music = ref.watch(musicProvider);
    final all = music.allSongs;
    // ponytail: scan substring O(n), tambah index kalau >10k lagu.
    final q = _q.trim().toLowerCase();
    final filtered = all.where((s) {
      return q.isNotEmpty &&
          (s.title.toLowerCase().contains(q) ||
              (s.artist ?? "").toLowerCase().contains(q) ||
              (s.album ?? "").toLowerCase().contains(q));
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 24.0,
          right: 24.0,
          top: 48.0,
          bottom: 180.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Search",
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _c,
              cursorColor: Color(0xFFFF4500),
              onChanged: (v) => setState(() => _q = v),
              onSubmitted: _pushHistory,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: "Judul, artis, album...",
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
                prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
                suffixIcon: _q.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 20),
                        onPressed: () {
                          _c.clear();
                          setState(() => _q = "");
                        },
                      ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFFFF4500),
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            if (music.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: CircularProgressIndicator(
                    color: Color(0xFFFF4500),
                  ),
                ),
              )
            else if (q.isEmpty)
              _buildRecent()
            else if (filtered.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 48),
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 56,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Tidak ketemu",
                        style: TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Coba kata kunci lain",
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${filtered.length} hasil untuk \"${_q.trim()}\"",
                    style: const TextStyle(
                      color: Color(0xFF374151),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final song = filtered[i];
                      return SongRow(
                        index: i,
                        song: song,
                        onTap: () {
                          _pushHistory(_c.text);
                          ref
                              .read(musicProvider.notifier)
                              .playSong(song, contextList: filtered);
                        },
                      );
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecent() {
    if (_history.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 48),
          child: Column(
            children: [
              Icon(Icons.search_rounded, size: 56, color: Colors.grey[300]),
              const SizedBox(height: 12),
              const Text(
                "Cari lagu favoritmu",
                style: TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Riwayat pencarian muncul di sini",
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Terakhir dicari",
              style: TextStyle(
                color: Color(0xFF374151),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _history.clear()),
              child: const Text(
                "Hapus",
                style: TextStyle(color: Color(0xFFFF4500)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _history.length,
          itemBuilder: (context, i) {
            final h = _history[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                dense: true,
                leading: const Icon(Icons.history_rounded, color: Colors.grey),
                title: Text(
                  h,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: () => setState(() => _history.removeAt(i)),
                ),
                onTap: () {
                  _c.text = h;
                  setState(() => _q = h);
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

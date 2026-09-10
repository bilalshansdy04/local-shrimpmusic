import "dart:convert";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:http/http.dart" as http;
import "package:package_info_plus/package_info_plus.dart";

import "../providers/music_provider.dart";

Future<void> showChangelog(BuildContext context) async {
  const api = "https://api.github.com/repos/bilalshansdy04/local-shrimpmusic/releases/latest";
  showDialog(
    context: context,
    builder: (context) => FutureBuilder<http.Response>(
      future: http.get(Uri.parse(api)),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const AlertDialog(
            content: SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        String body = "Gagal memuat catatan rilis.";
        if (snap.hasData && snap.data!.statusCode == 200) {
          try {
            final json = jsonDecode(snap.data!.body);
            body = json["body"] ?? "Tidak ada catatan rilis.";
          } catch (_) {}
        }
        return AlertDialog(
          title: const Text("Catatan Rilis"),
          content: SingleChildScrollView(child: Text(body)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Tutup"),
            ),
          ],
        );
      },
    ),
  );
}
Future<void> checkForUpdates(BuildContext context) async {
  final info = await PackageInfo.fromPlatform();
  final current = info.version;
  const api =
      "https://api.github.com/repos/bilalshansdy04/local-shrimpmusic/releases/latest";
  try {
    final res = await http.get(Uri.parse(api));
    if (res.statusCode != 200) throw Exception("${res.statusCode}");
    final tag = (jsonDecode(res.body)["tag_name"] as String)
        .replaceAll("v", "")
        .trim();
    if (!context.mounted) return;
    final update = tag != current;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(update ? "Update tersedia: $tag" : "Sudah terbaru"),
        content: Text(
          update
              ? "Versi lokal $current. Unduh manual di halaman Releases."
              : "Versi lokal $current sama dengan GitHub.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Cek gagal: $e")));
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final musicState = ref.watch(musicProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 32.0,
          right: 32.0,
          top: 48.0,
          bottom: 180.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Settings",
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 32),

            // Music Library Section
            const Text(
              "Music Library",
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
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
                  Text(
                    musicState.musicFolderPath ?? "Default System Music Folder",
                    style: const TextStyle(
                      color: Color(0xFF374151),
                      fontSize: 16,
                      fontFamily: "monospace",
                    ),
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: () {
                      ref.read(musicProvider.notifier).pickMusicFolder();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF111827),
                      side: BorderSide(color: Colors.grey.shade400),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                    child: const Text(
                      "Add a source",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // About & Updates Section
            const Text(
              "Tentang Aplikasi",
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
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
                      // Versi & Arsitektur
                      const Text(
                        "Versi perangkat lunak",
                        style: TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      FutureBuilder<PackageInfo>(
                        future: PackageInfo.fromPlatform(),
                        builder: (context, snap) {
                          final v = snap.data?.version ?? "1.0.0";
                          return Text(
                            "v$v",
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 14,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // Pembaruan
                      const Text(
                        "Pembaruan",
                        style: TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          OutlinedButton(
                            onPressed: () => checkForUpdates(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF111827),
                              side: BorderSide(color: Colors.grey.shade400),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: const Text("Check for updates"),
                          ),
                          const SizedBox(width: 12),
                          TextButton(
                            onPressed: () => showChangelog(context),
                            child: const Text("Changelog"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Legal
                      const Text(
                        "Legal",
                        style: TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        children: [
                          TextButton(
                            onPressed: () {},
                            child: const Text("Terms of Service"),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text("Kebijakan Privasi"),
                          ),
                          TextButton(
                            onPressed: () {
                              showLicensePage(context: context);
                            },
                            child: const Text("Open Source Licenses"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

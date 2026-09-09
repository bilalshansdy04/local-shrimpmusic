import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/music_provider.dart';

class QueuePaneView extends ConsumerWidget {
  const QueuePaneView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final musicState = ref.watch(musicProvider);
    final queue = musicState.queue;
    final queueIndex = musicState.queueIndex;

    return Column(
      children: [
        // Tabs
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          // child: Row(
          //   children: [
          //     Container(
          //       padding: const EdgeInsets.symmetric(
          //         horizontal: 16,
          //         vertical: 8,
          //       ),
          //       decoration: BoxDecoration(
          //         color: const Color(0xFFFF4500),
          //         borderRadius: BorderRadius.circular(8),
          //       ),
          //       child: const Text(
          //         "Playing Next",
          //         style: TextStyle(
          //           color: Colors.white,
          //           fontWeight: FontWeight.bold,
          //           fontSize: 16,
          //         ),
          //       ),
          //     ),
          //     const SizedBox(width: 24),
          //     const Text(
          //       "History",
          //       style: TextStyle(
          //         color: Colors.black,
          //         fontWeight: FontWeight.bold,
          //         fontSize: 16,
          //       ),
          //     ),
          //   ],
          // ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Playing Next",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              // Text(
              //   "Clear",
              //   style: TextStyle(
              //     color: Colors.grey[800],
              //     fontWeight: FontWeight.bold,
              //     fontSize: 14,
              //   ),
              // ),
            ],
          ),
        ),
        const Divider(height: 24, thickness: 1, color: Color(0xFFF0F0F0)),
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            buildDefaultDragHandles: false,
            itemCount: queue.length - queueIndex - 1,
            onReorder: (oldIndex, newIndex) {
              final absoluteOld = queueIndex + 1 + oldIndex;
              final absoluteNew = queueIndex + 1 + newIndex;
              ref
                  .read(musicProvider.notifier)
                  .reorderQueue(absoluteOld, absoluteNew);
            },
            itemBuilder: (context, index) {
              final absoluteIndex = queueIndex + 1 + index;
              final song = queue[absoluteIndex];
              return Dismissible(
                key: ValueKey('dismiss_${song.id}_$absoluteIndex'),
                direction: DismissDirection.horizontal,
                onDismissed: (direction) {
                  ref
                      .read(musicProvider.notifier)
                      .removeFromQueue(absoluteIndex);
                },
                // Background saat digeser ke kanan (Ikon di kiri)
                background: Container(
                  color: Colors.red[400],
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 24),
                  child: const Icon(Icons.delete_outline, color: Colors.white),
                ),
                // Background saat digeser ke kiri (Ikon di kanan)
                secondaryBackground: Container(
                  color: Colors.red[400],
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  child: const Icon(Icons.delete_outline, color: Colors.white),
                ),
                child: InkWell(
                  onTap: () {
                    ref
                        .read(musicProvider.notifier)
                        .skipToQueueItem(absoluteIndex);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        MouseRegion(
                          cursor: SystemMouseCursors.grab,
                          child: ReorderableDragStartListener(
                            index: index,
                            child: Container(
                              padding: const EdgeInsets.only(
                                right: 8.0,
                                left: 4.0,
                              ),
                              child: const Icon(
                                Icons.drag_indicator_rounded,
                                color: Colors.grey,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Consumer(
                            builder: (context, ref, _) {
                              final art = ref.watch(artworkProvider(song.data));
                              return art.when(
                                data: (bytes) {
                                  if (bytes != null) {
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        bytes,
                                        fit: BoxFit.cover,
                                        cacheWidth: 100,
                                      ),
                                    );
                                  }
                                  return const Icon(
                                    Icons.music_note,
                                    color: Colors.grey,
                                  );
                                },
                                loading: () => const SizedBox(),
                                error: (_, _) => const SizedBox(),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                song.title,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "${song.artist ?? 'Unknown'} • ${song.album ?? 'Unknown'}",
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Jarak tambahan di sisi kanan agar titik-titik overflow tidak mentok ke ujung layar.
                        // Kamu bisa mengubah angka 16 ini menjadi lebih besar (misal: 32) jika ingin titik-titiknya lebih ke kiri lagi!
                        const SizedBox(width: 32),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

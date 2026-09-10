import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:media_kit/media_kit.dart";
import "package:window_manager/window_manager.dart";
import "widgets/app_layout.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await windowManager.ensureInitialized();
  await windowManager.waitUntilReadyToShow(
    const WindowOptions(size: Size(1280, 720), center: true, titleBarStyle: TitleBarStyle.hidden),
    () async { await windowManager.show(); await windowManager.focus(); },
  );
  runApp(const ProviderScope(child: ShrimpMusic()));
}

class ShrimpMusic extends StatelessWidget {
  const ShrimpMusic({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "ShrimpMusic",
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFCFBFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF4500),
          primary: const Color(0xFFFF4500),
          surface: const Color(0xFFFCFBFC),
          onSurface: const Color(0xFF111827), // text-gray-900
        ),
        fontFamily: "Montserrat",
        scrollbarTheme: ScrollbarThemeData(
          thickness: WidgetStateProperty.all(4.0),
          thumbColor: WidgetStateProperty.all(const Color(0xFFFF7745)),
          radius: const Radius.circular(8),
        ),
      ),
      home: const AppLayout(),
      debugShowCheckedModeBanner: false,
    );
  }
}



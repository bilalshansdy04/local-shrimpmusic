import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:media_kit/media_kit.dart";
import "widgets/app_layout.dart";

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
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



import 'package:dsaclear/ollama_chat.dart';
import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  const Size windowSize = Size(600, 700);

  WindowOptions windowOptions = const WindowOptions(
    size: windowSize,
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    alwaysOnTop: true,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setAsFrameless();
    await windowManager.setAlwaysOnTop(true);
    await windowManager.setIgnoreMouseEvents(false);
    await windowManager.show();
    await windowManager.focus();
  });

  

  runApp(const OverlayWindow());

  doWhenWindowReady(() {
    appWindow.minSize = windowSize;
    appWindow.size = windowSize;
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });
}

class OverlayWindow extends StatelessWidget {
  const OverlayWindow({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClearDSA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        fontFamily: 'SF Pro Display',
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        fontFamily: 'SF Pro Display',
      ),
      themeMode: ThemeMode.system,
      home: const MinimalOverlay(),
    );
  }
}

class MinimalOverlay extends StatelessWidget {
  const MinimalOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withAlpha((0.05 * 255).toInt()), // Ensures hit testing
      body: MoveWindow(
        child: const OllamaChat(),
      ),
    );
  }
}

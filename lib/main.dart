import 'package:dsaclear/ollama_chat.dart';
import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await hotKeyManager.unregisterAll();

  const Size windowSize = Size(600, 700);

  WindowOptions windowOptions = const WindowOptions(
      size: windowSize,
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
      alwaysOnTop: true,
      windowButtonVisibility: false);

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setAsFrameless();
    await windowManager.setAlwaysOnTop(true);
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

  // Define and register hotkey: Ctrl + Option + O
  HotKey _hotKeyVisibility = HotKey(
    key: PhysicalKeyboardKey.keyO,
    modifiers: [
      HotKeyModifier.control,
    ],
    scope: HotKeyScope.system,
  );
  HotKeyRecorder(
    onHotKeyRecorded: (hotKey) {
      _hotKeyVisibility = hotKey;
    },
  );

  // Register hotkeys for scrolling up and down
  HotKey _scrollUpHotKey = HotKey(
    key: PhysicalKeyboardKey.keyW,
    modifiers: [HotKeyModifier.control],
    scope: HotKeyScope.system,
  );
  HotKeyRecorder(
    onHotKeyRecorded: (hotKey) {
      _scrollUpHotKey = hotKey;
    },
  );

  HotKey _scrollDownHotKey = HotKey(
    key: PhysicalKeyboardKey.keyS,
    modifiers: [HotKeyModifier.control],
    scope: HotKeyScope.system,
  );
  HotKeyRecorder(
    onHotKeyRecorded: (hotKey) {
      _scrollDownHotKey = hotKey;
    },
  );
  await hotKeyManager.register(_scrollUpHotKey, keyDownHandler: (hotKey) {
    if (scrollController.hasClients) {
      final newOffset = (scrollController.position.pixels - 100).clamp(
        0.0,
        scrollController.position.maxScrollExtent,
      );
      scrollController.animateTo(
        newOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  });

  await hotKeyManager.register(_scrollDownHotKey, keyDownHandler: (hotKey) {
    if (scrollController.hasClients) {
      final newOffset = (scrollController.position.pixels + 100).clamp(
        0.0,
        scrollController.position.maxScrollExtent,
      );
      scrollController.animateTo(
        newOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  });

  bool isVisible = true;
  await hotKeyManager.register(_hotKeyVisibility,
      keyDownHandler: (hotKey) async {
    isVisible = !isVisible;
    if (isVisible) {
      await windowManager.setOpacity(1.0);
    } else {
      await windowManager.setOpacity(0.0);
    }
  });

  bool isDisabled = true;

  HotKey _toggleMouseEventDisablity = HotKey(
    key: PhysicalKeyboardKey.keyM,
    modifiers: [HotKeyModifier.control],
    scope: HotKeyScope.system,
  );
  HotKeyRecorder(
    onHotKeyRecorded: (hotKey) {
      _toggleMouseEventDisablity = hotKey;
    },
  );
  await hotKeyManager.register(_toggleMouseEventDisablity,
      keyDownHandler: (hotKey) async {
    isDisabled = !isDisabled;
    await windowManager.setIgnoreMouseEvents(isDisabled, forward: isDisabled);
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
      backgroundColor:
          Colors.black.withAlpha((0.05 * 255).toInt()), // Slight transparency
      body: MoveWindow(
        child: const OllamaChat(),
      ),
    );
  }
}

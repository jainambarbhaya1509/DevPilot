import 'dart:async';
import 'dart:io';

class HoverTextService {
  static final HoverTextService _instance = HoverTextService._internal();
  factory HoverTextService() => _instance;

  HoverTextService._internal();

  final _controller = StreamController<String>.broadcast();
  String _lastHoveredText = "Waiting for hover text...";

  String get lastHoveredText => _lastHoveredText;
  Stream<String> get textStream => _controller.stream;

  Future<void> startServer({int port = 8080}) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    print("WebSocket server listening on ws://localhost:$port");

    await for (HttpRequest request in server) {
      if (WebSocketTransformer.isUpgradeRequest(request)) {
        WebSocket socket = await WebSocketTransformer.upgrade(request);
        print("Swift connected to Flutter via WebSocket");

        socket.listen((data) {
          print("Received from Swift: $data");
          _lastHoveredText = data;
          _controller.add(data);
        });
      } else {
        request.response
          ..statusCode = HttpStatus.forbidden
          ..close();
      }
    }
  }

  void dispose() {
    _controller.close();
  }
}

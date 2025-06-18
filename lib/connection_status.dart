import 'package:flutter/material.dart';
import 'package:ollama/ollama.dart';

class ConnectionStatus extends StatefulWidget {
  final Ollama ollama;
  final bool isDark;

  const ConnectionStatus({
    super.key,
    required this.ollama,
    required this.isDark,
  });

  @override
  State<ConnectionStatus> createState() => _ConnectionStatusState();
}

class _ConnectionStatusState extends State<ConnectionStatus>
    with SingleTickerProviderStateMixin {
  bool _isConnected = false;
  bool _isChecking = true;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _checkConnection();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _checkConnection() async {
    setState(() {
      _isChecking = true;
    });
    _pulseController.repeat();

    try {
      await widget.ollama.generate('test', model: 'codegemma').take(1).toList();
      if (mounted) {
        setState(() {
          _isConnected = true;
          _isChecking = false;
        });
        _pulseController.stop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConnected = false;
          _isChecking = false;
        });
        _pulseController.stop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (_isChecking) {
      statusColor = const Color(0xFFFB8500);
      statusText = 'Connecting...';
      statusIcon = Icons.sync_rounded;
    } else if (_isConnected) {
      statusColor = const Color(0xFF238636);
      statusText = 'Connected';
      statusIcon = Icons.check_circle_outline_rounded;
    } else {
      statusColor = const Color(0xFFDA3633);
      statusText = 'Disconnected';
      statusIcon = Icons.error_outline_rounded;
    }

    return GestureDetector(
      onTap: _checkConnection,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: statusColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _isChecking ? _pulseController.value * 2 * 3.14159 : 0,
                  child: Icon(
                    statusIcon,
                    size: 12,
                    color: statusColor,
                  ),
                );
              },
            ),
            const SizedBox(width: 4),
            Text(
              statusText,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

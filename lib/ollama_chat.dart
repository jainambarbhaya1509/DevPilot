import 'package:flutter/material.dart';
import 'package:ollama/ollama.dart';
import 'package:window_manager/window_manager.dart';
import 'model_selector.dart';
import 'connection_status.dart';
import 'code_block_widget.dart';
import 'hover_text_service.dart';

class Message {
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final bool isStreaming;

  Message({
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.isStreaming = false,
  });
}

class OllamaChat extends StatefulWidget {
  const OllamaChat({super.key});

  @override
  State<OllamaChat> createState() => _OllamaChatState();
}

class _OllamaChatState extends State<OllamaChat> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Message> _messages = [];
  bool _isLoading = false;
  late AnimationController _fadeController;
  late AnimationController _cursorController;
  late Animation<double> _fadeAnimation;
  late Ollama _ollama;
  late final HoverTextService _hoverTextService;
  String _selectedModel = 'codegemma';

  @override
  void initState() {
    super.initState();
    _ollama = Ollama();

    _hoverTextService = HoverTextService();
    _hoverTextService.startServer(); // Start WebSocket server

    // Listen to incoming hover text and auto-send it
    _hoverTextService.textStream.listen((hoveredText) {
      if (!_isLoading && hoveredText.trim().isNotEmpty) {
        _messageController.text = hoveredText;
        _sendMessage(); // Trigger send
      }
    });

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _cursorController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );
    _fadeController.forward();
    _cursorController.repeat(reverse: true);

    // Add welcome message
    _messages.add(Message(
      content:
          "Hello! I'm CodeAssist AI, your intelligent coding companion. I can help you with:\n\n• Code generation and completion\n• Debugging and optimization\n• Architecture and best practices\n• Documentation and explanations\n\nWhat would you like to work on today?",
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _fadeController.dispose();
    _cursorController.dispose();
    super.dispose();
  }

  void _sendMessageWithoutTyping() async {
    final userMessage = _messageController.text.trim();
    if (userMessage.isEmpty) return;

    setState(() => _isLoading = true);

    // Simulate sending
    print("Sending: $userMessage");

    // Reset loading & input after delay
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isLoading = false;
        _messageController.clear();
      });
    });
    setState(() {
      _messages.add(Message(
        content: userMessage,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      setState(() {
        _messages.add(Message(
          content: "",
          isUser: false,
          timestamp: DateTime.now(),
          isStreaming: true,
        ));
        _isLoading = false;
      });

      final messageIndex = _messages.length - 1;
      final stream = _ollama.generate(
        userMessage,
        model: _selectedModel,
      );

      await for (final chunk in stream) {
        setState(() {
          _messages[messageIndex] = Message(
            content: _messages[messageIndex].content + chunk.text,
            isUser: false,
            timestamp: _messages[messageIndex].timestamp,
            isStreaming: true,
          );
        });
        _scrollToBottom();
      }

      // Mark streaming as complete
      setState(() {
        _messages[messageIndex] = Message(
          content: _messages[messageIndex].content,
          isUser: false,
          timestamp: _messages[messageIndex].timestamp,
          isStreaming: false,
        );
      });
    } catch (e) {
      setState(() {
        if (_messages.isNotEmpty && !_messages.last.isUser) {
          _messages.removeLast();
        }
        _messages.add(Message(
          content:
              "⚠️ **Connection Error**\n\nI couldn't connect to the Ollama service. Please ensure:\n\n• Ollama is installed and running\n• The model `$_selectedModel` is available\n• Run `ollama pull $_selectedModel` if needed\n\n\`\`\`bash\n# Start Ollama service\nollama serve\n\n# Pull the model\nollama pull $_selectedModel\n\`\`\`",
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _messages.add(Message(
        content: userMessage,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      setState(() {
        _messages.add(Message(
          content: "",
          isUser: false,
          timestamp: DateTime.now(),
          isStreaming: true,
        ));
        _isLoading = false;
      });

      final messageIndex = _messages.length - 1;
      final stream = _ollama.generate(
        userMessage,
        model: _selectedModel,
      );

      await for (final chunk in stream) {
        setState(() {
          _messages[messageIndex] = Message(
            content: _messages[messageIndex].content + chunk.text,
            isUser: false,
            timestamp: _messages[messageIndex].timestamp,
            isStreaming: true,
          );
        });
        _scrollToBottom();
      }

      // Mark streaming as complete
      setState(() {
        _messages[messageIndex] = Message(
          content: _messages[messageIndex].content,
          isUser: false,
          timestamp: _messages[messageIndex].timestamp,
          isStreaming: false,
        );
      });
    } catch (e) {
      setState(() {
        if (_messages.isNotEmpty && !_messages.last.isUser) {
          _messages.removeLast();
        }
        _messages.add(Message(
          content:
              "⚠️ **Connection Error**\n\nI couldn't connect to the Ollama service. Please ensure:\n\n• Ollama is installed and running\n• The model `$_selectedModel` is available\n• Run `ollama pull $_selectedModel` if needed\n\n\`\`\`bash\n# Start Ollama service\nollama serve\n\n# Pull the model\nollama pull $_selectedModel\n\`\`\`",
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      _messages.add(Message(
        content:
            "Chat cleared. Ready to assist with your next coding challenge!",
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  double _windowOpacity = 1.0;

  void _toggleVisibility() async {
    _windowOpacity = _windowOpacity == 1.0 ? 0.0 : 1.0;
    await windowManager.setOpacity(_windowOpacity);
    setState(() {});
  }

  void _onModelChanged(String model) {
    setState(() {
      _selectedModel = model;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Header
            Container(
              height: 56,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? const Color(0xFF30363D)
                        : const Color(0xFFD0D7DE),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color.fromARGB(255, 77, 82, 88)
                          : const Color(0xFFF6F8FA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.code_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CodeAssist AI',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Intelligent Coding Companion',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onBackground,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ConnectionStatus(
                    ollama: _ollama,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 12),
                  ModelSelector(
                    selectedModel: _selectedModel,
                    onModelChanged: _onModelChanged,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _clearChat,
                    icon: Icon(
                      Icons.refresh_rounded,
                      color: theme.colorScheme.onBackground,
                      size: 18,
                    ),
                    tooltip: 'Clear conversation',
                    style: IconButton.styleFrom(
                      backgroundColor: isDark
                          ? const Color(0xFF21262D)
                          : const Color(0xFFF6F8FA),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _toggleVisibility,
                    icon: Icon(
                      Icons.remove_red_eye,
                      color: theme.colorScheme.onBackground,
                      size: 18,
                    ),
                    tooltip: 'Visibility toggle',
                    style: IconButton.styleFrom(
                      backgroundColor: isDark
                          ? const Color(0xFF21262D)
                          : const Color(0xFFF6F8FA),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),

            // Messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isLoading) {
                    return _buildTypingIndicator(theme, isDark);
                  }

                  final message = _messages[index];
                  return _buildMessageBubble(message, theme, isDark);
                },
              ),
            ),

            // Input area
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? const Color(0xFF30363D)
                        : const Color(0xFFD0D7DE),
                    width: 1,
                  ),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 120),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0D1117) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF30363D)
                              : const Color(0xFFD0D7DE),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Ask me anything about code...',
                          hintStyle: TextStyle(
                            color: theme.colorScheme.onBackground,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 14,
                          height: 1.4,
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessageWithoutTyping(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF21262D)
                          : const Color(0xFFF6F8FA),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: _isLoading ? null : _sendMessage,
                        child: Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.arrow_upward_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Message message, ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: message.isUser
                  ? (isDark ? const Color(0xFF21262D) : const Color(0xFFF6F8FA))
                  : isDark
                      ? const Color.fromARGB(255, 77, 82, 88)
                      : const Color(0xFFF6F8FA),
              borderRadius: BorderRadius.circular(8),
              border: message.isUser
                  ? Border.all(
                      color: isDark
                          ? const Color(0xFF30363D)
                          : const Color(0xFFD0D7DE),
                      width: 1,
                    )
                  : null,
            ),
            child: Icon(
              message.isUser
                  ? Icons.person_outline_rounded
                  : Icons.code_rounded,
              color: message.isUser
                  ? theme.colorScheme.onBackground
                  : Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 16),

          // Message content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author label
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    message.isUser ? 'You' : 'CodeAssist AI',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                ),

                // Message content
                Container(
                  width: double.infinity,
                  child: _buildMessageContent(message, theme, isDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(Message message, ThemeData theme, bool isDark) {
    final content = message.content;

    // Check if message contains code blocks
    if (content.contains('\`\`\`')) {
      return _buildRichContent(content, theme, isDark, message.isStreaming);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SelectableText(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        if (message.isStreaming)
          AnimatedBuilder(
            animation: _cursorController,
            builder: (context, child) {
              return Opacity(
                opacity: _cursorController.value,
                child: Container(
                  width: 2,
                  height: 20,
                  margin: const EdgeInsets.only(left: 2, top: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildRichContent(
      String content, ThemeData theme, bool isDark, bool isStreaming) {
    final parts = content.split('\`\`\`');
    final widgets = <Widget>[];

    for (int i = 0; i < parts.length; i++) {
      if (i % 2 == 0) {
        // Regular text
        if (parts[i].trim().isNotEmpty) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SelectableText(
                parts[i].trim(),
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          );
        }
      } else {
        // Code block
        final lines = parts[i].split('\n');
        final language = lines.isNotEmpty ? lines[0].trim() : '';
        final code = lines.skip(1).join('\n').trim();

        if (code.isNotEmpty) {
          widgets.add(
            CodeBlockWidget(
              code: code,
              language: language.isEmpty ? 'text' : language,
              isDark: isDark,
            ),
          );
        }
      }
    }

    if (isStreaming && widgets.isNotEmpty) {
      widgets.add(
        AnimatedBuilder(
          animation: _cursorController,
          builder: (context, child) {
            return Opacity(
              opacity: _cursorController.value,
              child: Container(
                width: 2,
                height: 20,
                margin: const EdgeInsets.only(left: 2, top: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            );
          },
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildTypingIndicator(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.code_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'CodeAssist AI',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF161B22)
                      : const Color(0xFFF6F8FA),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF30363D)
                        : const Color(0xFFD0D7DE),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Thinking',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 20,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildDot(0, theme),
                          _buildDot(1, theme),
                          _buildDot(2, theme),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index, ThemeData theme) {
    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        final value = (_fadeController.value + index * 0.3) % 1.0;
        return Opacity(
          opacity: 0.3 + (0.7 * (1 - (value - 0.5).abs() * 2).clamp(0.0, 1.0)),
          child: Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onBackground,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

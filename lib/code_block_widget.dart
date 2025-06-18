import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CodeBlockWidget extends StatelessWidget {
  final String code;
  final String language;
  final bool isDark;

  const CodeBlockWidget({
    super.key,
    required this.code,
    required this.language,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : const Color(0xFFF6F8FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with language and copy button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF21262D) : const Color(0xFFEAEEF2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(7),
                topRight: Radius.circular(7),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getLanguageIcon(language),
                  size: 14,
                  color: isDark ? const Color(0xFF8B949E) : const Color(0xFF656D76),
                ),
                const SizedBox(width: 6),
                Text(
                  language.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF8B949E) : const Color(0xFF656D76),
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Code copied to clipboard'),
                        duration: const Duration(seconds: 2),
                        backgroundColor: isDark ? const Color(0xFF238636) : const Color(0xFF1F883D),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.content_copy_rounded,
                      size: 14,
                      color: isDark ? const Color(0xFF8B949E) : const Color(0xFF656D76),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Code content
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            child: SelectableText(
              code,
              style: TextStyle(
                fontFamily: 'SF Mono',
                fontSize: 13,
                height: 1.4,
                color: isDark ? const Color(0xFFF0F6FC) : const Color(0xFF24292F),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getLanguageIcon(String language) {
    switch (language.toLowerCase()) {
      case 'dart':
      case 'flutter':
        return Icons.flutter_dash;
      case 'javascript':
      case 'js':
        return Icons.javascript;
      case 'python':
        return Icons.code;
      case 'java':
        return Icons.coffee;
      case 'swift':
        return Icons.phone_iphone;
      default:
        return Icons.code;
    }
  }
}

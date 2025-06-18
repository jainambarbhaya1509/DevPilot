import 'package:flutter/material.dart';

class ModelSelector extends StatelessWidget {
  final String selectedModel;
  final Function(String) onModelChanged;
  final bool isDark;

  const ModelSelector({
    super.key,
    required this.selectedModel,
    required this.onModelChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final models = [
      {'name': 'codegemma', 'description': 'Code generation & completion'},
      {'name': 'llama3.2', 'description': 'General purpose assistant'},
    ];

    return PopupMenuButton<String>(
      initialValue: selectedModel,
      onSelected: onModelChanged,
      tooltip: 'Select AI Model',
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE),
          width: 1,
        ),
      ),
      color: isDark ? const Color(0xFF161B22) : Colors.white,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF21262D) : const Color(0xFFF6F8FA),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.psychology_outlined,
              size: 14,
              color: isDark ? const Color(0xFF8B949E) : const Color(0xFF656D76),
            ),
            const SizedBox(width: 6),
            Text(
              selectedModel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? const Color(0xFFF0F6FC) : const Color(0xFF24292F),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: isDark ? const Color(0xFF8B949E) : const Color(0xFF656D76),
            ),
          ],
        ),
      ),
      itemBuilder: (context) => models.map((model) {
        final isSelected = selectedModel == model['name'];
        return PopupMenuItem<String>(
          value: model['name'],
          child: Container(
            width: 280,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.smart_toy_outlined,
                      size: 16,
                      color: isSelected
                          ? (isDark ? const Color(0xFF58A6FF) : const Color(0xFF0969DA))
                          : (isDark ? const Color(0xFF8B949E) : const Color(0xFF656D76)),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      model['name']!,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? (isDark ? const Color(0xFF58A6FF) : const Color(0xFF0969DA))
                            : (isDark ? const Color(0xFFF0F6FC) : const Color(0xFF24292F)),
                      ),
                    ),
                    if (isSelected) ...[
                      const Spacer(),
                      Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: isDark ? const Color(0xFF58A6FF) : const Color(0xFF0969DA),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: Text(
                    model['description']!,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? const Color(0xFF8B949E) : const Color(0xFF656D76),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

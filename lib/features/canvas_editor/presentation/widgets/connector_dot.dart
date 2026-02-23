import 'package:flutter/material.dart';

@immutable
class ConnectorDot extends StatelessWidget {
  const ConnectorDot({
    super.key,
    this.highlighted = false,
    this.accept = false,
    this.output = false,
  });

  final bool highlighted;
  final bool accept;
  final bool output;

  @override
  Widget build(BuildContext context) {
    final color = switch ((output, highlighted, accept)) {
      (true, _, _) => const Color(0xFF2E6157),
      (false, true, true) => const Color(0xFF3D8B7D),
      (false, true, false) => const Color(0xFF9AA6A3),
      _ => const Color(0xFFB1BCB9),
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 110),
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        shape: .circle,
        border: .all(color: Colors.white.withValues(alpha: 0.9), width: 1.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
    );
  }
}

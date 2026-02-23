import 'package:flutter/material.dart';

@immutable
class ConcatNodeBody extends StatelessWidget {
  const ConcatNodeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const .symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF6FAF8),
        borderRadius: .circular(10),
      ),
      child: const Text(
        'Using connected inputs',
        style: TextStyle(fontSize: 13, color: Color(0xFF6C7D79)),
      ),
    );
  }
}

import 'package:flutter/material.dart';

@immutable
class PrefixNodeBody extends StatelessWidget {
  const PrefixNodeBody({
    required this.controller,
    required this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Type a prefix',
          isDense: true,
          contentPadding: const .all(10),
          filled: true,
          fillColor: const Color(0xFFF6F8F8),
          border: OutlineInputBorder(
            borderRadius: .circular(10),
            borderSide: .none,
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

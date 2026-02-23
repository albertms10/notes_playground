import 'package:flutter/material.dart';

@immutable
class TextNodeBody<V> extends StatelessWidget {
  const TextNodeBody({
    required this.value,
    required this.displayText,
    super.key,
  });

  final V value;
  final String Function(String) displayText;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.headlineLarge;

    return SizedBox(
      width: double.infinity,
      child: Center(
        child: Padding(
          padding: const .only(top: 7, bottom: 8, left: 8, right: 8),
          child: Text(
            displayText(value.toString()),
            style: textStyle,
          ),
        ),
      ),
    );
  }
}

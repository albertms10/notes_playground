import 'package:flutter/material.dart';
import 'package:music_notes/music_notes.dart';

@immutable
class TextEditingNodeBody<T> extends StatefulWidget {
  const TextEditingNodeBody({
    required this.controller,
    required this.parser,
    this.displayText,
    this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final StringParser<T>? Function(String) parser;
  final String Function(T value)? displayText;

  @override
  State<TextEditingNodeBody<T>> createState() => _TextEditingNodeBodyState<T>();
}

class _TextEditingNodeBodyState<T> extends State<TextEditingNodeBody<T>> {
  bool _isEditing = false;
  late final FocusNode _focusNode;
  bool _isValid = true;

  String _format(String text) {
    final parsedValue = widget.parser(text)!.parse(text);

    return widget.displayText?.call(parsedValue) ?? parsedValue.toString();
  }

  void _onSubmitted(String value) {
    if (widget.parser(value) != null) {
      // Ensure the parent receives the final value so data-level handlers
      // (like cache invalidation) run.
      widget.onChanged?.call(value);
      setState(() {
        _isEditing = false;
      });
    }
  }

  void _onChanged(String value) {
    final valid = widget.parser(value) != null;
    if (valid != _isValid) {
      setState(() {
        _isValid = valid;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _focusNode = .new();
    _isValid = widget.parser(widget.controller.text) != null;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.headlineLarge;

    return SizedBox(
      width: double.infinity,
      child: Center(
        child: _isEditing
            ? TextField(
                controller: widget.controller,
                textAlign: .center,
                style: textStyle,
                onSubmitted: _onSubmitted,
                onEditingComplete: () => _onSubmitted(widget.controller.text),
                textInputAction: .go,
                focusNode: _focusNode,
                onChanged: _onChanged,
                decoration: InputDecoration(
                  hintText: 'Note',
                  contentPadding: const .all(10),
                  filled: true,
                  fillColor: const Color(0xFFF6F8F8),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: .circular(10),
                    borderSide: BorderSide(
                      color: _isValid
                          ? Colors.blue.shade300
                          : Colors.red.shade300,
                      width: 1.2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: .circular(10),
                    borderSide: BorderSide(
                      color: _isValid ? Colors.blue : Colors.red,
                      width: 2,
                    ),
                  ),
                ),
              )
            : Material(
                color: Colors.transparent,
                borderRadius: const .all(.circular(20)),
                child: ClipRRect(
                  borderRadius: const .all(.circular(20)),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _isEditing = true;
                      });
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _focusNode.requestFocus();
                      });
                    },
                    child: Padding(
                      padding: const .only(
                        top: 7,
                        bottom: 8,
                        left: 8,
                        right: 8,
                      ),
                      child: Text(
                        _format(widget.controller.text),
                        style: textStyle,
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

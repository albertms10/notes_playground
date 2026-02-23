import 'package:flutter/material.dart';
import 'package:music_notes/music_notes.dart';

@immutable
class TextEditingNodeBody extends StatefulWidget {
  const TextEditingNodeBody({
    required this.controller,
    required this.onChanged,
    required this.displayText,
    required this.validateText,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String Function(String) displayText;
  final bool Function(String) validateText;

  @override
  State<TextEditingNodeBody> createState() => _TextEditingNodeBodyState();
}

class _TextEditingNodeBodyState extends State<TextEditingNodeBody> {
  bool _isEditing = false;
  late final FocusNode _focusNode;
  bool _isValid = true;

  void _onSubmitted(String value) {
    if (widget.validateText(value)) {
      // Ensure the parent receives the final value so data-level handlers
      // (like cache invalidation) run.
      widget.onChanged(value);
      setState(() {
        _isEditing = false;
      });
    }
  }

  void _onChanged(String value) {
    final valid = widget.validateText(value);
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
    _isValid = widget.validateText(widget.controller.text);
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
                        widget.displayText(widget.controller.text),
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

extension StringParserChain<V> on List<StringParser<V>> {
  /// Parses [source] from this chain of [StringParser]s.
  bool match(String source) {
    for (final parser in this) {
      if (parser.matches(source)) return true;
    }
    return false;
  }
}

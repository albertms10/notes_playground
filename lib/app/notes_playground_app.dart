import 'package:flutter/material.dart';
import 'package:notes_playground/features/canvas_editor/canvas_editor_page.dart';

class NotesPlaygroundApp extends StatelessWidget {
  const NotesPlaygroundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Infinite Functional Canvas',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: const Color(0xFF4C8A7F)),
        scaffoldBackgroundColor: const Color(0xFFF5F7F6),
      ),
      home: const CanvasEditorPage(),
    );
  }
}

import 'package:flutter/material.dart';

class FullScreenImageView extends StatelessWidget {
  final String imagePath;
  const FullScreenImageView({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context), // Tap anywhere to close
        child: Center(
          child: InteractiveViewer( // pinch zoom, drag
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

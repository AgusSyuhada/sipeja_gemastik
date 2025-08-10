import 'dart:io';
import 'package:flutter/material.dart';

class ImagePreviewDialog extends StatelessWidget {
  final File imageFile;

  const ImagePreviewDialog({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black.withOpacity(0.8),
      insetPadding: const EdgeInsets.all(16.0),
      elevation: 0,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.file(imageFile, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

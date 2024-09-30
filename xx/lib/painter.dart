import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FacePainter extends CustomPainter {
  final List<Face> faces;
  final Image image;
  final Size imageSize;

  FacePainter(this.faces, this.image, this.imageSize);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.red;

    final double widthScale = size.width / imageSize.width;
    final double heightScale = size.height / imageSize.height;

    for (var face in faces) {
      final rect = Rect.fromLTRB(
        face.boundingBox.left * widthScale,
        face.boundingBox.top * heightScale,
        face.boundingBox.right * widthScale,
        face.boundingBox.bottom * heightScale,
      );
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant FacePainter oldDelegate) {
    return oldDelegate.faces != faces || oldDelegate.image != image;
  }
}

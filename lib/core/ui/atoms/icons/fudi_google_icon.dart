import 'package:flutter/material.dart';

class FudiGoogleIcon extends StatelessWidget {
  const FudiGoogleIcon({this.size = 20, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: CustomPaint(
        painter: GoogleIconPainter(),
      ),
    );
  }
}

class GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    final paint4285F4 = Paint()..color = const Color(0xFF4285F4);
    final paint34A853 = Paint()..color = const Color(0xFF34A853);
    final paintFBBC05 = Paint()..color = const Color(0xFFFBBC05);
    final paintEA4335 = Paint()..color = const Color(0xFFEA4335);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      -0.15,
      1.83,
      false,
      paint4285F4,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      1.68,
      1.46,
      false,
      paint34A853,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      3.14,
      1.57,
      false,
      paintFBBC05,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      4.71,
      1.46,
      false,
      paintEA4335,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


import 'package:flutter/material.dart';

class HintTrianglePainter extends CustomPainter {

  final Color? color;

  HintTrianglePainter({this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color ?? Colors.black
      ..strokeWidth = 1.0
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width, 0.0)
      ..lineTo(0.0, 0.0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0.0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(HintTrianglePainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(HintTrianglePainter oldDelegate) => false;
}

class HintTriangleCell extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final Color? hintColor;
  final String? hintValue;

  const HintTriangleCell({
    super.key,
    required this.width,
    required this.height,
    required this.child,
    this.hintValue,
    this.hintColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: width,
          height: height,
          child: child,
        ),

        Positioned(
          top: 0,
          right: 0,
          child: Tooltip(
            message: hintValue ?? "",
            child: CustomPaint(
              size: const Size(10, 10),
              painter: HintTrianglePainter(color: hintColor),
            ),

          ),
        ),
      ],
    );
  }
}



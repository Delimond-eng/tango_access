import 'package:flutter/material.dart';

class TicketCard extends StatelessWidget {
  const TicketCard({
    super.key,
    this.height,
    this.width,
    required this.child,
    this.padding,
    this.margin,
    this.color = Colors.white,
    this.isCornerRounded = false,
    this.shadow,
  });

  final double? width;
  final double? height;
  final Widget child;
  final Color color;
  final bool isCornerRounded;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final List<BoxShadow>? shadow;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return ClipPath(
      clipper: TicketClipper(),
      child: AnimatedContainer(
        duration: const Duration(seconds: 1),
        width: width ?? size.width,
        height: height ?? size.height,
        padding: padding,
        margin: margin,
        decoration: BoxDecoration(
          boxShadow: shadow,
          color: color,
          borderRadius: isCornerRounded
              ? BorderRadius.circular(5.0)
              : BorderRadius.circular(0.0),
        ),
        child: child,
      ),
    );
  }
}

class TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0.0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0.0);
    path.addOval(
      Rect.fromCircle(center: Offset(0.0, size.height - 80), radius: 8.0),
    );
    path.addOval(
      Rect.fromCircle(
          center: Offset(size.width, size.height - 80), radius: 8.0),
    );
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

import 'package:flutter/material.dart';

class SkeletonLogo extends StatelessWidget {
  final double size;
  final Color? color;

  const SkeletonLogo({
    super.key,
    this.size = 100,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (color ?? Colors.pink).withValues(alpha: 0.12),
            blurRadius: 15,
            spreadRadius: 1,
          )
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/skeleton_logo.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

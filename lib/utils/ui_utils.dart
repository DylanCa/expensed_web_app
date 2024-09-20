import 'package:flutter/material.dart';

Widget buildElevatedContainer({
  required Widget child,
  double borderRadius = 20,
  Color? backgroundColor,
}) {
  return Container(
    decoration: BoxDecoration(
      color: backgroundColor ?? Colors.white.withAlpha(200),
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 10,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: child,
    ),
  );
}

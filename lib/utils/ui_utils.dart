import 'package:flutter/material.dart';

Widget buildElevatedContainer({
  required Widget child,
  double borderRadius = 20,
  Color? backgroundColor,
}) {
  return Container(
    decoration: BoxDecoration(
      color: backgroundColor ?? Colors.white,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 5,
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

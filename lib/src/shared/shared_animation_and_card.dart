// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

Widget modernCard({required Widget child}) {
  return Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(22),
      color: Colors.white.withOpacity(0.95),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: child,
  );
}

Widget animatedEntry({required Widget child}) {
  return TweenAnimationBuilder(
    duration: const Duration(milliseconds: 650),
    tween: Tween<double>(begin: 0.0, end: 1.0),
    curve: Curves.easeOutCubic,
    builder: (context, value, _) {
      return Transform.translate(
        offset: Offset(0, 30 * (1 - value)),
        child: Opacity(opacity: value, child: child),
      );
    },
  );
}

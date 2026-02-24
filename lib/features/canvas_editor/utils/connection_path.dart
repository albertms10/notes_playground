import 'dart:ui';

Path buildPath(Offset from, Offset to) {
  final dx = (to.dx - from.dx).abs();
  final curvature = 40 + dx * 0.42;
  final c1 = from + Offset(curvature, 0);
  final c2 = to - Offset(curvature, 0);

  return Path()
    ..moveTo(from.dx, from.dy)
    ..cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, to.dx, to.dy);
}

bool pointNearPath(Path path, Offset point, {required double tolerance}) {
  final metrics = path.computeMetrics();
  for (final metric in metrics) {
    final length = metric.length;
    const step = 8.0;
    for (double distance = 0; distance <= length; distance += step) {
      final tangent = metric.getTangentForOffset(distance);
      if (tangent == null) continue;
      if ((tangent.position - point).distance <= tolerance) return true;
    }
  }

  return false;
}

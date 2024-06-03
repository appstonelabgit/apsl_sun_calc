import 'dart:math' as math;

import './constants.dart';

num julianCycle(d, lw) {
  return (d - j0 - lw / (2 * pi)).round();
}

num approxTransit(ht, lw, n) {
  return j0 + (ht + lw) / (2 * pi) + n;
}

num solarTransitJ(ds, M, L) {
  return j2000 + ds + 0.0053 * math.sin(M) - 0.0069 * math.sin(2 * L);
}

num hourAngle(h, phi, d) {
  num angle = (math.sin(h) - math.sin(phi) * math.sin(d)) /
      (math.cos(phi) * math.cos(d));
  if (angle < -1) angle = -1;
  if (angle > 1) angle = 1;

  return math.acos(angle);
}

num getSetJ(h, lw, phi, dec, n, M, L) {
  var w = hourAngle(h, phi, dec);
  var a = approxTransit(w, lw, n);

  return solarTransitJ(a, M, L);
}

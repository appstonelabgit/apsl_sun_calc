import 'dart:math' as math;

import './constants.dart';

num rightAscension(num l, num b) {
  return math.atan2(
      math.sin(l) * math.cos(e) - math.tan(b) * math.sin(e), math.cos(l));
}

num declination(num l, num b) {
  return math.asin(
      math.sin(b) * math.cos(e) + math.cos(b) * math.sin(e) * math.sin(l));
}

num azimuth(num h, num phi, num dec) {
  return math.atan2(
      math.sin(h), math.cos(h) * math.sin(phi) - math.tan(dec) * math.cos(phi));
}

num altitude(num H, num phi, num dec) {
  return math.asin(math.sin(phi) * math.sin(dec) +
      math.cos(phi) * math.cos(dec) * math.cos(H));
}

num siderealTime(num d, num lw) {
  return rad * (280.16 + 360.9856235 * d) - lw;
}

num astroRefraction(num h) {
  if (h < 0) {
    // the following formula works for positive altitudes only.
    h = 0; // if h = -0.08901179 a div/0 would occur.
  }
  // formula 16.4 of "Astronomical Algorithms" 2nd edition by Jean Meeus (Willmann-Bell, Richmond) 1998.
  // 1.02 / tan(h + 10.26 / (h + 5.10)) h in degrees, result in arc minutes -> converted to rad:
  return 0.0002967 / math.tan(h + 0.00312536 / (h + 0.08901179));
}

import 'dart:math' as math;

import './constants.dart';
import './position_utils.dart';

num solarMeanAnomaly(num d) {
  return rad * (357.5291 + 0.98560028 * d);
}

num equationOfCenter(num M) {
  var firstFactor = 1.9148 * math.sin(M);
  var secondFactor = 0.02 * math.sin(2 * M);
  var thirdFactor = 0.0003 * math.sin(3 * M);

  return rad * (firstFactor + secondFactor + thirdFactor);
}

num eclipticLongitude(num M) {
  var C = equationOfCenter(M);
  var P = rad * 102.9372; // perihelion of the Earth

  return M + C + P + pi;
}

Map<String, num> sunCoords(num d) {
  var M = solarMeanAnomaly(d);
  var L = eclipticLongitude(M);

  return {"dec": declination(L, 0), "ra": rightAscension(L, 0)};
}

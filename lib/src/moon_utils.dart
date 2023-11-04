import './constants.dart';
import './position_utils.dart';
import 'dart:math' as math;

Map<String, num> moonCoords(num d) {
  var L = rad * (218.316 + 13.176396 * d);
  var M = rad * (134.963 + 13.064993 * d);
  var F = rad * (93.272 + 13.229350 * d);

  var l = L + rad * 6.289 * math.sin(M);
  var b = rad * 5.128 * math.sin(F);
  var dt = 385001 - 20905 * math.cos(M);

  return {"ra": rightAscension(l, b), "dec": declination(l, b), "dist": dt};
}

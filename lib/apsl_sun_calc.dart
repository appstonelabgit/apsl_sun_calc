library flutter_suncalc;

import 'dart:math' as math;

import 'src/constants.dart';

final julianEpoch = DateTime.utc(-4713, 11, 24, 12, 0, 0);

num toJulian(DateTime date) {
  return date.difference(julianEpoch).inSeconds / Duration.secondsPerDay;
}

DateTime fromJulian(num j) {
  return julianEpoch
      .add(Duration(milliseconds: (j * Duration.millisecondsPerDay).floor()));
}

num toDays(DateTime date) {
  return toJulian(date) - j2000;
}

// general calculations for position
num rightAscension(num l, num b) {
  return math.atan2(
      math.sin(l) * math.cos(e) - math.tan(b) * math.sin(e), math.cos(l));
}

num declination(num l, num b) {
  return math.asin(
      math.sin(b) * math.cos(e) + math.cos(b) * math.sin(e) * math.sin(l));
}

num azimuth(num H, num phi, num dec) {
  return math.atan2(
      math.sin(H), math.cos(H) * math.sin(phi) - math.tan(dec) * math.cos(phi));
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

// general sun calculations
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

// calculations for sun times
var times = [
  [-0.833, 'sunrise', 'sunset'],
  [-0.3, 'sunriseEnd', 'sunsetStart'],
  [-6, 'dawn', 'dusk'],
  [-12, 'nauticalDawn', 'nauticalDusk'],
  [-18, 'nightEnd', 'night'],
  [6, 'goldenHourEnd', 'goldenHour']
];

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
  return math.acos((math.sin(h) - math.sin(phi) * math.sin(d)) /
      (math.cos(phi) * math.cos(d)));
}

num getSetJ(h, lw, phi, dec, n, M, L) {
  var w = hourAngle(h, phi, dec);
  var a = approxTransit(w, lw, n);

  return solarTransitJ(a, M, L);
}

DateTime hoursLater(DateTime date, num h) {
  var ms = h * 60 * 60 * 1000;
  return date.add(Duration(milliseconds: ms.toInt()));
}

// moon calculations, based on http://aa.quae.nl/en/reken/hemelpositie.html formulas
Map<String, num> moonCoords(num d) {
  var L = rad * (218.316 + 13.176396 * d);
  var M = rad * (134.963 + 13.064993 * d);
  var F = rad * (93.272 + 13.229350 * d);

  var l = L + rad * 6.289 * math.sin(M);
  var b = rad * 5.128 * math.sin(F);
  var dt = 385001 - 20905 * math.cos(M);

  return {"ra": rightAscension(l, b), "dec": declination(l, b), "dist": dt};
}

class SunCalc {
  static void addTime(num angle, String riseName, String setName) {
    times.add([angle, riseName, setName]);
  }

  // calculates sun position for a given date and latitude/longitude
  static Map<String, num> getPosition(DateTime date, num lat, num lng) {
    var lw = rad * -lng;
    var phi = rad * lat;
    var d = toDays(date);

    var c = sunCoords(d);
    var H = siderealTime(d, lw) - (c["ra"] ?? 0.0);

    return {
      "azimuth": azimuth(H, phi, (c["dec"] ?? 0.0)),
      "altitude": altitude(H, phi, (c["dec"] ?? 0.0))
    };
  }

  static Map<String, num> getSunPosition(DateTime date, num lat, num lng) {
    return SunCalc.getPosition(date, lat, lng);
  }

  static Map<String, DateTime> getTimes(DateTime date, num lat, num lng) {
    var lw = rad * -lng;
    var phi = rad * lat;

    var d = toDays(date);
    var n = julianCycle(d, lw);
    var ds = approxTransit(0, lw, n);

    var M = solarMeanAnomaly(ds);
    var L = eclipticLongitude(M);
    var dec = declination(L, 0);

    var jnoon = solarTransitJ(ds, M, L);
    dynamic time, jset, jrise;
    int i;

    var result = {
      "solarNoon": fromJulian(jnoon),
      "nadir": fromJulian(jnoon - 0.5)
    };

    for (i = 0; i < times.length; i += 1) {
      time = times[i];

      jset = getSetJ(time[0] * rad, lw, phi, dec, n, M, L);
      jrise = jnoon - (jset - jnoon);

      result[time[1]] = fromJulian(jrise);
      result[time[2]] = fromJulian(jset);
    }

    return result;
  }

  static Map<String, num> getMoonPosition(DateTime date, num lat, num lng) {
    var lw = rad * -lng;
    var phi = rad * lat;
    var d = toDays(date);

    var c = moonCoords(d);
    var H = siderealTime(d, lw) - (c["ra"] ?? 0.0);
    var h = altitude(H, phi, (c["dec"] ?? 0.0));
    // formula 14.1 of "Astronomical Algorithms" 2nd edition by Jean Meeus (Willmann-Bell, Richmond) 1998.
    var pa = math.atan2(
      math.sin(H),
      math.tan(phi) * math.cos(c["dec"] ?? 0.0) -
          math.sin(c["dec"] ?? 0.0) * math.cos(H),
    );

    h = h + astroRefraction(h); // altitude correction for refraction

    return {
      "azimuth": azimuth(H, phi, (c["dec"] ?? 0.0)),
      "altitude": h,
      "distance": c["dist"] ?? 0.0,
      "parallacticAngle": pa
    };
  }

  static Map<String, num> getMoonIllumination(DateTime date) {
    var d = toDays(date);
    var s = sunCoords(d);
    var m = moonCoords(d);

    var sdist = 149598000; // distance from Earth to Sun in km

    var phi = math.acos(math.sin(s["dec"] ?? 0.0) * math.sin(m["dec"] ?? 0.0) +
        math.cos(s["dec"] ?? 0.0) *
            math.cos(m["dec"] ?? 0.0) *
            math.cos((s["ra"] ?? 0) - (m["ra"] ?? 0.0)));
    var inc = math.atan2(
        sdist * math.sin(phi), (m["dist"] ?? 0.0) - sdist * math.cos(phi));
    var angle = math.atan2(
        math.cos(s["dec"] ?? 0.0) *
            math.sin((s["ra"] ?? 0.0) - (m["ra"] ?? 0.0)),
        math.sin(s["dec"] ?? 0.0) * math.cos(m["dec"] ?? 0.0) -
            math.cos(s["dec"] ?? 0.0) *
                math.sin(m["dec"] ?? 0.0) *
                math.cos((s["ra"] ?? 0.0) - (m["ra"] ?? 0.0)));

    return {
      "fraction": (1 + math.cos(inc)) / 2,
      "phase": 0.5 + 0.5 * inc * (angle < 0 ? -1 : 1) / pi,
      "angle": angle
    };
  }

  static Map getMoonTimes(DateTime date, num lat, num lng,
      [bool inUtc = true]) {
    var t = DateTime(date.year, date.month, date.day, 0, 0, 0);
    if (inUtc) {
      t = DateTime.utc(date.year, date.month, date.day, 0, 0, 0);
    }
    const hc = 0.133 * rad;
    var h0 = (SunCalc.getMoonPosition(t, lat, lng)["altitude"] ?? 0.0) - hc;
    var h1 = 0.0;
    var h2 = 0.0;
    var rise = 0.0;
    var set = 0.0;
    var a = 0.0;
    var b = 0.0;
    var xe = 0.0;
    var ye = 0.0;
    var d = 0.0;
    var roots = 0.0;
    var x1 = 0.0;
    var x2 = 0.0;
    var dx = 0.0;

    // go in 2-hour chunks, each time seeing if a 3-point quadratic curve crosses zero (which means rise or set)
    for (var i = 1; i <= 24; i += 2) {
      h1 = (SunCalc.getMoonPosition(hoursLater(t, i), lat, lng)["altitude"] ??
              0) -
          hc;
      h2 = (SunCalc.getMoonPosition(
                  hoursLater(t, i + 1), lat, lng)["altitude"] ??
              0) -
          hc;

      a = (h0 + h2) / 2 - h1;
      b = (h2 - h0) / 2;
      xe = -b / (2 * a);
      ye = (a * xe + b) * xe + h1;
      d = b * b - 4 * a * h1;
      roots = 0;

      if (d >= 0) {
        dx = math.sqrt(d) / (a.abs() * 2);
        x1 = xe - dx;
        x2 = xe + dx;
        if (x1.abs() <= 1) roots++;
        if (x2.abs() <= 1) roots++;
        if (x1 < -1) x1 = x2;
      }

      if (roots == 1) {
        if (h0 < 0) {
          rise = i + x1;
        } else {
          set = i + x1;
        }
      } else if (roots == 2) {
        rise = i + (ye < 0 ? x2 : x1);
        set = i + (ye < 0 ? x1 : x2);
      }

      if ((rise != 0) && (set != 0)) {
        break;
      }

      h0 = h2;
    }

    var result = {};
    result["alwaysUp"] = false;
    result["alwaysDown"] = false;

    if (rise != 0) {
      result["rise"] = hoursLater(t, rise);
    }
    if (set != 0) {
      result["set"] = hoursLater(t, set);
    }

    if ((rise == 0) && (set == 0)) {
      result[ye > 0 ? "alwaysUp" : "alwaysDown"] = true;
    }

    return result;
  }
}

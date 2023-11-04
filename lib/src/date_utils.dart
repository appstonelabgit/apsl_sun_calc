import './constants.dart';

num toJulian(DateTime date) {
  return date.millisecondsSinceEpoch / dayMs - 0.5 + j1970;
}

DateTime fromJulian(num j) {
  return DateTime.fromMillisecondsSinceEpoch(
      ((j + 0.5 - 1970) * dayMs).round());
}

num toDays(DateTime date) {
  return toJulian(date) - j2000;
}

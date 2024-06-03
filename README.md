# Apsl Sun Calc

`apsl_sun_calc` is a Flutter package for calculating the position and phase of the sun and moon, based on a given date and geographic location. This Dart package is inspired by the `suncalc` JavaScript library.

## Features

- **Sun Position**: Calculate the sun's position with azimuth and altitude.
- **Moon Position**: Determine the moon's position with azimuth, altitude, and distance.
- **Sun Times**: Get various sunlight phases (dawn, dusk, golden hour, etc.).
- **Moon Illumination**: Calculate the fraction of the moon illuminated, its phase, and angle.
- **Flutter Support**: Compatible with Flutter for both mobile and web platforms.

## Prerequisites

Before you begin, ensure you have met the following requirements:

- Flutter SDK
- Dart SDK

## Installation

Add `flutter_suncalc` to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter_suncalc: ^0.0.1
```

Then, run the following command to install the package:
```dart
flutter pub get
```

## Usage

Import the package in your Dart code:

```dart
import 'package:flutter_suncalc/flutter_suncalc.dart';
```

## Examples

Sun Position

```dart
var sunPosition = SunCalc.getSunPosition(DateTime.now(), latitude, longitude);
// Output the sun's position
```

Moon Position

```dart
var moonPosition = SunCalc.getMoonPosition(DateTime.now(), latitude, longitude);
// Output the moon's position
```

## Acknowledgments

Thanks to the original [suncalc](https://github.com/mourner/suncalc) JavaScript library authors.

## License

Distributed under the MIT License. See LICENSE for more information.


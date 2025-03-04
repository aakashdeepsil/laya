import 'dart:math';

import 'package:flutter/material.dart';

class ShakeCurve extends Curve {
  @override
  double transform(double t) {
    return sin(t * pi * 5);
  }
}

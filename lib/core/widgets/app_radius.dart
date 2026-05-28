import 'package:flutter/material.dart';

class AppRadius {
  // values
  static const double r4 = 4;
  static const double r8 = 8;
  static const double r12 = 12;
  static const double r16 = 16;
  static const double r20 = 20;
  static const double r24 = 24;
  static const double r32 = 32;
  static const double r40 = 40;
  static const double r48 = 48;

  // predefined border radius
  static const br4 = BorderRadius.all(Radius.circular(r4));
  static const br8 = BorderRadius.all(Radius.circular(r8));
  static const br12 = BorderRadius.all(Radius.circular(r12));
  static const br16 = BorderRadius.all(Radius.circular(r16));
  static const br20 = BorderRadius.all(Radius.circular(r20));
  static const br24 = BorderRadius.all(Radius.circular(r24));
  static const br32 = BorderRadius.all(Radius.circular(r32));
  static const br40 = BorderRadius.all(Radius.circular(r40));
  static const br48 = BorderRadius.all(Radius.circular(r48));

  // full rounded
  static final full = BorderRadius.circular(double.infinity);

  // flexible
  static BorderRadius all(double value) =>
      BorderRadius.all(Radius.circular(value));

  static BorderRadius only({
    double topLeft = 0,
    double topRight = 0,
    double bottomLeft = 0,
    double bottomRight = 0,
  }) {
    return BorderRadius.only(
      topLeft: Radius.circular(topLeft),
      topRight: Radius.circular(topRight),
      bottomLeft: Radius.circular(bottomLeft),
      bottomRight: Radius.circular(bottomRight),
    );
  }
}

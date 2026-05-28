import 'package:flutter/material.dart';

class AppSpacing {
  // base values
  static const double x4 = 4;
  static const double x8 = 8;
  static const double x12 = 12;
  static const double x16 = 16;
  static const double x20 = 20;
  static const double x24 = 24;
  static const double x32 = 32;
  static const double x40 = 40;
  static const double x48 = 48;

  // predefined sized boxes for vertical spacing
  static const v4 = SizedBox(height: x4);
  static const v8 = SizedBox(height: x8);
  static const v12 = SizedBox(height: x12);
  static const v16 = SizedBox(height: x16);
  static const v20 = SizedBox(height: x20);
  static const v24 = SizedBox(height: x24);
  static const v32 = SizedBox(height: x32);
  static const v40 = SizedBox(height: x40);
  static const v48 = SizedBox(height: x48);

  // predefined sized boxes for horizontal spacing
  static const h4 = SizedBox(width: x4);
  static const h8 = SizedBox(width: x8);
  static const h12 = SizedBox(width: x12);
  static const h16 = SizedBox(width: x16);
  static const h20 = SizedBox(width: x20);
  static const h24 = SizedBox(width: x24);
  static const h32 = SizedBox(width: x32);
  static const h40 = SizedBox(width: x40);
  static const h48 = SizedBox(width: x48);

  // flexible
  static SizedBox v(double value) => SizedBox(height: value);
  static SizedBox h(double value) => SizedBox(width: value);
}
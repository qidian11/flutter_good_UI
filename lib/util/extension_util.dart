import 'dart:math';
import 'package:quantity/quantity.dart';
import 'package:decimal/decimal.dart';

extension RandomExtension on Random {
  double rangeDouble(double min, double max) {
    double res = min + Random().nextDouble() * (max - min);
    res = res > max ? max : res;
    // return res.round().toDouble();
    return res;
  }

  int rangeInt(int min, int max) => min + Random().nextInt(max - min);
}

extension PreciseExtension on Precise {
  Precise get square => (this * this);
}

extension DoubleExtension on double {
  double get square => this * this;
  // double get square =>
  //     (Decimal.parse(this.toString()) * Decimal.parse(this.toString()))
  //         .toDouble();
  // double get round5 =>
  //     Decimal.parse(this.toString()).round(scale: 5).toDouble();
  // double plus(num num) =>
  //     (Decimal.parse(this.toString()) + Decimal.parse(num.toString()))
  //         .toDouble();
  // double minus(num num) =>
  //     (Decimal.parse(this.toString()) - Decimal.parse(num.toString()))
  //         .toDouble();
  // double times(num num) =>
  //     (Decimal.parse(this.toString()) * Decimal.parse(num.toString()))
  //         .toDouble();
  // double divide(num num) =>
  //     (Decimal.parse(this.toString()) / Decimal.parse(num.toString()))
  //         .toDouble();
  double get sign => this < 0 ? -1 : 1;
}

extension IntExtension on int {
  int get square => this * this;

  // double times(num num) =>
  //     (Decimal.parse(this.toString()) * Decimal.parse(num.toString()))
  //         .toDouble();

  // double divide(num num) =>
  //     (Decimal.parse(this.toString()) / Decimal.parse(num.toString()))
  //         .toDouble();
  double get sign => this / (this.abs());
}

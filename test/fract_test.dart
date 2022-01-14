import 'package:test/test.dart';
import 'package:clc/fract.dart';
import 'dart:math';

void main() {
  test("fromString", () {
    var s = "12345/23456";
    var v = Fraction.fromString(s);
    expect(v.toString(), equals("12345/23456"));
  });
  test("fromString 1.3", () {
    var s = "1.3";
    var v = Fraction.fromString(s);
    expect(v.toString(), equals("13/10"));
  });
  test("fromString 3.14159", () {
    var s = "3.14159";
    var v = Fraction.fromString(s);
    expect(v.toString(), equals("314159/100000"));
    expect(v.toExpr(), equals("\\frac{314159}{100000}"));
    expect(v.toExpr2(), equals("3\\frac{14159}{100000}"));
  });
  test("fromString(float)", () {
    var s = "12345.67/23456.78";
    var v = Fraction.fromString(s);
    expect(v.toString(), equals("1234567/2345678"));
  });

  test("fromBigInt", () {
    var s = BigInt.from(123456);
    var v = Fraction.fromBigInt(s);
    expect(v.toString(), equals("123456"));
  });

  test("fromInt", () {
    var s = 123456;
    var v = Fraction.fromInt(s);
    expect(v.toString(), equals("123456"));
  });

  test("fromDouble2_1", () {
    var s = 123456.789;
    var v = Fraction.fromDouble2(s);
    expect(v.toString(), equals("123456789/1000"));
  });

  test("fromDouble2_2", () {
    var s = 123456.789;
    var v = Fraction.fromDouble2(s);
    expect(v.toString2(), equals("123456+789/1000"));
  });

  test("fromDouble2_3", () {
    var s = 123456.780;
    var v = Fraction.fromDouble2(s);
    expect(v.toString(), equals("6172839/50"));
    expect(v.toDouble().toString(), "123456.78");
  });

  test("+-/*", () {
    var s1 = Fraction.fromString("1/2");
    var s2 = Fraction.fromString("3/4");
    expect((s1 + s2).toString(), equals("5/4"));
    expect((s1 - s2).toString(), equals("-1/4"));
    expect((s2 - s1).toString(), equals("1/4"));
    expect((s1 * s2).toString(), equals("3/8"));
    expect((s1 / s2).toString(), equals("2/3"));
    expect((s2 / s1).toString(), equals("3/2"));
  });

  test("-", () {
    var s1 = Fraction.fromString("1/2");
    var s2 = Fraction.fromString("3/4");
    expect((-s1).toString(), equals("-1/2"));
    expect((-s2).toString(), equals("-3/4"));
    expect((-(s1 - s2)).toString(), equals("1/4"));
  });

  test("compare", () {
    var s1 = Fraction.fromString("3/4");
    var s2 = Fraction.fromString("4/5");
    expect(s1 < s2, true);
    expect(s1 + Fraction.fromString("1/8") > s2, true);
    expect(s1, equals(Fraction(BigInt.from(3), BigInt.from(4))));
  });

  test("shift", () {
    var s1 = Fraction.fromString("1/4");
    expect(s1 << 1, equals(Fraction.fromString("1/2")));
    expect(s1 << 2, equals(Fraction.fromString("1")));
    expect(s1 >> 1, equals(Fraction.fromString("1/8")));
    expect(s1 >> 2, equals(Fraction.fromString("1/16")));
  });

  test("sqrt", () {
    var s1 = Fraction.fromString("100/33");
    expect(s1.sqrt().toDouble().toString().substring(0, 10),
        equals(sqrt(100.0 / 33).toString().substring(0, 10)));
  });

  test("log2", () {
    var s1 = Fraction.fromString("100");
    expect(s1.log2().toDouble().toString().substring(0, 5),
        equals((log(100) / ln2).toString().substring(0, 5)));
  });

  test("fromDouble 1.1", () {
    var s1 = Fraction.fromDouble(1.1);
    expect(s1, equals(Fraction(BigInt.from(11), BigInt.from(10))));
  });
  test("fromDouble pi", () {
    var s1 = Fraction.fromDouble(pi);
    expect((pi - s1.toDouble()).abs(), lessThan(1e-9));
  });

  test("fromDouble e", () {
    var s1 = Fraction.fromDouble(e);
    expect((e - s1.toDouble()).abs(), lessThan(1e-9));
  });
}

import 'dart:math' as math;
import 'package:logger/logger.dart';

var _log = Logger(
  printer: SimplePrinter(printTime: true),
);

enum ExprStyle {
  normalStyle,
  textStyle,
  displayStyle,
}

class Fraction extends Comparable<Fraction> {
  BigInt num, den;
  Fraction(this.num, this.den);

  static Fraction pi = fromDouble(math.pi);
  static Fraction e = fromDouble(math.e);

  static Fraction _fromDoubleSub(List<BigInt> v) {
    Fraction res = Fraction(BigInt.one, BigInt.one);
    for (var vv in v.reversed) {
      res = res.inv() + Fraction(vv, BigInt.one);
    }
    res.fix();
    return res;
  }

  static Fraction fromDouble(double v, {double precision = 1e-9}) {
    var cur = v;
    List<BigInt> stk = [];
    while (true) {
      var flr = BigInt.from(cur);
      _log.d("$v -> cur=$cur, flr=$flr");
      stk.add(flr);
      cur -= flr.toDouble();
      cur = 1 / cur;
      var res = _fromDoubleSub(stk);
      _log.d("test $v =?= $res");
      if ((res.toDouble() - v).abs() < precision) {
        _log.d("result: $res");
        return res;
      }
    }
  }

  static Fraction fromDouble2(double v, {double precision = 1e-12}) {
    var ret = Fraction(BigInt.from(v / precision), BigInt.from(1 / precision));
    ret.fix();
    return ret;
  }

  static Fraction fromBigInt(BigInt v) {
    return Fraction(v, BigInt.one);
  }

  static Fraction fromInt(int v) {
    return Fraction(BigInt.from(v), BigInt.one);
  }

  static Fraction _fromString(String s) {
    var idx = s.indexOf(".");
    if (idx == -1) {
      return Fraction(BigInt.parse(s), BigInt.one);
    }
    var n1 = BigInt.parse(s.substring(0, idx) + s.substring(idx + 1));
    var l = (s.length - idx) - 1;
    var n2 = BigInt.parse("1" + "0" * l);
    var ret = Fraction(n1, n2);
    ret.fix();
    return ret;
  }

  static Fraction fromString(String s) {
    var idx = s.indexOf("/");
    if (idx == -1) {
      return _fromString(s);
    }
    var x1 = _fromString(s.substring(0, idx));
    var x2 = _fromString(s.substring(idx + 1));
    return x1 / x2;
  }

  void fix() {
    var n = num.gcd(den);
    if (n != BigInt.one) {
      num ~/= n;
      den ~/= n;
    }
    if (den.sign < 0) {
      den = -den;
      num = -num;
    }
  }

  bool isNegative() {
    return num.isNegative ^ den.isNegative;
  }

  Fraction abs() {
    return Fraction(num.abs(), den.abs());
  }

  double toDouble() {
    return num / den;
  }

  BigInt toBigInt() {
    return num ~/ den;
  }

  @override
  String toString() {
    fix();
    if (den == BigInt.one) {
      return num.toString();
    } else {
      return "$num/$den";
    }
  }

  String toString2() {
    fix();
    BigInt n1 = num ~/ den;
    BigInt n2 = (num % den).abs();
    if (n2 == BigInt.zero) {
      return "$n1";
    } else {
      return "$n1+$n2/$den";
    }
  }

  Map<ExprStyle, String> stylemap = {
    ExprStyle.normalStyle: "frac",
    ExprStyle.textStyle: "tfrac",
    ExprStyle.displayStyle: "dfrac",
  };

  String toExpr([ExprStyle style = ExprStyle.normalStyle]) {
    fix();
    if (den == BigInt.one) {
      return num.toString();
    } else {
      var s = stylemap[style]!;
      return "\\$s{$num}{$den}";
    }
  }

  String toExpr2([ExprStyle style = ExprStyle.normalStyle]) {
    fix();
    BigInt n1 = num ~/ den;
    BigInt n2 = (num % den).abs();
    if (n1 == BigInt.zero) {
      return toExpr(style);
    } else if (n2 == BigInt.zero) {
      return "$n1";
    } else {
      var s = stylemap[style]!;
      return "$n1\\$s{$n2}{$den}";
    }
  }

  @override
  int compareTo(Fraction other) {
    fix();
    other.fix();
    _log.d("compareTo: $this $other");
    if (other.num == num && other.den == den) {
      return 0;
    }
    if ((num / den) < (other.num / other.den)) {
      return -1;
    }
    return 1;
  }

  Fraction operator %(Fraction other) {
    BigInt n = den.gcd(other.den);
    BigInt n1 = other.den ~/ n;
    BigInt n2 = den ~/ n;
    var ret = Fraction(num * n1, den * n1);
    ret.num %= other.num * n2;
    return ret;
  }

  Fraction operator *(Fraction other) {
    return Fraction(num * other.num, den * other.den);
  }

  Fraction square() {
    return Fraction(num * num, den * den);
  }

  Fraction operator +(Fraction other) {
    BigInt n = den.gcd(other.den);
    BigInt n1 = other.den ~/ n;
    BigInt n2 = den ~/ n;
    var ret = Fraction(num * n1, den * n1);
    ret.num += other.num * n2;
    return ret;
  }

  Fraction operator -(Fraction other) {
    BigInt n = den.gcd(other.den);
    BigInt n1 = other.den ~/ n;
    BigInt n2 = den ~/ n;
    var ret = Fraction(num * n1, den * n1);
    ret.num -= other.num * n2;
    return ret;
  }

  Fraction operator /(Fraction other) {
    var ret = Fraction(num * other.den, den * other.num);
    return ret;
  }

  bool operator <(Fraction other) {
    BigInt n = den.gcd(other.den);
    BigInt n1 = other.den ~/ n;
    BigInt n2 = den ~/ n;
    return (num * n1) < (other.num * n2);
  }

  bool operator <=(Fraction other) {
    BigInt n = den.gcd(other.den);
    BigInt n1 = other.den ~/ n;
    BigInt n2 = den ~/ n;
    return (num * n1) <= (other.num * n2);
  }

  bool operator >=(Fraction other) {
    BigInt n = den.gcd(other.den);
    BigInt n1 = other.den ~/ n;
    BigInt n2 = den ~/ n;
    return (num * n1) >= (other.num * n2);
  }

  bool operator >(Fraction other) {
    BigInt n = den.gcd(other.den);
    BigInt n1 = other.den ~/ n;
    BigInt n2 = den ~/ n;
    return (num * n1) > (other.num * n2);
  }

  @override
  int get hashCode => num.hashCode ^ den.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is Fraction) {
      fix();
      other.fix();
      return num == other.num && den == other.den;
    } else if (other is BigInt) {
      fix();
      return num == other && den == BigInt.one;
    } else if (other is int) {
      fix();
      return num.toInt() == other && den == BigInt.one;
    } else if (other is double) {
      return toDouble() == other;
    }
    return false;
  }

  Fraction operator <<(int n) {
    return Fraction(num << n, den);
  }

  Fraction operator >>(int n) {
    return Fraction(num, den << n);
  }

  Fraction operator -() {
    return Fraction(-num, den);
  }

  Fraction log() {
    return Fraction.fromDouble(math.log(toDouble()));
  }

  Fraction log2() {
    return log() / Fraction.fromDouble(math.ln2);
  }

  Fraction log10() {
    return log() / Fraction.fromDouble(math.ln10);
  }

  Fraction logN(double n) {
    // returns log_n(this)
    return log() / fromDouble(math.log(n));
  }

  Fraction log2slow([double precision = 1e-10]) {
    // returns log_2(this)
    var res = Fraction(BigInt.from(0), BigInt.one);
    var x = Fraction(num, den);
    var one = Fraction(BigInt.one, BigInt.one);
    var two = Fraction(BigInt.two, BigInt.one);
    // int part
    while (x < one) {
      res -= one;
      x <<= 1;
    }
    while (x >= two) {
      res += one;
      x >>= 1;
    }
    // float part
    var fp = Fraction(BigInt.one, BigInt.one);
    var prec = Fraction.fromDouble(precision);
    while (fp.den <= prec.den) {
      fp >>= 1;
      x = x.square();
      if (x.num ~/ x.den >= BigInt.two) {
        x >>= 1;
        res += fp;
      }
    }
    return res;
  }

  Fraction pow(Fraction other) {
    // returns this ** other
    return fromDouble(math.pow(toDouble(), other.toDouble()).toDouble());
  }

  Fraction sqrt([double precision = 1e-10]) {
    // returns sqrt(this)
    // simple sqrt algo
    _log.d("sqrt $this");
    var prec = fromDouble(precision);
    var r = Fraction(num, den);
    while ((this - r * r).abs() > prec) {
      r = (r + this / r);
      r.den *= BigInt.from(2);
    }
    _log.d("result $r");
    return r;
  }

  Fraction exp() {
    // returns e ** this
    return e.pow(this);
  }

  Fraction inv() {
    return Fraction(den, num);
  }
}

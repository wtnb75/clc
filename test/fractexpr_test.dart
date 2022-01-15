import 'package:test/test.dart';
import 'package:clc/fract.dart';
import 'package:clc/fractexpr.dart';

void main() {
  FractRpn fr = FractRpn();

  Map<String, String> evalmap = {
    "1+1/2": "3/2",
    "(1/2+1/3)/(1/4+1/5)": "50/27",
    "-12": "-12",
    "+1+2+(-3)": "0",
    "!10": "3628800",
    "1/2<<1": "1",
    "1/2>>2": "1/8",
    "(1/2)*(1/2)": "1/4",
    "(1/2)-(1/2)": "0",
  };

  evalmap.forEach((String k, String v) {
    test("eval $k", () {
      var r = fr.eval(k)!;
      expect(r.toString(), equals(v));
    });
  });

  Map<String, String> expmap = {
    "1 1 +": "1 + 1",
    "1 2 /": r"\frac{1}{2}",
    "2 log": r"\log 2",
    "10 2 + S!": r"(10 + 2)!",
  };

  expmap.forEach((String k, String v) {
    test("exp $k", () {
      fr.fromString(k, " ");
      expect(fr.toExpr(), equals(v));
    });
  });
}

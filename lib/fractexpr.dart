import 'dart:math';
import 'package:clc/fract.dart';
import 'package:clc/rpn.dart';

class FractRpn extends RPN<Fraction> {
  RegExp numberExp = RegExp(r"[0-9]+(\.[0-9]+)?(e[\+\-])?[0-9]*");
  RegExp funcExp = RegExp(r"[a-zA-Z][a-zA-Z0-9]*");
  Map<String, Fraction> constants = {
    "pi": Fraction.fromDouble(pi),
    "e": Fraction.fromDouble(e),
  };

  @override
  void exec1(String v) {
    Set<String> ary1 = {
      "S-",
      "S+",
      "S!",
      "log",
      "log2",
      "log10",
      "sqrt",
      "exp"
    };
    Set<String> ary2 = {"+", "-", "*", "×", "/", "÷", "<<", ">>", "%"};
    if (numberExp.matchAsPrefix(v) != null) {
      push(Fraction.fromString(v));
    } else if (ary1.contains(v)) {
      var a = pop();
      if (v == "S-") {
        push(-a);
      } else if (v == "S+") {
        push(a);
      } else if (v == "S!") {
        var res = BigInt.one;
        for (var i = a.toBigInt(); i > BigInt.one; i -= BigInt.one) {
          res *= i;
        }
        push(Fraction.fromBigInt(res));
      } else if (v == "log") {
        push(a.log());
      } else if (v == "log2") {
        push(a.log2());
      } else if (v == "log10") {
        push(a.log10());
      } else if (v == "exp") {
        push(a.exp());
      } else if (v == "sqrt") {
        push(a.sqrt());
      } else {
        throw Exception("no such unary op: $v");
      }
    } else if (ary2.contains(v)) {
      var a = pop();
      var b = pop();
      if (v == "+") {
        push(b + a);
      } else if (v == "-") {
        push(b - a);
      } else if (v == "*" || v == "×") {
        push(b * a);
      } else if (v == "/" || v == "÷") {
        push(b / a);
      } else if (v == "<<") {
        push(b << a.toBigInt().toInt());
      } else if (v == ">>") {
        push(b >> a.toBigInt().toInt());
      } else if (v == "%") {
        push(b % a);
      } else {
        throw Exception("no such binary op: $v");
      }
    }
  }

  Fraction eval(String s) {
    fromInfixString(s, numberExp, funcExp);
    return evaluate();
  }

  List<String> exprStack = [];

  void toExpr1(String v) {
    Set<String> ary1 = {
      "S-",
      "S+",
      "S!",
      "log",
      "log2",
      "log10",
      "sqrt",
      "exp"
    };
    Set<String> ary2 = {"+", "-", "*", "×", "/", "÷", "<<", ">>", "%"};
    if (numberExp.matchAsPrefix(v) != null) {
      exprStack.add(Fraction.fromString(v).toExpr());
    } else if (ary1.contains(v)) {
      var a = exprStack.removeLast();
      if (a.contains(" ")) {
        a = "($a)";
      }
      if (v == "S-") {
        exprStack.add("-$a");
      } else if (v == "S+") {
        exprStack.add("+$a");
      } else if (v == "S!") {
        exprStack.add("$a!");
      } else if (v == "log") {
        exprStack.add("\\log $a");
      } else if (v == "log2") {
        exprStack.add("\\log_2 $a");
      } else if (v == "log10") {
        exprStack.add("\\log_10 $a");
      } else if (v == "exp") {
        exprStack.add("e^{$a}");
      } else if (v == "sqrt") {
        exprStack.add("\\sqrt{$a}");
      } else {
        throw Exception("no such unary op: $v");
      }
    } else if (ary2.contains(v)) {
      var a = exprStack.removeLast();
      var b = exprStack.removeLast();
      if (a.contains(" ")) {
        a = "($a)";
      }
      if (b.contains(" ")) {
        b = "($b)";
      }
      if (v == "+") {
        exprStack.add("$b + $a");
      } else if (v == "-") {
        exprStack.add("$b - $a");
      } else if (v == "*" || v == "×") {
        exprStack.add("$b \\times $a");
      } else if (v == "/" || v == "÷") {
        exprStack.add("\\frac{$b}{$a}");
      } else if (v == "<<") {
        exprStack.add("$b << $a");
      } else if (v == ">>") {
        exprStack.add("$b >> $a");
      } else if (v == "%") {
        exprStack.add("$b \\bmod $a");
      } else {
        throw Exception("no such binary op: $v");
      }
    }
  }

  String toExpr() {
    exprStack = [];
    expression.forEach((x) => toExpr1(x));
    return exprStack.last;
  }
}

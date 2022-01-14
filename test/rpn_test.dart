import 'package:test/test.dart';
import 'package:clc/rpn.dart';
import 'dart:math';

class myRPN extends RPN<int> {
  @override
  void exec1(String v) {
    if (RegExp(r"^[0-9]+$").hasMatch(v)) {
      push(int.parse(v));
    } else if (v.startsWith("S")) {
      var a = pop();
      if (v == "S-") {
        push(-a);
      } else if (v == "S+") {
        push(a);
      }
    } else {
      var a = pop();
      var b = pop();
      if (v == "*") {
        push(b * a);
      } else if (v == "+") {
        push(b + a);
      } else if (v == "-") {
        push(b - a);
      } else if (v == "/") {
        push(b ~/ a);
      } else if (v == "%") {
        push(b % a);
      } else {
        throw Exception("unknown opcode");
      }
    }
  }
}

void rpnString() {
  Map<String, List<String>> strmaps = {
    "12345 23456 /": ["12345", "23456", "/"],
  };
  strmaps.forEach((key, value) {
    test("fromString $key", () {
      var m = myRPN();
      m.fromString(key, " ");
      expect(m.expression, equals(value));
    });
  });
}

void infixString() {
  Map<String, List<String>> strmaps = {
    "5+8*(4+5)": ["5", "8", "4", "5", "+", "*", "+"],
    "1/2*3": ["1", "2", "/", "3", "*"],
    "((6/11)+(8/9))/129": ["6", "11", "/", "8", "9", "/", "+", "129", "/"],
    "{(6/11)+(8/9)}/129": ["6", "11", "/", "8", "9", "/", "+", "129", "/"],
    "(6/11)+(8/9)/129": ["6", "11", "/", "8", "9", "/", "129", "/", "+"],
    "(3 + 4) * (1 - 2)": ["3", "4", "+", "1", "2", "-", "*"],
    "-10*10": ["10", "S-", "10", "*"],
    "-10*10+20": ["10", "S-", "10", "*", "20", "+"],
    "10+-10*-1": ["10", "10", "S-", "1", "S-", "*", "+"],
    "-(1+2+3)": ["1", "2", "+", "3", "+", "S-"],
  };

  strmaps.forEach((key, value) {
    test("fromInfix $key", () {
      var m = myRPN();
      m.fromInfixString(key, RegExp("[0-9]+"));
      expect(m.expression, equals(value));
    });
  });
}

void infixStringFunc() {
  Map<String, List<String>> strmaps = {
    "1*log(20)": ["1", "20", "log", "*"],
    "1*log(20+10)": ["1", "20", "10", "+", "log", "*"],
    "sqrt(100)+log(20*10)": ["100", "sqrt", "20", "10", "*", "log", "+"],
  };

  strmaps.forEach((key, value) {
    test("fromInfixFunc $key", () {
      var m = myRPN();
      m.fromInfixString(key, RegExp("[0-9]+"), RegExp("log|sqrt"));
      expect(m.expression, equals(value));
    });
  });
}

void rpnEval() {
  Map<String, int> strmaps = {
    "12345 23456 +": 12345 + 23456,
  };
  strmaps.forEach((key, value) {
    test("evaluate $key", () {
      var m = myRPN();
      m.fromString(key, " ");
      expect(m.evaluate(), equals(value));
    });
  });
}

void infixEval() {
  Map<String, int> strmaps = {
    "5+8*(4+5)": 5 + 8 * (4 + 5),
    "-10/5*16": -32,
    "10+(-10)": 0,
    "10+(-10)*-1": 10 + (-10) * -1,
  };
  strmaps.forEach((key, value) {
    test("evaluate $key", () {
      var m = myRPN();
      m.fromInfixString(key, RegExp("[0-9]+"));
      expect(m.evaluate(), equals(value));
    });
  });
}

void main() {
  rpnString();
  infixString();
  infixStringFunc();
  rpnEval();
  infixEval();
}

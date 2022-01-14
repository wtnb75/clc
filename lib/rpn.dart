// RPN(Reverse Polish Notation) expression
import 'dart:math';
import 'package:logger/logger.dart';

var log = Logger(
  printer: SimplePrinter(printTime: true),
);

abstract class RPN<N> {
  List<String> expression = [];
  List<N> stack = [];

  void fromString(String input, String delim) {
    expression = input.split(delim);
  }

  // for Infix Notation
  Map<String, String> braces = {
    ")": "(",
    "}": "{",
    "]": "[",
  };

  Map<String, int> opcodes = {
    "S-": 1,
    "S+": 1,
    "S!": 1,
    "*": 2,
    "/": 2,
    "%": 2,
    "×": 2,
    "÷": 2,
    "+": 3,
    "-": 3,
    "<<": 4,
    ">>": 4,
    "&": 5,
    "^": 6,
    "|": 7,
  };

  void fromInfixString(String input, RegExp number, [RegExp? func]) {
    // load infix notation string to rev polish notation
    var opcodeLength = opcodes.keys.map((x) => x.length).reduce(max);
    List<String> p = [];
    List<MapEntry<String, int>> s = [];
    int idx = 0;
    bool single = true;
    while (idx < input.length) {
      // skip space
      var rest0 = input.substring(idx);
      var rest = rest0.trimLeft();
      idx += rest0.length - rest.length;

      log.d("p=$p, s=$s");
      log.d("rest: idx=$idx, $rest");
      var oplen = 0;
      var prio = 100;
      String? opnum;
      var isnum = number.matchAsPrefix(rest);
      var isfunc = func?.matchAsPrefix(rest);
      if (isnum != null) {
        // number
        opnum = isnum[0]!;
        oplen = opnum.length;
        prio = 0;
        single = false;
        log.d("number: $opnum len=$oplen prio=$prio");
      } else if (braces.containsValue(rest[0]) || braces.containsKey(rest[0])) {
        // braces
        oplen = 1;
        opnum = rest[0];
        prio = 100;
        single = braces.containsValue(rest[0]);
        log.d("brace: $opnum len=$oplen prio=$prio");
      } else if (isfunc != null) {
        // func
        opnum = isfunc[0]!;
        oplen = opnum.length;
        prio = 0;
        single = false;
        log.d("func: $opnum len=$oplen prio=$prio");
      } else {
        // opcode
        for (int x = opcodeLength; x != 0; x--) {
          var op = rest.substring(0, x);
          if (single) {
            op = "S$op";
          }
          if (opcodes.containsKey(op)) {
            opnum = op;
            oplen = x;
            prio = opcodes[op]!;
            single = true;
            log.d("opcode: $opnum len=$oplen prio=$prio");
            break;
          }
        }
      }
      if (opnum == null) {
        log.e("error: cannot find op/num: idx=$idx, rest=$rest");
        break;
      }
      if (braces.containsValue(opnum)) {
        log.d("brace-start push: $opnum");
        s.add(MapEntry(opnum, prio));
      } else if (braces.containsKey(opnum)) {
        log.d("brace-end move");
        var sbrace = braces[opnum]!;
        while (s.last.key != sbrace) {
          var tmp = s.removeLast();
          if (braces.containsKey(tmp.key) || braces.containsValue(tmp.key)) {
            log.d("brace skip move: $tmp");
          } else {
            log.d("brace move: $tmp");
            p.add(tmp.key);
          }
        }
        if (s.last.key == sbrace) {
          // pop sbrace
          s.removeLast();
        }
      } else {
        while (s.isNotEmpty && s.last.value <= prio) {
          log.d("notempty=${s.isNotEmpty}, lastval=${s.last}");
          var tmp = s.removeLast();
          if (braces.containsKey(tmp.key) || braces.containsValue(tmp.key)) {
            log.d("move: brace skip: $tmp");
          } else {
            log.d("move: $tmp");
            p.add(tmp.key);
          }
        }
        log.d("finished: notempty=${s.isNotEmpty}");
        if (s.isNotEmpty) {
          log.d("finished: lastval=${s.last}");
        }
        s.add(MapEntry(opnum, prio));
      }
      idx += oplen;
    }
    while (s.isNotEmpty) {
      var tmp = s.removeLast();
      if (braces.containsKey(tmp.key) || braces.containsValue(tmp.key)) {
        log.d("last move: brace skip: $tmp");
      } else {
        log.d("last move: $tmp");
        p.add(tmp.key);
      }
    }
    log.d("result: $input -> $p");
    expression = p;
  }

  N pop() {
    return stack.removeLast();
  }

  void push(N v) {
    stack.add(v);
  }

  void exec1(String v);

  N evaluate() {
    expression.forEach((x) => exec1(x));
    return stack.last;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:clc/fractexpr.dart';
import 'package:clc/fract.dart';
import 'package:url_launcher/url_launcher.dart';

var log = Logger(
  printer: SimplePrinter(printTime: true),
);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Simple Calculator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _resultStr = "";
  String _resultStr2 = "";
  String _exprStr = "";
  Fraction _result = Fraction(BigInt.one, BigInt.one);
  TextEditingController ctrl = TextEditingController();

  void _showResult2() {
    setState(() {
      _resultStr = _result.toString();
      _resultStr2 = _result.toString2();
    });
  }

  void _showResult(String s) {
    setState(() {
      if (s == "") {
        _result = Fraction(BigInt.zero, BigInt.one);
        _resultStr = "";
        _resultStr2 = "";
        _exprStr = "";
      } else {
        try {
          FractRpn f = FractRpn();
          _result = f.eval(s);
          _resultStr = _result.toExpr();
          _resultStr2 = _result.toExpr2();
          _exprStr = f.toExpr();
        } on Exception catch (e) {
          _resultStr = "ERR";
          _resultStr2 = "ERR";
          log.d("$e");
        }
      }
    });
  }

  void push_txt(String txt) {
    log.d("push $txt");
    if (txt == "AC") {
      ctrl.text = "";
      txt = "";
      _showResult(ctrl.text);
    } else if (txt == "BS") {
      var start = ctrl.selection.start;
      log.d("start=$start");
      if (start == -1) {
        if (ctrl.text.isNotEmpty) {
          ctrl.text = ctrl.text.substring(0, ctrl.text.length - 1);
        }
      } else if (start != 0) {
        ctrl.text =
            ctrl.text.substring(0, start - 1) + ctrl.text.substring(start);
        _showResult(ctrl.text);
      }
      return;
    } else if (txt == "+/-") {
      _showResult(ctrl.text);
      if (_resultStr != "ERR") {
        _showResult2();
        ctrl.text = _result.toString();
      }
      txt = "";
    } else if (txt == "=") {
      _showResult(ctrl.text);
      if (_resultStr != "ERR") {
        ctrl.text = _result.toString();
      }
      txt = "";
    }
    var start = ctrl.selection.start;
    var end = ctrl.selection.end;
    log.d("pre: start=$start, end=$end");
    if (start == -1) {
      start = ctrl.text.length;
    }
    if (end == -1) {
      end = start;
    }
    log.d("fix: start=$start, end=$end");
    ctrl.text = ctrl.text.substring(0, start) + txt + ctrl.text.substring(end);
    ctrl.selection =
        TextSelection.fromPosition(TextPosition(offset: start + txt.length));
    _showResult(ctrl.text);
  }

  Widget txtbtn(String txt,
      {Color fgcolor = Colors.black,
      Color bgcolor = Colors.black12,
      int flex = 1}) {
    return Expanded(
        flex: flex,
        child: TextButton(
            onPressed: () => push_txt(txt),
            child: Text(txt,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  // fontSize: 25,
                )),
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(fgcolor),
              backgroundColor: MaterialStateProperty.all<Color>(bgcolor),
            )));
  }

  Widget buttons() {
    return Column(children: <Widget>[
      Row(children: <Widget>[
        txtbtn("7"),
        txtbtn("8"),
        txtbtn("9"),
        txtbtn("(", bgcolor: Colors.orangeAccent),
        txtbtn(")", bgcolor: Colors.orangeAccent),
      ]),
      Row(children: <Widget>[
        txtbtn("4"),
        txtbtn("5"),
        txtbtn("6"),
        txtbtn("×", bgcolor: Colors.orangeAccent),
        txtbtn("÷", bgcolor: Colors.orangeAccent),
      ]),
      Row(children: <Widget>[
        txtbtn("1"),
        txtbtn("2"),
        txtbtn("3"),
        txtbtn("+", bgcolor: Colors.orangeAccent),
        txtbtn("-", bgcolor: Colors.orangeAccent),
      ]),
      Row(children: <Widget>[
        txtbtn("0"),
        txtbtn("."),
        txtbtn("AC", bgcolor: Colors.orangeAccent),
        txtbtn("BS", bgcolor: Colors.orangeAccent),
        txtbtn("=", bgcolor: Colors.orangeAccent),
      ]),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 4,
        child: Builder(
          builder: (BuildContext context) {
            return Scaffold(
                extendBody: false,
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerDocked,
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    var tabid = DefaultTabController.of(context)?.index;
                    String copyText = "";
                    if (tabid == 1) {
                      copyText = _result.toString2();
                    } else if (tabid == 2) {
                      copyText = _result.toDouble().toString();
                    } else if (tabid == 3) {
                      copyText = _exprStr;
                    } else {
                      copyText = _result.toString();
                    }
                    log.d("copy$tabid: $copyText");
                    Clipboard.setData(ClipboardData(text: copyText));
                  },
                  child: const Icon(Icons.copy),
                  tooltip: "copy",
                ),
                drawer: Drawer(
                  child: ListView(
                    children: <Widget>[
                      DrawerHeader(
                        child: Text(widget.title,
                            style: const TextStyle(color: Colors.white)),
                        decoration: const BoxDecoration(color: Colors.blue),
                      ),
                      ListTile(
                        title: Row(children: const <Widget>[
                          Icon(Icons.bug_report),
                          Text("Report issue"),
                        ]),
                        onTap: () {
                          launch("https://github.com/wtnb75/clc/issues/new");
                        },
                      ),
                      ListTile(
                        title: const Text("other action..."),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                appBar: AppBar(
                    title: Text(widget.title),
                    bottom: TabBar(
                      tabs: <Widget>[
                        Tab(child: Math.tex(r'\frac{3}{2}')),
                        Tab(child: Math.tex(r'1 \frac{1}{2}')),
                        Tab(child: Math.tex(r'1.5')),
                        Tab(child: Math.tex(r'\frac{1}{2} \times 3')),
                      ],
                    )),
                body: Container(
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.blueGrey)),
                  margin: const EdgeInsets.all(8),
                  child: TabBarView(children: <Widget>[
                    Center(
                        child: Math.tex(
                      _resultStr,
                      mathStyle: MathStyle.display,
                      textStyle: const TextStyle(fontSize: 42),
                    )),
                    Center(
                        child: Math.tex(
                      _resultStr2,
                      mathStyle: MathStyle.display,
                      textStyle: const TextStyle(fontSize: 42),
                    )),
                    Center(
                        child: Math.tex(
                      '${_result.toDouble()}',
                      mathStyle: MathStyle.display,
                      textStyle: const TextStyle(fontSize: 42),
                    )),
                    Center(
                        child: Math.tex(
                      _exprStr,
                      mathStyle: MathStyle.display,
                      textStyle: const TextStyle(fontSize: 42),
                    )),
                  ]),
                ),
                bottomNavigationBar: Container(
                  padding: const EdgeInsets.all(10),
                  child:
                      Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: TextField(
                            controller: ctrl,
                            textAlign: TextAlign.right,
                            enabled: true,
                            maxLines: 1,
                            style: const TextStyle(fontSize: 30),
                            keyboardType: TextInputType.number,
                            onChanged: _showResult,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter formula',
                            ))),
                    const Divider(),
                    buttons(),
                  ]),
                  // bottomNavigationBar: buttons(),
                ));
          },
        ));
  }
}

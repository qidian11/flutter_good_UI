import 'package:flutter/material.dart';
import 'dart:math';

double sphereRadius = 100;

class MySphere extends StatefulWidget {
  const MySphere({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MySphere> createState() => _MySphereState();
}

class _MySphereState extends State<MySphere> {
  int _counter = 0;
  List<MyStar> starList = [];

  @override
  void initState() {
    // TODO: implement initState
    var random = Random();
    for (int i = 0; i < 2 * sphereRadius; i++) {
      int negative;
      Offset position = getPosition(random);
      MyStar star = MyStar(x: position.dx, y: position.dy);
      negative = random.nextBool() ? 1 : -1;
      star.r = (random.nextDouble() * sphereRadius) * negative;
      starList.add(star);
    }
    super.initState();
  }

  Offset getPosition(Random random) {
    int negative = random.nextBool() ? 1 : -1;
    double x = random.nextDouble() * sphereRadius * negative;
    negative = random.nextBool() ? 1 : -1;
    double y = random.nextDouble() * sphereRadius * negative;
    double dist = x * x + y * y;
    if (dist > sphereRadius * sphereRadius) {
      double ratio = (sphereRadius * sphereRadius) / dist;
      x *= ratio;
      y *= ratio;
    }
    return Offset(x, y);
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      backgroundColor: Color(0xFF000000),
      body: Center(
        child: Container(
            width: 2 * sphereRadius,
            height: 2 * sphereRadius,
            child: CustomPaint(
              painter: SpherePainter(starList),
            )),
      ),
    );
  }
}

class SpherePainter extends CustomPainter {
  late Size size;
  List<MyStar> starList;
  Paint _paint = Paint()
    ..isAntiAlias = true
    // ..style = PaintingStyle.stroke
    ..style = PaintingStyle.fill
    ..strokeWidth = 0.5
    ..color = Colors.white;

  SpherePainter(this.starList);

  @override
  void paint(Canvas canvas, Size size) {
    double height = size.height;
    double width = size.width;
    this.size = size;
    canvas.translate(width / 2, height / 2);
    starList.forEach((e) {
      Offset center = Offset(e.x, e.y);
      canvas.drawOval(
          Rect.fromCenter(center: center, width: 5, height: 5), _paint);
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}

class MyStar {
  late double _r;
  double x;
  double y;

  double get r => _r;
  set r(double radius) => _r = radius;

  MyStar({required this.x, required this.y});
}

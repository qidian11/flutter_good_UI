import 'package:flutter/material.dart';
import 'dart:math';

double sphereRadius = 80;

class My3DSphere extends StatefulWidget {
  static const String name = "My3DSphere";
  const My3DSphere({Key? key, this.title = "3D Sphere"}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<My3DSphere> createState() => _My3DSphereState();
}

class _My3DSphereState extends State<My3DSphere> {
  int _counter = 0;
  double spotRadius = 8;
  List<MyStar> starList = [];

  @override
  void initState() {
    // TODO: implement initState
    var random = Random();
    for (int i = 0; i < 80; i++) {
      int negative;
      negative = random.nextBool() ? 1 : -1;
      double dist = (random.nextDouble() * sphereRadius) * negative;
      Offset position = getPosition(random, dist);
      MyStar star = MyStar(x: position.dx, y: position.dy);
      star.dist = dist;
      starList.add(star);
    }
    // MyStar star = MyStar(x: 0, y: 0);
    // star.dist = sphereRadius;
    // starList.add(star);
    super.initState();
  }

  Offset getPosition(Random random, double r) {
    int negative = random.nextBool() ? 1 : -1;
    double x = random.nextDouble() * sphereRadius * negative;
    negative = random.nextBool() ? 1 : -1;
    double y = random.nextDouble() * sphereRadius * negative;
    double dist = x * x + y * y;
    if (dist > r * r) {
      double ratio = (r * r) / dist;
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
        child: GestureDetector(
          onPanUpdate: (e) {
            double newX;
            double newY;
            double edgePointX;
            double edgePointY;
            double newAngle = 0;
            starList.forEach((element) {
              if (element.dist > 0) {
                // front
                newX = element.x + e.delta.dx * element.dist / sphereRadius;
                newY = element.y + e.delta.dy * element.dist / sphereRadius;
                if (newX * newX + newY * newY > element.dist * element.dist) {
                  if (newX != 0) {
                    newAngle = atan(newY / newX).abs();
                    if (newX < 0 && newY < 0) newAngle += pi;
                    if (newX < 0 && newY > 0) newAngle = pi - newAngle;
                    if (newX > 0 && newY < 0) newAngle = 2 * pi - newAngle;
                  } else {
                    if (newY > 0) newAngle = 0.5 * pi;
                    if (newY < 0) newAngle = 1.5 * pi;
                    if (newY == 0) newAngle = 0;
                  }

                  edgePointX = element.dist * cos(newAngle);
                  edgePointY = element.dist * sin(newAngle);
                  if (newX.abs() > edgePointX.abs()) {
                    newX = edgePointX - (newX - edgePointX);
                    element.dist =
                        element.dist > 0 ? -element.dist : element.dist;
                  }
                  if (newY.abs() > edgePointY.abs()) {
                    newY = edgePointY - (newY - edgePointY);
                    element.dist =
                        element.dist > 0 ? -element.dist : element.dist;
                  }
                }
                element.x = newX;
                element.y = newY;
              } else {
                // back
                newX =
                    element.x - e.delta.dx * element.dist.abs() / sphereRadius;
                newY =
                    element.y - e.delta.dy * element.dist.abs() / sphereRadius;
                if (newX * newX + newY * newY > element.dist * element.dist) {
                  if (newX != 0) {
                    newAngle = atan(newY / newX).abs();
                    if (newX < 0 && newY < 0) newAngle += pi;
                    if (newX < 0 && newY > 0) newAngle = pi - newAngle;
                    if (newX > 0 && newY < 0) newAngle = 2 * pi - newAngle;
                  } else {
                    if (newY > 0) newAngle = 0.5 * pi;
                    if (newY < 0) newAngle = 1.5 * pi;
                    if (newY == 0) newAngle = 0;
                  }
                  edgePointX = element.dist.abs() * cos(newAngle);
                  edgePointY = element.dist.abs() * sin(newAngle);
                  if (newX.abs() > edgePointX.abs()) {
                    newX = edgePointX - (newX - edgePointX);
                    element.dist = -element.dist;
                  }
                  if (newY.abs() > edgePointY.abs()) {
                    newY = edgePointY - (newY - edgePointY);
                    element.dist =
                        element.dist < 0 ? -element.dist : element.dist;
                  }
                }
                element.x = newX;
                element.y = newY;
              }
            });
            setState(() {});
          },
          child: Container(
              width: 2 * sphereRadius,
              height: 2 * sphereRadius,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(sphereRadius)),
                  border: Border.all(
                    color: Color(0xFFFFFFFF),
                    width: 1,
                  )),
              child: CustomPaint(
                painter: SpherePainter(starList, spotRadius),
              )),
        ),
      ),
    );
  }
}

class SpherePainter extends CustomPainter {
  late Size size;
  List<MyStar> starList;
  double spotRadius;
  Paint _paint = Paint()
    ..isAntiAlias = true
    // ..style = PaintingStyle.stroke
    ..style = PaintingStyle.fill
    ..strokeWidth = 0.5
    ..color = Colors.white;

  SpherePainter(this.starList, this.spotRadius);

  @override
  void paint(Canvas canvas, Size size) {
    double height = size.height;
    double width = size.width;

    this.size = size;
    canvas.translate(width / 2, height / 2);
    _paint.color = Color(0xFFFFFFFF);
    canvas.drawLine(Offset.zero, Offset(0, sphereRadius), _paint);
    canvas.drawLine(Offset.zero, Offset(0, -sphereRadius), _paint);
    canvas.drawLine(Offset.zero, Offset(sphereRadius, 0), _paint);
    canvas.drawLine(Offset.zero, Offset(-sphereRadius, 0), _paint);
    starList.forEach((e) {
      if (e.dist < 0) {
        Offset center;
        double angle = 0;
        if (e.x != 0) {
          angle = atan(e.y / e.x);
          angle = angle.abs();
          if (e.x < 0 && e.y < 0) angle += pi;
          if (e.x > 0 && e.y < 0) angle = 2 * pi - angle;
          if (e.x < 0 && e.y > 0) angle = pi - angle;
        } else {
          if (e.y > 0) angle = 0.5 * pi;
          if (e.y < 0) angle = 1.5 * pi;
          if (e.y == 0) angle = 0;
        }
        canvas.rotate(angle);

        double r2DSquare =
            e.x * e.x + e.y * e.y; // 2d projection radius square 2维投影半径的平方
        double r2D = sqrt(r2DSquare); // 2d projection radius 2维投影半径
        double ovalWidth;
        double ovalHeight;
        center = Offset(r2D, 0);
        // canvas.drawLine(Offset.zero, center, _paint);
        double zDistSquare = e.dist * e.dist - r2DSquare;
        zDistSquare = zDistSquare < 0 ? 0 : zDistSquare;
        double zDist = sqrt(zDistSquare);
        // horizontal perspective ratio 水平透视的比率
        double hPRatio = (1 - r2DSquare / (sphereRadius * sphereRadius) * 0.2);
        // skew perspective ratio 倾斜透视
        double skewPRatio = 1 - r2DSquare / (e.dist * e.dist) * 0.8;

        // _paint.color = Colors.blue;
        // depth perspective 纵深透视
        double dPRatio = (1 - zDist / sphereRadius * 0.2);
        ovalWidth = skewPRatio * hPRatio * dPRatio * spotRadius * 0.8;
        ovalHeight = hPRatio * dPRatio * spotRadius * 0.8;
        ovalWidth = ovalWidth < 1 ? 1 : ovalWidth;
        ovalHeight = ovalHeight < 1 ? 1 : ovalHeight;
        canvas.drawOval(
            Rect.fromCenter(
                center: center, width: ovalWidth, height: ovalHeight),
            _paint);

        canvas.rotate(-angle);
      }
    });
    starList.forEach((e) {
      if (e.dist > 0) {
        Offset center;
        double angle = 0;
        if (e.x != 0) {
          angle = atan(e.y / e.x);
          angle = angle.abs();
          if (e.x < 0 && e.y < 0) angle += pi;
          if (e.x > 0 && e.y < 0) angle = 2 * pi - angle;
          if (e.x < 0 && e.y > 0) angle = pi - angle;
        } else {
          if (e.y > 0) angle = 0.5 * pi;
          if (e.y < 0) angle = 1.5 * pi;
          if (e.y == 0) angle = 0;
        }
        canvas.rotate(angle);

        double r2DSquare =
            e.x * e.x + e.y * e.y; // 2d projection radius square 2维投影半径的平方
        double r2D = sqrt(r2DSquare); // 2d projection radius 2维投影半径
        double ovalWidth;
        double ovalHeight;
        center = Offset(r2D, 0);
        // canvas.drawLine(Offset.zero, center, _paint);
        double zDistSquare = e.dist * e.dist - r2DSquare;
        zDistSquare = zDistSquare < 0 ? 0 : zDistSquare;
        double zDist = sqrt(zDistSquare);
        // horizontal perspective ratio 水平透视的比率
        double hPRatio = (1 - r2DSquare / (sphereRadius * sphereRadius) * 0.2);
        // skew perspective ratio 倾斜透视
        // double skewPRatio = 1 - r2DSquare / (e.dist * e.dist) * 0.2;

        // _paint.color = Color(0xCCFF0000);
        // depth perspective 纵深透视
        double dPRatio = 1 - (sphereRadius - zDist) / sphereRadius * 0.2;
        // ovalWidth = skewPRatio * hPRatio * dPRatio * spotRadius;
        ovalWidth = hPRatio * dPRatio * spotRadius;
        ovalHeight = hPRatio * dPRatio * spotRadius;
        canvas.drawOval(
            Rect.fromCenter(
                center: center, width: ovalWidth, height: ovalHeight),
            _paint);

        canvas.rotate(-angle);
      }
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}

class MyStar {
  late double _dist;
  double x;
  double y;

  double get dist => _dist;
  set dist(double radius) => _dist = radius;

  MyStar({required this.x, required this.y});
}

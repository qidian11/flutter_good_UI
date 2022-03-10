import "dart:math";
import "package:flutter/material.dart";
import 'package:flutter_good_ui/util/extension_util.dart';
import 'package:decimal/decimal.dart';

const double sphereRadius = 300;
const double dP = 0.6;

class Sphere extends StatefulWidget {
  final int starNum;
  final Color starColor;
  final Color starShaderColor;
  const Sphere(
      {Key? key,
      this.starNum = 300,
      this.starColor = Colors.blue,
      this.starShaderColor = const Color(0xCC21CCF3)})
      : super(key: key);

  @override
  State<Sphere> createState() => _SphereState();
}

class _SphereState extends State<Sphere> {
  // tap position
  Offset prePosition = Offset(0, 0);
  Offset newPosition = Offset(0, 0);
  late SphereInfo sphereInfo;

  @override
  void initState() {
    // remove alpha channel
    int color = (widget.starColor.alpha << 24 ^ widget.starColor.value);
    Star.color = color;
    int shaderColor =
        (widget.starShaderColor.alpha << 24 ^ widget.starShaderColor.value);
    Star.shaderColor = shaderColor;
    sphereInfo = SphereInfo.ring();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (e) {
        // print("e.local :${e.localPosition}");
        prePosition = e.localPosition.translate(-sphereRadius, -sphereRadius);
        // print("tap position :${prePosition}");
      },
      onPanUpdate: (e) {
        newPosition = e.localPosition.translate(-sphereRadius, -sphereRadius);
        // out range return 超出范围返回
        if (newPosition.dx.square + newPosition.dy.square >
            sphereRadius.square) {
          return;
        }
        // print('newPosition:$newPosition prePosition:$prePosition');
        // print("newPosition:$newPosition prePosition:$prePosition");
        // rotateAngle: List[angle in Z-X plane,angle in Z-Y plane]
        List rotateAngle = getRotateAngle(prePosition, newPosition);
        sphereInfo.updateStarList(rotateAngle);
        prePosition = newPosition;
        setState(() {});
      },
      child: Container(
          width: 2 * sphereRadius,
          height: 2 * sphereRadius,
          // decoration: BoxDecoration(
          //     borderRadius: BorderRadius.all(Radius.circular(sphereRadius)),
          //     border: Border.all(
          //       color: Color(0xFFFFFFFF),
          //       width: 1,
          //     )),
          child: CustomPaint(
            painter: SpherePainter(sphereInfo.starList),
          )),
    );
  }

  double getAngle(double x, double y) {
    double angle = 0;
    if (x != 0) {
      angle = atan(y / x).abs();
      if (x < 0 && y < 0) angle += pi;
      if (x < 0 && y > 0) angle = pi - (angle);
      if (x > 0 && y < 0) angle = 2 * (pi) - (angle);
    } else {
      if (y > 0) angle = 0.5 * (pi);
      if (y < 0) angle = 1.5 * (pi);
      if (y == 0) angle = 0;
    }
    return angle;
  }

  // angleX_Y = angleZ_Y
  List<double> getRotateAngle(Offset prePosition, Offset newPosition) {
    double angleZ_Y = getAngleZ_Y(prePosition.dy, newPosition.dy, sphereRadius);
    double angleZ_X = getAngleZ_X(prePosition.dx, newPosition.dx, sphereRadius);
    return [angleZ_X, angleZ_Y];
  }

  // 获取在球的投影面上的转动角度
  // counterclockwise in z-y clockwise in z-x star angle from y-axis|z-y/x-axis|z-x
  // z-y顺时针计算 z-x顺时针计算 起始角从z轴/x轴算起
  double getAngleZ_X(double preX, double newX, double radius) {
    double preAngle = acos(preX / sphereRadius);
    double newAngle = acos(newX / sphereRadius);
    double angle = newAngle - (preAngle);
    return angle;
  }

  double getAngleZ_Y(double preY, double newY, double radius) {
    double preAngle = asin(preY / sphereRadius);
    double newAngle = asin(newY / sphereRadius);
    double angle = newAngle - (preAngle);
    return angle;
  }
}

enum SphereType { Ring, Sphere }

class SphereInfo {
  List<Star> starList = [];
  // total rotate angle
  double rotateAngleZ_X = 0.0;
  double rotateAngleZ_Y = 0.0;
  double sphereRadius;
  int starNum;
  late SphereType type;

  SphereInfo.ring({this.starNum = 200, this.sphereRadius = 300}) {
    type = SphereType.Ring;
    Random random = Random();
    for (int i = 0; i < starNum; i++) {
      int negative;
      negative = random.nextBool() ? 1 : -1;
      double dist =
          random.rangeDouble(2 * sphereRadius / (3), sphereRadius) * negative;
      Offset position = getPosition(random, dist, type: SphereType.Ring);
      Star star = Star(
          x: position.dx,
          y: position.dy,
          starRadius: random.rangeDouble(3, 5),
          dist: dist);
      starList.add(star);
    }
    // updateStarList([0, pi / 2]);
  }

  SphereInfo.sphere({this.starNum = 200, this.sphereRadius = 300}) {
    type = SphereType.Sphere;
    Random random = Random();
    for (int i = 0; i < starNum; i++) {
      int negative;
      negative = random.nextBool() ? 1 : -1;
      double dist = random.rangeDouble(
              2 * sphereRadius / 3 - sphereRadius / 8, 2 * sphereRadius / 3) *
          negative;
      Offset position = getPosition(
        random,
        dist,
      );
      Star star = Star(
          x: position.dx,
          y: position.dy,
          starRadius: random.rangeDouble(3, 5),
          dist: dist);
      starList.add(star);
    }
  }

  Offset getPosition(Random random, double r,
      {SphereType type = SphereType.Sphere}) {
    int sign = random.nextBool() ? 1 : -1;
    double x = random.rangeDouble(-sphereRadius, sphereRadius);
    x = x == 0 ? 10.0 * sign : x;
    double y;
    // negative = random.nextBool() ? 1 : -1;
    if (type == SphereType.Ring) {
      y = random.rangeDouble(
          (-sphereRadius / 8).round5, (sphereRadius / 8).round5);
    } else {
      y = random.rangeDouble(-sphereRadius, sphereRadius);
    }
    sign = random.nextBool() ? 1 : -1;
    y = y == 0 ? 10.0 * sign : y;
    double dist = x.square.round5 + y.square.round5;
    if (dist > r.square) {
      double ratio = (r.square.round5 / (dist)).round5;
      x = (x * (ratio)).round5;
      y = (y * (ratio)).round5;
    }
    print("x:$x y:$y");
    return Offset(x, y);
  }

  void updateStarList(List rotateAngle) {
    double newX;
    double newY;
    // projection radius 投影半径
    double radiusZ_Y;
    double radiusZ_X;
    double initAngleZ_Y = 0;
    double newAngleZ_Y = 0;
    // double initAngleZ_X = 0;
    double newAngleZ_X = 0;
    starList.forEach((e) {
      // radiusZ_X = sqrt(e.dist.square - e.y.square);
      radiusZ_X = sqrt(e.initDist.square - e.initY.square);
      if (radiusZ_X != 0) {
        // initAngleZ_X = acos((element.x / radiusZ_X));
        // if (element.dist < 0) initAngleZ_X = 2 * pi - initAngleZ_X;
        // newAngleZ_X = initAngleZ_X + rotateAngle[0];
        newAngleZ_X = e.initAngleZ_X + rotateAngle[0] + rotateAngleZ_X;
        newX = radiusZ_X * cos(newAngleZ_X);
      } else {
        // 此时垂直于Z_X平面
        newX = 0;
      }
      e.x = newX;
      radiusZ_Y = sqrt(e.initDist.square - e.x.square);
      if (radiusZ_Y == 0) {
        // 此时垂直于X_Y平面
        newY = 0;
      } else {
        initAngleZ_Y = asin((e.y / radiusZ_Y));
        if (e.dist < 0 && e.y > 0) {
          initAngleZ_Y = pi - initAngleZ_Y;
        }
        if (e.dist < 0 && e.y < 0) initAngleZ_Y = pi - initAngleZ_Y;
        newAngleZ_Y = initAngleZ_Y + rotateAngle[1] + rotateAngleZ_Y;
        newY = radiusZ_Y * (sin(newAngleZ_Y));
      }
      // rotate from back to front or from front to back
      // 转到背面或者转到正面
      if (newAngleZ_X * (e.initAngleZ_X + rotateAngleZ_X) < 0 ||
          (newAngleZ_X - pi) * (e.initAngleZ_X + rotateAngleZ_X - pi) < 0 ||
          (newAngleZ_X - 2 * pi) * (e.initAngleZ_X + rotateAngleZ_X - 2 * pi) <
              0 ||
          (newAngleZ_Y - pi / 2) * (initAngleZ_Y + rotateAngleZ_Y - pi / 2) <
              0 ||
          (newAngleZ_Y + pi / 2) * (initAngleZ_Y + rotateAngleZ_Y + pi / 2) <
              0 ||
          (newAngleZ_Y - 3 * pi / 2) *
                  (initAngleZ_Y + rotateAngleZ_Y - 3 * pi / 2) <
              0) {
        e.dist = -e.dist;
      }
      rotateAngleZ_X += rotateAngle[0];
      rotateAngleZ_Y += rotateAngle[1];
      rotateAngleZ_X =
          rotateAngleZ_X > 2 * pi ? rotateAngleZ_X - 2 * pi : rotateAngleZ_X;
      rotateAngleZ_X =
          rotateAngleZ_X < -2 * pi ? rotateAngleZ_X + 2 * pi : rotateAngleZ_X;
      rotateAngleZ_Y =
          rotateAngleZ_Y > 2 * pi ? rotateAngleZ_Y - 2 * pi : rotateAngleZ_Y;
      rotateAngleZ_Y =
          rotateAngleZ_Y < -2 * pi ? rotateAngleZ_Y + 2 * pi : rotateAngleZ_Y;
      double dist = newX.square + newY.square;
      if (dist > e.dist.square) {
        print("rotateAngleZ_X:$rotateAngleZ_X rotateAngleZ_Y:$rotateAngleZ_Y");
        // print(
        //     "超出范围 x:${e.x} y:${e.y} newX:$newX newY:$newY initAngleZ_X:${e.initAngleZ_X} newAngleZ_X:$newAngleZ_X initAngleZ_Y:${e.initAngleZ_Y} newAngleZ_Y:$newAngleZ_Y");
        double ratio = sqrt(e.dist.square / dist);
        newX *= ratio;
        newY *= ratio;
      }
      // print("x:${element.x}, y:${element.x}, dist:${element.dist}");
      // print("newX:$newX, newY:$newY, dist:${element.dist}");
      // print("rotateAngle:$rotateAngle");
      // print("initAngleZ-X:$initAngleZ_X newAngleZ_X:$newAngleZ_X");
      // print("initAngleZ-Y:$initAngleZ_Y newAngleZ_Y:$newAngleZ_Y");
      e.x = newX;
      e.y = newY;
    });
  }

  void ringToSphere() {}
}

class Star {
  static int color = 0x2196F3;
  static int shaderColor = 0x21CCF3;
  double dist;
  late double _initDist;
  late double _initX;
  double x;
  late double _initY;
  double y;
  late double _initAngleZ_X;
  late double _initAngleZ_Y;
  double starRadius;

  double get initAngleZ_X => _initAngleZ_X;
  double get initAngleZ_Y => _initAngleZ_Y;
  double get initX => _initX;
  double get initY => _initY;
  double get initDist => _initDist;

  Star(
      {required this.x,
      required this.y,
      required this.starRadius,
      required this.dist}) {
    _initX = x;
    _initY = y;
    _initDist = dist;
    double radiusZ_X = sqrt(dist.square - y.square);
    _initAngleZ_X = acos((x / radiusZ_X));
    if (dist < 0) _initAngleZ_X = 2 * pi - _initAngleZ_X;
    double radiusZ_Y = sqrt(dist.square - x.square);

    _initAngleZ_Y = asin((y / radiusZ_Y));
    if (dist < 0 && y > 0) {
      _initAngleZ_Y = pi - _initAngleZ_Y;
    }
    if (dist < 0 && y < 0) _initAngleZ_Y = pi - _initAngleZ_Y;
  }
}

class SpherePainter extends CustomPainter {
  late Size size;
  List<Star> starList;
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
    _paint.color = Color(0xFFFFFFFF);
    // canvas.drawLine(Offset.zero, Offset(0, sphereRadius), _paint);
    // canvas.drawLine(Offset.zero, Offset(0, -sphereRadius), _paint);
    // canvas.drawLine(Offset.zero, Offset(sphereRadius, 0), _paint);
    // canvas.drawLine(Offset.zero, Offset(-sphereRadius, 0), _paint);
    int alpha = 0xFF;
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
          if (e.y == 0 && e.x < 0) angle = pi;
        } else {
          if (e.y > 0) angle = 0.5 * pi;
          if (e.y < 0) angle = 1.5 * pi;
          if (e.y == 0) angle = 0;
        }
        canvas.rotate(angle);

        double r2DSquare =
            e.x.square + e.y.square; // 2d projection radius square 2维投影半径的平方
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
        double dPRatio = (1 - zDist / sphereRadius * (1 - dP));
        alpha = (0xFF * dPRatio).round();
        ovalWidth = dPRatio * e.starRadius * dP;
        ovalHeight = dPRatio * e.starRadius * dP;
        ovalWidth = ovalWidth < 1 ? 1 : ovalWidth;
        ovalHeight = ovalHeight < 1 ? 1 : ovalHeight;
        // print(
        //     "e.x:${e.x} e.y:${e.y} e.dist:${e.dist} e.starRadius:${e.starRadius}");
        // print("ovalWidth:$ovalWidth ovalHeight:$ovalHeight dPRatio$dPRatio");
        _paint.shader = RadialGradient(
          colors: [
            Color(alpha << 24 | Star.shaderColor),
            Color((alpha * 0.5).round() << 24 | Star.shaderColor),
          ],
        ).createShader(Rect.fromCircle(
          center: Offset(0, 0),
          radius: ovalWidth,
        ));
        canvas.drawOval(
            Rect.fromCenter(
                center: center, width: 3 * ovalWidth, height: 3 * ovalHeight),
            _paint);
        // _paint.color = Color(0xFF3345FF);
        _paint.shader = null;
        _paint.color = Color(alpha << 24 | Star.color);
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
          if (e.y == 0 && e.x < 0) angle = pi;
        } else {
          if (e.y > 0) angle = 0.5 * pi;
          if (e.y < 0) angle = 1.5 * pi;
          if (e.y == 0) angle = 0;
        }
        canvas.rotate(angle);
        // print("in painter x:${e.x}, y:${e.y}, dist:${e.dist}");
        // print("canvas rotate angle:$angle");
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
        double dPRatio = 1 - (sphereRadius - zDist) / sphereRadius * (1 - dP);
        // ovalWidth = skewPRatio * hPRatio * dPRatio * e.starRadius;
        ovalWidth = dPRatio * e.starRadius;
        ovalHeight = dPRatio * e.starRadius;
        // print(
        //     "e.x:${e.x} e.y:${e.y} e.dist:${e.dist} e.starRadius:${e.starRadius}");
        // print("ovalWidth:$ovalWidth ovalHeight:$ovalHeight dPRatio$dPRatio");
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

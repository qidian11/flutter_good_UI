import "dart:math";
import "package:flutter/material.dart";
import 'package:flutter_good_ui/util/extension_util.dart';
import 'package:decimal/decimal.dart';

double sphereRadius = 300;

class Sphere extends StatefulWidget {
  final int starNum;
  const Sphere({Key? key, this.starNum = 2}) : super(key: key);

  @override
  State<Sphere> createState() => _SphereState();
}

class _SphereState extends State<Sphere> {
  List<Star> starList = [];
  // tap position
  Offset prePosition = Offset(0, 0);
  Offset newPosition = Offset(0, 0);

  @override
  void initState() {
    var random = Random();
    for (int i = 0; i < widget.starNum; i++) {
      int negative;
      negative = random.nextBool() ? 1 : -1;
      double dist =
          random.rangeDouble(2 * sphereRadius / (3), sphereRadius) * negative;
      Offset position = getPosition(random, dist);
      Star star = Star(
          x: position.dx, y: position.dy, starRadius: random.rangeDouble(1, 5));
      star.dist = dist;
      starList.add(star);
    }
    // Star star0 = Star(x: 100, y: 0, starRadius: 5);
    // Star star1 = Star(x: 200, y: 0, starRadius: 5);
    // star0.dist = 100;
    // star1.dist = 200;
    // starList.add(star0);
    // starList.add(star1);
    Star star0 = starList[0];
    Star star1 = starList[1];
    double z0 = sqrt(star0.dist.square - star0.x.square - star0.y.square);
    if (star0.dist < 0) z0 = -z0;
    double z1 = sqrt(star1.dist.square - star1.x.square - star1.y.square);
    if (star1.dist < 0) z1 = -z1;
    double dist = (star0.x - star1.x).square +
        (star0.y - star1.y).square +
        (z0 - z1).square;
    print("star dist init:$dist");
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
        updateStarList(e, rotateAngle);
        prePosition = newPosition;
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
            painter: SpherePainter(starList),
          )),
    );
  }

  Offset getPosition(Random random, double r) {
    // int negative = random.nextBool() ? 1 : -1;
    double x = random.rangeDouble(-sphereRadius, sphereRadius);
    // negative = random.nextBool() ? 1 : -1;
    double y = random.rangeDouble(
        (-sphereRadius / (8)).round5, (sphereRadius / (8)).round5);
    double dist = x.square.round5 + y.square.round5;
    if (dist > r.square) {
      double ratio = (r.square.round5 / (dist)).round5;
      x = (x * (ratio)).round5;
      y = (y * (ratio)).round5;
    }
    // print("x:$x y:$y");
    return Offset(x, y);
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
    print("angleZ_Y:$angleZ_Y");
    print(Offset(0.0, angleZ_Y));
    print(Offset(0.01, -0.006737888419176885));
    // return Offset(angleZ_X, angleZ_Y);
    return [angleZ_X, angleZ_Y];
    // return Offset(angleZ_X, 0);
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

  void updateStarList(DragUpdateDetails e, List rotateAngle) {
    double newX;
    double newY;
    // projection radius 投影半径
    double radiusX_Y;
    double radiusZ_Y;
    double radiusZ_X;
    double initAngleX_Y = 0;
    double newAngleX_Y = 0;
    double initAngleZ_Y = 0;
    double newAngleZ_Y = 0;
    double initAngleZ_X = 0;
    double newAngleZ_X = 0;
    int num = 1;
    starList.forEach((element) {
      radiusZ_Y = sqrt(element.dist.square - element.x.square);
      radiusZ_X = sqrt(element.dist.square - element.y.square);
      element.y =
          element.y.abs() > radiusZ_Y ? radiusZ_Y * element.y.sign : element.y;
      element.x =
          element.x.abs() > radiusZ_X ? radiusZ_X * element.x.sign : element.x;
      if (radiusZ_Y == 0) {
        // 此时垂直于X_Y平面
        // initAngleX_Y = asin(element.y / element.dist);
        // if (element.x < 0 && element.y > 0) initAngleX_Y = pi - initAngleX_Y;
        // if (element.x < 0 && element.y < 0) initAngleX_Y = pi - initAngleX_Y;
        // newAngleX_Y = initAngleX_Y + rotateAngle[1];
        // newY = element.dist.abs() * (sin(newAngleX_Y));
        newY = 0;
      } else {
        initAngleZ_Y = asin((element.y / radiusZ_Y));
        if (element.dist < 0 && element.y > 0) {
          initAngleZ_Y = pi - initAngleZ_Y;
        }
        if (element.dist < 0 && element.y < 0) initAngleZ_Y = pi - initAngleZ_Y;
        newAngleZ_Y = initAngleZ_Y + rotateAngle[1];
        newY = radiusZ_Y * (sin(newAngleZ_Y));
      }
      if (radiusZ_X != 0) {
        initAngleZ_X = acos((element.x / radiusZ_X));
        if (element.dist < 0) initAngleZ_X = 2 * pi - initAngleZ_X;
        newAngleZ_X = initAngleZ_X + rotateAngle[0];
        newX = radiusZ_X * cos(newAngleZ_X);
      } else {
        // 此时垂直于Z_X平面
        newX = 0;
      }
      if (newAngleZ_X * initAngleZ_X < 0 ||
          (newAngleZ_X - pi) * (initAngleZ_X - pi) < 0 ||
          (newAngleZ_X - 2 * pi) * (initAngleZ_X - 2 * pi) < 0 ||
          (newAngleZ_Y - pi / 2) * (initAngleZ_Y - pi / 2) < 0 ||
          (newAngleZ_Y + pi / 2) * (initAngleZ_Y + pi / 2) < 0 ||
          (newAngleZ_Y - 3 * pi / 2) * (initAngleZ_Y - 3 * pi / 2) < 0) {
        element.dist = -element.dist;
      }
      newX = newX.round5;
      newY = newY.round5;
      double dist = newX.square + newY.square;
      if (dist > element.dist.square) {
        print(
            "超出范围 x:${element.x} y:${element.y} newX:$newX newY:$newY initAngleZ_X:$initAngleZ_X newAngleZ_X:$newAngleZ_X initAngleZ_Y:$initAngleZ_Y newAngleZ_Y:$newAngleZ_Y");
        double ratio = sqrt(element.dist.square / dist);
        newX *= ratio;
        newY *= ratio;
      }
      // print("x:${element.x}, y:${element.x}, dist:${element.dist}");
      // print("newX:$newX, newY:$newY, dist:${element.dist}");
      // print("rotateAngle:$rotateAngle");
      // print("initAngleZ-X:$initAngleZ_X newAngleZ_X:$newAngleZ_X");
      // print("initAngleZ-Y:$initAngleZ_Y newAngleZ_Y:$newAngleZ_Y");
      element.x = newX;
      element.y = newY;
      num++;
      // print("num:$num");
    });
    Star star0 = starList[0];
    Star star1 = starList[1];
    double z0 = sqrt(star0.dist.square - star0.x.square - star0.y.square);
    if (star0.dist < 0) z0 = -z0;
    double z1 = sqrt(star1.dist.square - star1.x.square - star1.y.square);
    if (star1.dist < 0) z1 = -z1;
    double dist = (star0.x - star1.x).square +
        (star0.y - star1.y).square +
        (z0 - z1).square;
    print("star dist:$dist");
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
        double dPRatio = (1 - zDist / sphereRadius * 0.2);
        ovalWidth = dPRatio * e.starRadius * 0.8;
        ovalHeight = dPRatio * e.starRadius * 0.8;
        ovalWidth = ovalWidth < 1 ? 1 : ovalWidth;
        ovalHeight = ovalHeight < 1 ? 1 : ovalHeight;
        // print(
        //     "e.x:${e.x} e.y:${e.y} e.dist:${e.dist} e.starRadius:${e.starRadius}");
        // print("ovalWidth:$ovalWidth ovalHeight:$ovalHeight dPRatio$dPRatio");
        _paint.color = Color(0x55CC33CC);
        canvas.drawOval(
            Rect.fromCenter(
                center: center, width: 3 * ovalWidth, height: 3 * ovalHeight),
            _paint);
        _paint.color = Color(0xFF3345FF);
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
        double dPRatio = 1 - (sphereRadius - zDist) / sphereRadius * 0.2;
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

class Star {
  late double _dist;
  double x;
  double y;
  double starRadius;

  double get dist => _dist;
  set dist(double radius) => _dist = radius;

  Star({required this.x, required this.y, required this.starRadius});
}

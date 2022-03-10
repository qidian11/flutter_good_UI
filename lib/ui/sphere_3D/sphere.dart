import "dart:math";
import "package:flutter/material.dart";
import 'package:flutter_good_ui/util/extension_util.dart';
import 'package:flutter_good_ui/ui/sphere_3D/sphere_construct.dart';

const double sphereRadius = 300;
const double dP = 0.6;

class SphereViewer extends StatefulWidget {
  final int starNum;
  final Color starColor;
  final Color starShaderColor;
  const SphereViewer(
      {Key? key,
      this.starNum = 300,
      this.starColor = Colors.blue,
      this.starShaderColor = const Color(0xCC21CCF3)})
      : super(key: key);

  @override
  State<SphereViewer> createState() => _SphereViewerState();
}

class _SphereViewerState extends State<SphereViewer> {
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
        List<double> rotateAngle = getRotateAngle(prePosition, newPosition);
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
            painter: SpherePainter(sphereInfo.starList,
                defaultStar: sphereInfo.defaultStar),
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
    return [angleZ_X, 0];
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

class SpherePainter extends CustomPainter {
  late Size size;
  List<Star> starList;
  Star defaultStar;
  Paint _paint = Paint()
    ..isAntiAlias = true
    // ..style = PaintingStyle.stroke
    ..style = PaintingStyle.fill
    ..strokeWidth = 0.5
    ..color = Colors.white;

  SpherePainter(this.starList, {required this.defaultStar});

  @override
  void paint(Canvas canvas, Size size) {
    double height = size.height;
    double width = size.width;

    this.size = size;
    canvas.translate(width / 2, height / 2);
    _paint.color = Color(0xFFFFFF66);
    canvas.drawLine(Offset.zero, Offset(0, sphereRadius), _paint);
    canvas.drawLine(Offset.zero, Offset(0, -sphereRadius), _paint);
    canvas.drawLine(Offset.zero, Offset(sphereRadius, 0), _paint);
    canvas.drawLine(Offset.zero, Offset(-sphereRadius, 0), _paint);
    int alpha = 0xFF;
    canvas.drawCircle(Offset(defaultStar.x, defaultStar.y), 5, _paint);
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

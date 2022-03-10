import "dart:math";
import "package:flutter/material.dart";
import 'package:flutter_good_ui/util/extension_util.dart';

enum SphereType { Ring, Sphere }
enum RotateType { ZX, ZY } //

class SphereInfo {
  List<Star> starList = [];
  // rotate angle
  double preRotateAngleZ_X = 0.0;
  double nowRotateAngleZ_X = 0.0;
  double preRotateAngleZ_Y = 0.0;
  double nowRotateAngleZ_Y = 0.0;
  // rotate which plane first
  RotateType rotateType = RotateType.ZX;
  Star defaultStar = Star(x: 0, y: 0, starRadius: 0, dist: 10);
  double sphereRadius;
  int starNum;
  late SphereType type;

  SphereInfo.ring({this.starNum = 1, this.sphereRadius = 300}) {
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

  void updateStarList(List<double> rotateAngle) {
    updateDefaultStar(rotateAngle);
    getRotateAngle();
    print("nowRotateAngleZ_X:$nowRotateAngleZ_X");
    double newX;
    double newY;
    // projection radius 投影半径
    double radiusZ_Y;
    double radiusZ_X;
    double initAngleZ_Y = 0;
    double newAngleZ_Y = 0;
    // double initAngleZ_X = 0;
    double newAngleZ_X = 0;
    print("rotateType:$rotateType");
    starList.forEach((e) {
      // radiusZ_X = sqrt(e.dist.square - e.y.square);
      if (rotateType == RotateType.ZX) {
        radiusZ_X = sqrt(e.dist.square - e.initY.square);
        if (radiusZ_X != 0) {
          // initAngleZ_X = acos((element.x / radiusZ_X));
          // if (element.dist < 0) initAngleZ_X = 2 * pi - initAngleZ_X;
          // newAngleZ_X = initAngleZ_X + rotateAngle[0];
          newAngleZ_X = e.initAngleZ_X + nowRotateAngleZ_X;
          newX = radiusZ_X * cos(newAngleZ_X);
        } else {
          // 此时垂直于Z_X平面
          newX = 0;
        }
        e.x = newX;
        if ((newAngleZ_X > pi && newAngleZ_X < 2 * pi) ||
            (newAngleZ_X > 3 * pi && newAngleZ_X < 4 * pi) ||
            (newAngleZ_X < 0 && newAngleZ_X > -pi) ||
            (newAngleZ_X < -2 * pi && newAngleZ_X > -3 * pi)) {
          e.dist = -e.dist.abs();
        } else {
          if (newAngleZ_X != 0) e.dist = e.dist.abs();
        }
        radiusZ_Y = sqrt(e.dist.square - e.x.square);
        if (radiusZ_Y == 0) {
          // 此时垂直于X_Y平面
          newY = 0;
        } else {
          initAngleZ_Y = asin((e.initY / radiusZ_Y));
          if (e.dist < 0 && e.initY > 0) {
            initAngleZ_Y = pi - initAngleZ_Y;
          }
          if (e.dist < 0 && e.initY < 0) initAngleZ_Y = -pi - initAngleZ_Y;
          newAngleZ_Y = initAngleZ_Y + nowRotateAngleZ_Y;
          newY = radiusZ_Y * (sin(newAngleZ_Y));
        }
        // rotate from front to back
        // 转到背面
        if ((newAngleZ_Y > pi / 2 && newAngleZ_Y < 3 * pi / 2) ||
            (newAngleZ_Y > 5 * pi / 2 && newAngleZ_Y < 7 * pi / 2) ||
            (newAngleZ_Y < -pi / 2 && newAngleZ_Y > -3 * pi / 2) ||
            (newAngleZ_Y < -5 * pi / 2 && newAngleZ_Y > -7 * pi / 2)) {
          e.dist = -e.dist.abs();
        } else {
          if (newAngleZ_Y != 0) e.dist = e.dist.abs();
        }
        print("nowRotateAngleZ_Y:$nowRotateAngleZ_Y");
        print("e.dist: ${e.dist}");
        double dist = newX.square + newY.square;
        if (dist > e.dist.square) {
          // print(
          //     "超出范围 x:${e.x} y:${e.y} newX:$newX newY:$newY initAngleZ_X:${e.initAngleZ_X} newAngleZ_X:$newAngleZ_X initAngleZ_Y:${e.initAngleZ_Y} newAngleZ_Y:$newAngleZ_Y");
          double ratio = sqrt(e.dist.square / dist);
          newX *= ratio;
          newY *= ratio;
        }
        // print(
        //     "超出范围 x:${e.x} y:${e.y} newX:$newX newY:$newY initAngleZ_X:${e.initAngleZ_X} newAngleZ_X:$newAngleZ_X initAngleZ_Y:${initAngleZ_Y} newAngleZ_Y:$newAngleZ_Y");
        // print("x:${element.x}, y:${element.x}, dist:${element.dist}");
        // print("newX:$newX, newY:$newY, dist:${element.dist}");
        // print("rotateAngle:$rotateAngle");
        // print("initAngleZ-X:$initAngleZ_X newAngleZ_X:$newAngleZ_X");
        // print("initAngleZ-Y:$initAngleZ_Y newAngleZ_Y:$newAngleZ_Y");
        e.x = newX;
        e.y = newY;
        print("e.x:${e.x} e.y:${e.y}");
      } else {
        // rotate in plane Z_Y first
        radiusZ_Y = sqrt(e.dist.square - e.initX.square);
        if (radiusZ_Y != 0) {
          // initAngleZ_X = acos((element.x / radiusZ_X));
          // if (element.dist < 0) initAngleZ_X = 2 * pi - initAngleZ_X;
          // newAngleZ_X = initAngleZ_X + rotateAngle[0];
          newAngleZ_Y = e.initAngleZ_Y + nowRotateAngleZ_Y;
          newY = radiusZ_Y * sin(newAngleZ_Y);
        } else {
          // 此时垂直于Z_X平面
          newY = 0;
        }
        e.y = newY;
        // rotate from front to back
        // 转到背面
        if ((newAngleZ_Y > pi / 2 && newAngleZ_Y < 3 * pi / 2) ||
            (newAngleZ_Y > 5 * pi / 2 && newAngleZ_Y < 7 * pi / 2) ||
            (newAngleZ_Y < -pi / 2 && newAngleZ_Y > -3 * pi / 2) ||
            (newAngleZ_Y < -5 * pi / 2 && newAngleZ_Y > -7 * pi / 2)) {
          e.dist = -e.dist.abs();
        } else {
          if (newAngleZ_Y != 0) e.dist = e.dist.abs();
        }

        radiusZ_X = sqrt(e.dist.square - e.y.square);
        if (radiusZ_X == 0) {
          // 此时垂直于X_Y平面
          newX = 0;
        } else {
          double initAngleZ_X = acos((e.initX / radiusZ_X));
          if (e.dist < 0) initAngleZ_X = 2 * pi - initAngleZ_X;
          newAngleZ_X = initAngleZ_X + nowRotateAngleZ_X;
          newX = radiusZ_X * cos(newAngleZ_X);
        }

        // rotate from front to back
        // 转到背面
        if ((newAngleZ_X > pi && newAngleZ_X < 2 * pi) ||
            (newAngleZ_X > 3 * pi && newAngleZ_X < 4 * pi) ||
            (newAngleZ_X < 0 && newAngleZ_X > -pi) ||
            (newAngleZ_X < -2 * pi && newAngleZ_X > -3 * pi)) {
          e.dist = -e.dist.abs();
        } else {
          if (newAngleZ_X != 0) e.dist = e.dist.abs();
        }

        double dist = newX.square + newY.square;
        if (dist > e.dist.square) {
          // print(
          //     "超出范围 x:${e.x} y:${e.y} newX:$newX newY:$newY initAngleZ_X:${e.initAngleZ_X} newAngleZ_X:$newAngleZ_X initAngleZ_Y:${e.initAngleZ_Y} newAngleZ_Y:$newAngleZ_Y");
          double ratio = sqrt(e.dist.square / dist);
          newX *= ratio;
          newY *= ratio;
        }
        // print(
        //     "超出范围 x:${e.x} y:${e.y} newX:$newX newY:$newY initAngleZ_X:${e.initAngleZ_X} newAngleZ_X:$newAngleZ_X initAngleZ_Y:${initAngleZ_Y} newAngleZ_Y:$newAngleZ_Y");
        // print("x:${element.x}, y:${element.x}, dist:${element.dist}");
        // print("newX:$newX, newY:$newY, dist:${element.dist}");
        // print("rotateAngle:$rotateAngle");
        // print("initAngleZ-X:$initAngleZ_X newAngleZ_X:$newAngleZ_X");
        // print("initAngleZ-Y:$initAngleZ_Y newAngleZ_Y:$newAngleZ_Y");
        e.x = newX;
        e.y = newY;
        print("e.x:${e.x} e.y:${e.y}");
      }
    });
    preRotateAngleZ_X = nowRotateAngleZ_X;
    preRotateAngleZ_Y = nowRotateAngleZ_Y;
  }

  void updateDefaultStar(List<double> rotateAngle) {
    double initAngleZ_X = 0;
    double initAngleZ_Y = 0;
    double newAngleZ_X = 0;
    double newAngleZ_Y = 0;
    double newX;
    double newY;
    double radiusZ_X = sqrt(defaultStar.dist.square - defaultStar.y.square);
    if (radiusZ_X != 0) {
      initAngleZ_X = acos((defaultStar.x / radiusZ_X));
      print("defaultStar initAngleZ_X before :$initAngleZ_X");
      if (defaultStar.dist < 0) initAngleZ_X = 2 * pi - initAngleZ_X;
      newAngleZ_X = initAngleZ_X + rotateAngle[0];
      newX = radiusZ_X * cos(newAngleZ_X);
    } else {
      // 此时垂直于Z_X平面
      newX = 0;
    }
    print("defaultStar.x:${defaultStar.x}");
    defaultStar.x = newX;
    print("defaultStar initAngleZ_X:$initAngleZ_X");
    print(rotateAngle[0]);
    print("defaultStar newAngleZ_X:$newAngleZ_X");
    print("defaultStar.newX:${defaultStar.x}");
    if ((newAngleZ_X > pi && newAngleZ_X < 2 * pi) ||
        (newAngleZ_X > 3 * pi && newAngleZ_X < 4 * pi) ||
        (newAngleZ_X < 0 && newAngleZ_X > -pi) ||
        (newAngleZ_X < -2 * pi && newAngleZ_X > -3 * pi)) {
      defaultStar.dist = -defaultStar.dist.abs();
    } else {
      if (newAngleZ_X != 0) defaultStar.dist = defaultStar.dist.abs();
    }
    double radiusZ_Y = sqrt(defaultStar.dist.square - defaultStar.x.square);
    if (radiusZ_Y == 0) {
      // 此时垂直于X_Y平面
      newY = 0;
    } else {
      initAngleZ_Y = asin((defaultStar.y / radiusZ_Y));
      if (defaultStar.dist < 0 && defaultStar.y > 0) {
        initAngleZ_Y = pi - initAngleZ_Y;
      }
      if (defaultStar.dist < 0 && defaultStar.y < 0)
        initAngleZ_Y = -pi - initAngleZ_Y;
      newAngleZ_Y = initAngleZ_Y + rotateAngle[1];
      newY = radiusZ_Y * (sin(newAngleZ_Y));
    }
    print("defaultStar newAngleZ_Y:$newAngleZ_Y");
    // rotate from front to back
    // 转到背面
    if ((newAngleZ_Y > pi / 2 && newAngleZ_Y < 3 * pi / 2) ||
        (newAngleZ_Y > 5 * pi / 2 && newAngleZ_Y < 7 * pi / 2) ||
        (newAngleZ_Y < -pi / 2 && newAngleZ_Y > -3 * pi / 2) ||
        (newAngleZ_Y < -5 * pi / 2 && newAngleZ_Y > -7 * pi / 2)) {
      defaultStar.dist = -defaultStar.dist.abs();
    } else {
      if (newAngleZ_Y != 0) {
        defaultStar.dist = defaultStar.dist.abs();
      }
    }
    print("defaultStar dist:${defaultStar.dist}");
    double dist = newX.square + newY.square;
    if (dist > defaultStar.dist.square) {
      // print(
      //     "超出范围 x:${e.x} y:${e.y} newX:$newX newY:$newY initAngleZ_X:${e.initAngleZ_X} newAngleZ_X:$newAngleZ_X initAngleZ_Y:${e.initAngleZ_Y} newAngleZ_Y:$newAngleZ_Y");
      double ratio = sqrt(defaultStar.dist.square / dist);
      newX *= ratio;
      newY *= ratio;
    }
    defaultStar.x = newX;
    defaultStar.y = newY;
  }

  List<double> getNewZ_X(Star star, List<double> rotateAngle) {
    double radiusZ_X = sqrt(star.dist.square - star.y.square);
    double initAngleZ_X = 0;
    double newAngleZ_X = 0;
    double newX = 0;
    if (radiusZ_X != 0) {
      initAngleZ_X = acos((star.x / radiusZ_X));
      if (star.dist < 0) initAngleZ_X = 2 * pi - initAngleZ_X;
      newAngleZ_X = initAngleZ_X + rotateAngle[0];
      newX = radiusZ_X * cos(newAngleZ_X);
    } else {
      // 此时垂直于Z_X平面
      newX = 0;
    }
    return [newX, newAngleZ_X];
  }

  getRotateAngle() {
    double nowAngleZ_X = 0;
    double nowAngleZ_Y = 0;
    double newAngleZ_X = 0;
    double tempAngleZ_Y = 0; // 中间状态的角度
    double newX;
    double newY;
    // double radiusZ_X = sqrt(defaultStar.dist.square - defaultStar.initY.square);
    if (defaultStar.x.abs() <= defaultStar.initRadiusZ_X) {
      // rotate in Z_X first
      rotateType = RotateType.ZX;
      if (defaultStar.initRadiusZ_X != 0) {
        nowAngleZ_X = acos((defaultStar.x / defaultStar.initRadiusZ_X));
        if (defaultStar.dist < 0) nowAngleZ_X = 2 * pi - nowAngleZ_X;
      }
      nowRotateAngleZ_X = nowAngleZ_X - defaultStar.initAngleZ_X;
      double radiusZ_Y = sqrt(defaultStar.dist.square - defaultStar.x.square);
      if (radiusZ_Y != 0) {
        nowAngleZ_Y = asin((defaultStar.y / radiusZ_Y));
        tempAngleZ_Y = asin((defaultStar.initY / radiusZ_Y));
        if (defaultStar.dist < 0 && defaultStar.y > 0) {
          nowAngleZ_Y = pi - nowAngleZ_Y;
        }
        if (defaultStar.dist < 0 && defaultStar.y < 0)
          nowAngleZ_Y = -nowAngleZ_Y - pi;
        if (defaultStar.dist < 0 && defaultStar.initY > 0) {
          tempAngleZ_Y = pi - tempAngleZ_Y;
        }
        if (defaultStar.dist < 0 && defaultStar.initY < 0)
          tempAngleZ_Y = -tempAngleZ_Y - pi;
      }
      nowRotateAngleZ_Y = nowAngleZ_Y - tempAngleZ_Y;
    } else // rotate in Z_Y first
    {
      rotateType = RotateType.ZY;
      if (defaultStar.initRadiusZ_Y != 0) {
        nowAngleZ_Y = acos((defaultStar.y / defaultStar.initRadiusZ_Y));
        if (defaultStar.dist < 0 && defaultStar.y > 0) {
          nowAngleZ_Y = pi - nowAngleZ_Y;
        }
        if (defaultStar.dist < 0 && defaultStar.y < 0)
          nowAngleZ_Y = pi - nowAngleZ_Y;
      }
      nowRotateAngleZ_Y = nowAngleZ_Y - defaultStar.initAngleZ_Y;
      double radiusZ_X = sqrt(defaultStar.dist.square - defaultStar.y.square);
      if (radiusZ_X != 0) {
        nowAngleZ_X = asin((defaultStar.x / radiusZ_X));
        double tempAngleZ_X = asin((defaultStar.initY / radiusZ_X));
        if (defaultStar.dist < 0) nowAngleZ_X = 2 * pi - nowAngleZ_X;
        if (defaultStar.dist < 0) tempAngleZ_X = 2 * pi - tempAngleZ_X;
      }
      nowRotateAngleZ_Y = nowAngleZ_Y - tempAngleZ_Y;
    }
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
  late double _initRadiusZ_X;
  late double _initRadiusZ_Y;
  double starRadius;

  double get initAngleZ_X => _initAngleZ_X;
  double get initAngleZ_Y => _initAngleZ_Y;
  double get initRadiusZ_X => _initAngleZ_X;
  double get initRadiusZ_Y => _initAngleZ_Y;
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
    _initRadiusZ_X = sqrt(dist.square - _initY.square);
    _initAngleZ_X = acos((_initX / _initRadiusZ_X));
    if (dist < 0) _initAngleZ_X = 2 * pi - _initAngleZ_X;
    _initRadiusZ_Y = sqrt(dist.square - x.square);

    _initAngleZ_Y = asin((y / _initRadiusZ_Y));
    if (dist < 0 && y > 0) {
      _initAngleZ_Y = pi - _initAngleZ_Y;
    }
    if (dist < 0 && y < 0) _initAngleZ_Y = pi - _initAngleZ_Y;
  }
}

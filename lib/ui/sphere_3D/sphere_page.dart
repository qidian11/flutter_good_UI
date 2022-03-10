import 'package:flutter/material.dart';
import 'package:flutter_good_ui/ui/sphere_3D/sphere.dart';
import 'package:flutter_good_ui/ui/sphere_3D/sphere_construct.dart';

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
  List<Star> starList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
      body: const Center(
        child: SphereViewer(),
      ),
    );
  }
}

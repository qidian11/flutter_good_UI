import 'package:flutter/cupertino.dart';

import 'package:flutter_good_ui/ui/index.dart';

class NavigatorUtil {
  static Map<String, WidgetBuilder> Routes = {
    My3DSphere.name: (_) => const My3DSphere(),
  };
}

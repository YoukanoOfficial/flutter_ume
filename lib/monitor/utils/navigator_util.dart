import 'package:flutter/material.dart';

class NavigatorUtil {
  static void pushPage(BuildContext context, Widget child) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => child));
  }
}

import 'package:flutter/material.dart';

class CommonSnackBar {
  static buildSnackBar(BuildContext context, String str) {
    final snackBar = new SnackBar(content: new Text(str));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  static buildSnackBarByKey(
      final GlobalKey<ScaffoldState> key, BuildContext context, String str) {
    final snackBar = new SnackBar(content: new Text(str));
    key.currentState.showSnackBar(snackBar);
  }
}

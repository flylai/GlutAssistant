import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glutassistant/Pages/Home.dart';

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
  SystemUiOverlayStyle systemUiOverlayStyle =
      SystemUiOverlayStyle(statusBarColor: Colors.transparent);
  SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
}

import 'package:flutter/material.dart';

class DetailCard extends StatelessWidget {
  final Widget child;
  final double opacity;
  final double elevation;
  final double height;
  final EdgeInsets margin;
  final Color color;

  DetailCard(this.color, this.child,
      {this.margin = const EdgeInsets.fromLTRB(13, 13, 13, 3),
      this.elevation = 2.0,
      this.opacity = 0.7,
      this.height = 80,
      Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: margin,
        color: color.withOpacity(opacity),
        elevation: elevation,
        child: Container(
            margin: EdgeInsets.all(10),
            height: height,
            width: double.infinity,
            child: child));
  }
}

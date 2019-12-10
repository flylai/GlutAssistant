import 'dart:ui';

class CourseBox {
  final bool empty;
  final double marginTop;
  final double padding;
  final Color color;
  final String text;
  final double height;
  final int weekday;
  final int startTime;
  final int endTime;

  CourseBox(this.empty, this.marginTop, this.padding, this.color, this.text,
      this.height,
      {this.weekday, this.startTime, this.endTime});
}

import 'package:flutter/material.dart';
import 'package:glutassistant/Widget/SnackBar.dart';

class Timetable extends StatefulWidget {
  _TimetableState createState() => _TimetableState();
}

class _TimetableState extends State<Timetable> {
  @override
  Widget build(BuildContext context) {
    print('sfaf');
    return Container(
        child: Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Text('data1'),
            Text('data2'),
            Text('data3'),
            Text('data4'),
            Text('data5'),
            Text('data6'),
            Text('data7')
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Column(
              children: <Widget>[
                Text('data1'),
                Text('data2'),
                Text('data3'),
                Text('data4'),
                Text('data5'),
                Text('data6'),
                Text('data7')
              ],
            ),
            Column(
              children: <Widget>[
                Text('data1'),
                Text('data2'),
                Text('data3'),
                Text('data4'),
                Text('data5'),
                Text('data6'),
                Text('data7')
              ],
            ),
            Column(
              children: <Widget>[
                Text('data1'),
                Text('data2'),
                Text('data3'),
                Text('data4'),
                Text('data5'),
                Text('data6'),
                Text('data7')
              ],
            ),
            Column(
              children: <Widget>[
                Text('data1'),
                Text('data2'),
                Text('data3'),
                Text('data4'),
                Text('data5'),
                Text('data6'),
                Text('data7')
              ],
            ),
            Column(
              children: <Widget>[
                Text('data1'),
                Text('data2'),
                Text('data3'),
                Text('data4'),
                Text('data5'),
                Text('data6'),
                Text('data7')
              ],
            ),
            Column(
              children: <Widget>[
                Text('data1'),
                Text('data2'),
                Text('data3'),
                Text('data4'),
                Text('data5'),
                Text('data6'),
                Text('data7')
              ],
            ),
            Column(
              children: <Widget>[
                Text('data1'),
                Text('data2'),
                Text('data3'),
                Text('data4'),
                Text('data5'),
                Text('data6'),
                Text('data7')
              ],
            )
          ],
        )
      ],
    ));
  }
}

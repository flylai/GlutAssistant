import 'package:flutter/material.dart';
import 'dart:core';

import 'package:glutassistant/Utility/FileUtil.dart';
import 'package:glutassistant/Common/Constant.dart';
import 'package:glutassistant/Utility/HttpUtil.dart';
import 'package:glutassistant/Utility/SqliteUtil.dart';

class ImportTimetable extends StatefulWidget {
  _ImportTimetableState createState() => _ImportTimetableState();
}

class _ImportTimetableState extends State<ImportTimetable> {
  int _selectYearValue = 2019;
  var _selectTermValue = 2;
  String _cookie;

  @override
  void initState() {
    super.initState();
    FileUtil.getFileDir();
    SqliteUtil.init();
  }

  List<DropdownMenuItem> _generateYearList() {
    List<DropdownMenuItem> items = List();
    int year = DateTime.now().year;
    for (var i = 0; i < 5; i++) {
      int _year = year - i;
      DropdownMenuItem item =
          DropdownMenuItem(value: _year, child: Text(_year.toString()));
      items.add(item);
    }
    return items;
  }

  List<DropdownMenuItem> _generateTermList() {
    List<DropdownMenuItem> items = List();
    DropdownMenuItem item = DropdownMenuItem(value: 1, child: Text('春'));
    items.add(item);
    DropdownMenuItem item2 = DropdownMenuItem(value: 2, child: Text('秋'));
    items.add(item2);
    return items;
  }

  Widget _buildYearDropdown() {
    return DropdownButtonHideUnderline(
      child: DropdownButton(
        value: _selectYearValue,
        items: _generateYearList(),
        onChanged: (value) {
          setState(() {
            _selectYearValue = value;
          });
        },
      ),
    );
  }

  Widget _buildTermDropdown() {
    return DropdownButtonHideUnderline(
      child: DropdownButton(
        value: _selectTermValue,
        items: _generateTermList(),
        onChanged: (value) {
          setState(() {
            _selectTermValue = value;
            print(value);
          });
        },
      ),
    );
  }

  Widget _buildImportButtom() {
    return RaisedButton(
      onPressed: () {
        _cookie = FileUtil.readFile(Constant.FILE_SESSION);
        print(_cookie);
        HttpUtil.importTimeTable('2019', '1', _cookie, (callback) {});
      },
      color: Colors.blue,
      child: Text(
        '导入课表',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.fromLTRB(30, 50, 30, 50),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: _buildYearDropdown(),
                ),
                Expanded(
                  child: _buildTermDropdown(),
                )
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: _buildImportButtom(),
                )
              ],
            )
          ],
        ));
  }
}
